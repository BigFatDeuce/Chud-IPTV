import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/source.dart';

const backupFormat = 'chud-iptv-backup';
const backupVersion = 1;
const backupExtension = 'chudbackup';

/// Étirement de la phrase de passe, noté dans le fichier pour pouvoir évoluer.
const _iterations = 600000;
const _keyBits = 256;

enum BackupError { notBackup, tooNew, wrongPassphrase, damaged }

class BackupFailure implements Exception {
  const BackupFailure(this.error);

  final BackupError error;
}

/// Ce qu'annonce un fichier avant d'être ouvert. Les compteurs ne révèlent aucun identifiant.
class BackupHeader {
  const BackupHeader({required this.encrypted, required this.createdAt, required this.sources, required this.lists, required this.favorites});

  final bool encrypted;
  final DateTime createdAt;
  final int sources;
  final int lists;
  final int favorites;
}

class RestoreReport {
  const RestoreReport({required this.toRefresh, required this.incomplete});

  /// Sources ajoutées et complètes, à importer tout de suite.
  final List<int> toRefresh;

  /// Sources dont le mot de passe ou l'adresse n'était pas dans le fichier.
  final int incomplete;
}

/// Une adresse de playlist contient presque toujours des identifiants, dans la requête ou dans
/// le chemin : hors fichier chiffré, on n'en garde que le serveur.
String serverOnly(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return '';
  return Uri(scheme: uri.scheme, host: uri.host, port: uri.hasPort ? uri.port : null).toString();
}

/// Lit ce qui est propre à l'utilisateur. Le catalogue n'y est pas : il se réimporte.
/// Sans [secrets], ni mot de passe ni adresse complète n'en sortent.
Map<String, Object?> readBackup(Database db, {required bool secrets}) {
  final sources = <Map<String, Object?>>[];
  for (final r in db.select('SELECT * FROM sources ORDER BY id')) {
    final isPlaylist = r['kind'] == SourceKind.m3uUrl.name;
    final incomplete = !secrets && (isPlaylist || (r['password'] as String).isNotEmpty);
    sources.add({
      'id': r['id'],
      'name': r['name'],
      'kind': r['kind'],
      'url': !secrets && isPlaylist ? serverOnly(r['url'] as String) : r['url'],
      'username': r['username'],
      'password': secrets ? r['password'] : '',
      'enabled': r['enabled'],
      'isDefault': r['is_default'],
      'withMovies': r['with_movies'],
      'withSeries': r['with_series'],
      'epgUrl': secrets ? r['epg_url'] : '',
      'incomplete': incomplete,
    });
  }
  return {
    'sources': sources,
    'settings': {
      for (final r in db.select("SELECT key, value FROM settings WHERE key NOT IN ('player.external', 'download.dir')")) r.columnAt(0) as String: r.columnAt(1),
    },
    'lists': [
      for (final r in db.select('SELECT id, name, icon FROM fav_lists ORDER BY position')) {'id': r.columnAt(0), 'name': r.columnAt(1), 'icon': r.columnAt(2)},
    ],
    'favorites': [
      for (final r in db.select(
        'SELECT f.list_id, f.position, i.source_id, i.type, i.stable_key FROM fav_items f JOIN items i ON i.id = f.item_id ORDER BY f.list_id, f.position',
      ))
        {'list': r.columnAt(0), 'position': r.columnAt(1), 'source': r.columnAt(2), 'type': r.columnAt(3), 'key': r.columnAt(4)},
    ],
    'guides': secrets
        ? [
            for (final r in db.select("SELECT name, url FROM epg_sources WHERE source_id IS NULL AND url <> ''")) {'name': r.columnAt(0), 'url': r.columnAt(1)},
          ]
        : const <Object>[],
    'links': [
      for (final r in db.select('SELECT l.channel, i.source_id, i.type, i.stable_key FROM epg_links l JOIN items i ON i.id = l.item_id WHERE l.manual = 1'))
        {'channel': r.columnAt(0), 'source': r.columnAt(1), 'type': r.columnAt(2), 'key': r.columnAt(3)},
    ],
  };
}

int _matchingSource(Database db, Map<String, dynamic> s) {
  // Une playlist sans son adresse complète se reconnaît à son serveur.
  final cut = s['incomplete'] == true && s['kind'] == SourceKind.m3uUrl.name;
  final rows = db.select(
    "SELECT id FROM sources WHERE kind = ?1 AND username = ?3 AND (url = ?2 ${cut ? "OR url LIKE ?2 || '/%'" : ''})",
    [s['kind'], s['url'], s['username']],
  );
  return rows.isEmpty ? 0 : rows.first.columnAt(0) as int;
}

void _attach(Database db, int? source, Map<String, dynamic> entry, {int? list, int position = 0, String? channel}) {
  if (source == null) return;
  db.execute(
    'INSERT INTO restore_pending(source_id, type, stable_key, list_id, position, channel) VALUES(?,?,?,?,?,?)',
    [source, entry['type'], entry['key'], list, position, channel],
  );
}

/// Ajoute une sauvegarde aux données présentes, sans rien retirer : une source déjà là est
/// réutilisée, une liste de même nom est complétée. Seuls les réglages sont remplacés.
RestoreReport applyBackup(Database db, Map<String, dynamic> data) {
  final refresh = <int>[];
  var incomplete = 0;
  final sourceIds = <int, int>{};
  final listIds = <int, int>{};
  final added = <int>{};
  db.execute('BEGIN IMMEDIATE');
  try {
    for (final s in (data['sources'] as List).cast<Map<String, dynamic>>()) {
      final missing = s['incomplete'] == true;
      var id = _matchingSource(db, s);
      if (id == 0) {
        db.execute(
          'INSERT INTO sources(name, kind, url, username, password, enabled, is_default, with_movies, with_series, epg_url, error, error_at) '
          'VALUES(?,?,?,?,?,?, (SELECT count(*) = 0 FROM sources) AND ?, ?,?,?,?,?)',
          [
            s['name'], s['kind'], s['url'], s['username'], s['password'], s['enabled'], s['isDefault'], s['withMovies'], s['withSeries'], s['epgUrl'],
            missing ? ImportError.credentials.name : null,
            missing ? DateTime.now().millisecondsSinceEpoch : null,
          ],
        );
        id = db.lastInsertRowId;
        added.add(id);
        if (missing) {
          incomplete++;
        } else if (s['enabled'] == 1) {
          refresh.add(id);
        }
      } else if (!missing && (s['password'] as String).isNotEmpty) {
        db.execute("UPDATE sources SET password = ? WHERE id = ? AND password = ''", [s['password'], id]);
      }
      sourceIds[s['id'] as int] = id;
    }
    final settings = db.prepare('INSERT OR REPLACE INTO settings(key, value) VALUES(?, ?)');
    for (final e in (data['settings'] as Map<String, dynamic>).entries) {
      settings.execute([e.key, e.value]);
    }
    settings.close();
    for (final list in (data['lists'] as List).cast<Map<String, dynamic>>()) {
      final known = db.select('SELECT id FROM fav_lists WHERE name = ?', [list['name']]);
      if (known.isNotEmpty) {
        listIds[list['id'] as int] = known.first.columnAt(0) as int;
        continue;
      }
      db.execute(
        'INSERT INTO fav_lists(name, icon, position) VALUES(?, ?, (SELECT coalesce(max(position), 0) + 1 FROM fav_lists))',
        [list['name'], list['icon']],
      );
      listIds[list['id'] as int] = db.lastInsertRowId;
    }
    for (final f in (data['favorites'] as List).cast<Map<String, dynamic>>()) {
      _attach(db, sourceIds[f['source']], f, list: listIds[f['list']], position: f['position'] as int);
    }
    for (final g in (data['guides'] as List).cast<Map<String, dynamic>>()) {
      db.execute(
        'INSERT INTO epg_sources(name, url) SELECT ?1, ?2 WHERE NOT EXISTS (SELECT 1 FROM epg_sources WHERE url = ?2)',
        [g['name'], g['url']],
      );
    }
    for (final l in (data['links'] as List).cast<Map<String, dynamic>>()) {
      _attach(db, sourceIds[l['source']], l, channel: l['channel'] as String);
    }
    attachPending(db);
    db.execute('COMMIT');
  } catch (_) {
    db.execute('ROLLBACK');
    rethrow;
  }
  return RestoreReport(toRefresh: refresh, incomplete: incomplete);
}

/// Rattache favoris et associations aux éléments du catalogue. Ceux d'une source pas encore
/// importée attendent : ils se placent à la fin de son import.
void attachPending(Database db) {
  db.execute(
    'INSERT OR IGNORE INTO fav_items(list_id, item_id, position) '
    'SELECT p.list_id, i.id, p.position FROM restore_pending p '
    'JOIN items i ON i.source_id = p.source_id AND i.type = p.type AND i.stable_key = p.stable_key WHERE p.list_id IS NOT NULL',
  );
  db.execute(
    'INSERT OR REPLACE INTO epg_links(item_id, channel, manual) '
    'SELECT i.id, p.channel, 1 FROM restore_pending p '
    'JOIN items i ON i.source_id = p.source_id AND i.type = p.type AND i.stable_key = p.stable_key WHERE p.channel IS NOT NULL',
  );
  db.execute(
    'DELETE FROM restore_pending WHERE EXISTS '
    '(SELECT 1 FROM items i WHERE i.source_id = restore_pending.source_id AND i.type = restore_pending.type AND i.stable_key = restore_pending.stable_key)',
  );
}

Map<String, Object?> _header(Map<String, Object?> data, String appVersion, DateTime now, bool encrypted) => {
      'format': backupFormat,
      'version': backupVersion,
      'createdAt': now.toUtc().toIso8601String(),
      'app': appVersion,
      'encrypted': encrypted,
      'sources': (data['sources'] as List).length,
      'lists': (data['lists'] as List).length,
      'favorites': (data['favorites'] as List).length,
    };

Future<List<int>> _deriveKey(String passphrase, List<int> salt, int iterations) async {
  final kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: _keyBits);
  final key = await kdf.deriveKeyFromPassword(password: passphrase, nonce: salt);
  return key.extractBytes();
}

/// Fichier de sauvegarde. Avec une phrase de passe, tout le contenu est chiffré (AES-256-GCM,
/// clé tirée de la phrase par PBKDF2-SHA256). L'étirement est long : il part dans un isolat.
Future<String> encodeBackup(Map<String, Object?> data, String appVersion, {String? passphrase, DateTime? now}) => Isolate.run(() async {
      final header = _header(data, appVersion, now ?? DateTime.now(), passphrase != null);
      if (passphrase == null) return const JsonEncoder.withIndent(' ').convert({...header, 'data': data});
      final random = Random.secure();
      final salt = [for (var i = 0; i < 16; i++) random.nextInt(256)];
      final cipher = AesGcm.with256bits();
      final key = await _deriveKey(passphrase, salt, _iterations);
      final box = await cipher.encrypt(utf8.encode(jsonEncode(data)), secretKey: SecretKey(key));
      return const JsonEncoder.withIndent(' ').convert({
        ...header,
        'kdf': {'name': 'pbkdf2-sha256', 'iterations': _iterations, 'salt': base64.encode(salt)},
        'cipher': 'aes-256-gcm',
        'nonce': base64.encode(box.nonce),
        'mac': base64.encode(box.mac.bytes),
        'data': base64.encode(box.cipherText),
      });
    });

Map<String, dynamic> _json(String text) {
  try {
    final value = jsonDecode(text);
    if (value is Map<String, dynamic> && value['format'] == backupFormat) return value;
  } on FormatException {
    // Un fichier qui n'est pas du JSON n'est simplement pas une sauvegarde.
  }
  throw const BackupFailure(BackupError.notBackup);
}

/// Lit l'en-tête sans déchiffrer, pour demander confirmation.
BackupHeader readHeader(String text) {
  final json = _json(text);
  if ((json['version'] as num? ?? 0) > backupVersion) throw const BackupFailure(BackupError.tooNew);
  try {
    return BackupHeader(
      encrypted: json['encrypted'] == true,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      sources: json['sources'] as int,
      lists: json['lists'] as int,
      favorites: json['favorites'] as int,
    );
  } on Object {
    throw const BackupFailure(BackupError.damaged);
  }
}

/// Contenu d'un fichier. Une phrase fausse et un fichier modifié échouent au même contrôle.
Future<Map<String, dynamic>> decodeBackup(String text, {String? passphrase}) async {
  final json = _json(text);
  if (json['encrypted'] != true) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    throw const BackupFailure(BackupError.damaged);
  }
  if (passphrase == null) throw const BackupFailure(BackupError.wrongPassphrase);
  final String plain;
  try {
    plain = await Isolate.run(() async {
      final kdf = json['kdf'] as Map<String, dynamic>;
      final key = await _deriveKey(passphrase, base64.decode(kdf['salt'] as String), kdf['iterations'] as int);
      final box = SecretBox(
        base64.decode(json['data'] as String),
        nonce: base64.decode(json['nonce'] as String),
        mac: Mac(base64.decode(json['mac'] as String)),
      );
      return utf8.decode(await AesGcm.with256bits().decrypt(box, secretKey: SecretKey(key)));
    });
  } on SecretBoxAuthenticationError {
    throw const BackupFailure(BackupError.wrongPassphrase);
  } on FormatException {
    throw const BackupFailure(BackupError.damaged);
  } on TypeError {
    throw const BackupFailure(BackupError.damaged);
  }
  return jsonDecode(plain) as Map<String, dynamic>;
}
