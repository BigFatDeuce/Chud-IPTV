import 'dart:math';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../backup/backup.dart';
import '../epg/catchup.dart';
import '../epg/epg_import.dart';
import '../import/text.dart';
import '../models/catalog.dart';
import '../models/download.dart';
import '../models/source.dart';
import 'db_worker.dart';

DateTime? _date(Object? ms) => ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms as int);

Source _source(Row r) => Source(
      id: r['id'] as int,
      name: r['name'] as String,
      kind: SourceKind.values.byName(r['kind'] as String),
      url: r['url'] as String,
      username: r['username'] as String,
      password: r['password'] as String,
      enabled: r['enabled'] == 1,
      isDefault: r['is_default'] == 1,
      withMovies: r['with_movies'] == 1,
      withSeries: r['with_series'] == 1,
      epgUrl: r['epg_url'] as String,
      expiresAt: _date(r['expires_at']),
      maxConnections: r['max_connections'] as int?,
      refreshedAt: _date(r['refreshed_at']),
      error: r['error'] == null ? null : ImportError.values.asNameMap()[r['error']] ?? ImportError.unknown,
      errorDetail: r['error_detail'] as String,
      errorAt: _date(r['error_at']),
      liveCount: r['live_count'] as int,
      movieCount: r['movie_count'] as int,
      seriesCount: r['series_count'] as int,
      serverOffset: r['server_offset'] as int,
    );

/// Une source de guide des programmes.
class EpgSource {
  const EpgSource({
    required this.id,
    required this.name,
    this.url = '',
    this.path = '',
    this.sourceId,
    this.refreshedAt,
    this.error,
    this.programs = 0,
  });

  final int id;
  final String name;
  final String url;
  final String path;

  /// Source IPTV qui fournit ce guide, ou null pour un guide ajouté à la main.
  final int? sourceId;
  final DateTime? refreshedAt;
  final String? error;
  final int programs;
}

/// Ce qu'il faut pour construire l'adresse de lecture d'un élément.
class StreamInfo {
  const StreamInfo({
    required this.type,
    required this.stableKey,
    this.url = '',
    this.extension = '',
    this.httpHeaders = '',
    this.catchup = '',
    this.catchupDays = 0,
    this.catchupSource = '',
  });

  final ItemType type;
  final String stableKey;
  final String url;
  final String extension;
  final String httpHeaders;

  /// Replay annoncé par la source : vide s'il n'y en a pas.
  final String catchup;
  final int catchupDays;
  final String catchupSource;
}

/// Accès à la base depuis l'interface. Les fonctions statiques tournent dans un isolat [DbWorker] :
/// un pour lire, un pour écrire. Une écriture peut attendre la fin d'un import ; les listes, elles,
/// continuent de se charger.
class Repository {
  Repository(this._reader, this._writer);

  final DbWorker _reader;
  final DbWorker _writer;

  static Future<Repository> open(String path) async => Repository(await DbWorker.open(path), await DbWorker.open(path));

  Future<void> close() async {
    await _reader.close();
    await _writer.close();
  }

  Future<List<Source>> sources() => _reader.run(_sources);

  static List<Source> _sources(Database db) =>
      db.select('SELECT * FROM sources ORDER BY is_default DESC, id').map(_source).toList();

  Future<int> addSource(Source s) => _writer.run((db) => _addSource(db, s));

  static int _addSource(Database db, Source s) {
    db.execute(
      'INSERT INTO sources(name, kind, url, username, password, with_movies, with_series, is_default) '
      'VALUES(?,?,?,?,?,?,?, (SELECT count(*) = 0 FROM sources))',
      [s.name, s.kind.name, s.url, s.username, s.password, s.withMovies ? 1 : 0, s.withSeries ? 1 : 0],
    );
    return db.lastInsertRowId;
  }

  /// Enregistre les changements d'une source. Désactiver films ou séries libère aussitôt la place.
  Future<void> updateSource(Source s) => _writer.run((db) => _updateSource(db, s));

  static void _updateSource(Database db, Source s) {
    db.execute('BEGIN IMMEDIATE');
    db.execute(
      'UPDATE sources SET name=?, url=?, username=?, password=?, enabled=?, with_movies=?, with_series=?, '
      'movie_count = CASE WHEN ? THEN movie_count ELSE 0 END, series_count = CASE WHEN ? THEN series_count ELSE 0 END '
      'WHERE id=?',
      [s.name, s.url, s.username, s.password, s.enabled ? 1 : 0, s.withMovies ? 1 : 0, s.withSeries ? 1 : 0,
        s.withMovies ? 1 : 0, s.withSeries ? 1 : 0, s.id],
    );
    for (final (keep, type) in [(s.withMovies, ItemType.movie), (s.withSeries, ItemType.series)]) {
      if (keep) continue;
      db.execute('DELETE FROM fav_items WHERE item_id IN (SELECT id FROM items WHERE source_id=? AND type=?)', [s.id, type.index]);
      db.execute('DELETE FROM items WHERE source_id=? AND type=?', [s.id, type.index]);
      db.execute('DELETE FROM categories WHERE source_id=? AND type=?', [s.id, type.index]);
    }
    db.execute('COMMIT');
  }

  Future<void> deleteSource(int id) => _writer.run((db) => _deleteSource(db, id));

  static void _deleteSource(Database db, int id) {
    db.execute('BEGIN IMMEDIATE');
    db.execute('DELETE FROM fav_items WHERE item_id IN (SELECT id FROM items WHERE source_id=?)', [id]);
    db.execute('DELETE FROM items WHERE source_id=?', [id]);
    db.execute('DELETE FROM categories WHERE source_id=?', [id]);
    db.execute('DELETE FROM sources WHERE id=?', [id]);
    db.execute('DELETE FROM epg_programs WHERE epg_id IN (SELECT id FROM epg_sources WHERE source_id = ?)', [id]);
    db.execute('DELETE FROM epg_sources WHERE source_id = ?', [id]);
    db.execute(
      'UPDATE sources SET is_default = 1 WHERE id = (SELECT min(id) FROM sources) '
      'AND NOT EXISTS (SELECT 1 FROM sources WHERE is_default = 1)',
    );
    db.execute('COMMIT');
  }

  Future<void> setDefaultSource(int id) => _writer.run((db) => _setDefault(db, id));

  static void _setDefault(Database db, int id) => db.execute('UPDATE sources SET is_default = (id = ?)', [id]);

  Future<List<Category>> categories(ItemType type, int? sourceId) =>
      _reader.run((db) => _categories(db, type, sourceId));

  static List<Category> _categories(Database db, ItemType type, int? sourceId) {
    final rows = db.select(
      'SELECT c.id, c.source_id, c.name, c.item_count, c.remote_id FROM categories c JOIN sources s ON s.id = c.source_id '
      'WHERE c.type = ? AND c.hidden = 0 AND c.item_count > 0 AND s.enabled = 1 AND (?2 IS NULL OR c.source_id = ?2) '
      'ORDER BY s.is_default DESC, s.id, c.position',
      [type.index, sourceId],
    );
    return [
      for (final r in rows)
        Category(
          id: r.columnAt(0) as int,
          sourceId: r.columnAt(1) as int,
          type: type,
          name: r.columnAt(2) as String,
          itemCount: r.columnAt(3) as int,
          remoteId: r.columnAt(4) as String,
        ),
    ];
  }

  Future<int> count(BrowseQuery q) => _reader.run((db) => _count(db, q));

  static (String, List<Object?>) _filter(Database db, BrowseQuery q) {
    final where = <String>['i.missing_since IS NULL'];
    final args = <Object?>[];
    final ids = q.categoryIds;
    if (ids != null) {
      where.add('i.category_id IN (${ids.isEmpty ? '0' : ids.join(',')})');
    } else if (q.categoryId != null) {
      where.add('i.category_id = ?');
      args.add(q.categoryId);
    } else {
      where.add('i.type = ?');
      args.add(q.type.index);
    }
    if (q.sourceId != null) {
      where.add('i.source_id = ?');
      args.add(q.sourceId);
    } else if (q.categoryId == null) {
      where.add('i.source_id IN (SELECT id FROM sources WHERE enabled = 1)');
    }
    if (q.country.isNotEmpty) {
      where.add('i.country = ?');
      args.add(q.country);
    }
    if (q.onlyGuide) where.add('i.id IN (SELECT item_id FROM epg_links)');
    if (q.favoriteList != null) {
      where.add('i.id IN (SELECT item_id FROM fav_items WHERE list_id = ?)');
      args.add(q.favoriteList);
    }
    final match = _matchExpression(db, q.text);
    if (match != null) {
      where.add('i.id IN (SELECT rowid FROM items_fts WHERE items_fts MATCH ?)');
      args.add(match);
    }
    return (where.join(' AND '), args);
  }

  static List<String>? _vocabulary;
  static int _vocabularyVersion = -1;

  /// Tous les mots de l'index, relus quand une autre connexion a écrit (un import, par exemple).
  static List<String> _terms(Database db) {
    final version = db.select('PRAGMA data_version').first.columnAt(0) as int;
    if (_vocabulary == null || version != _vocabularyVersion) {
      _vocabulary = [for (final r in db.select('SELECT term FROM items_vocab')) r.columnAt(0) as String];
      _vocabularyVersion = version;
    }
    return _vocabulary!;
  }

  static String _quoted(String term) => '"${term.replaceAll('"', '""')}"';

  /// Traduit une saisie en requête FTS5. Chaque mot doit être trouvé, sous l'une de ces formes :
  /// début de mot, morceau de mot (« sport » dans « eurosport »), ou mot proche s'il n'existe pas tel
  /// quel (« telefot », « eurosprot »). Null si la saisie ne contient aucun mot.
  static String? _matchExpression(Database db, String text) {
    final tokens = normalizeText(text).split(' ').where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return null;
    final vocabulary = tokens.any((t) => t.length >= 3) ? _terms(db) : const <String>[];
    final parts = <String>[];
    for (final token in tokens) {
      final forms = <String>{'${_quoted(token)}*'};
      if (token.length >= 3) {
        var startsSomewhere = false;
        for (final term in vocabulary) {
          if (!term.contains(token)) continue;
          if (term.startsWith(token)) {
            startsSomewhere = true;
          } else if (forms.length < 60) {
            forms.add(_quoted(term));
          }
        }
        if (!startsSomewhere && forms.length == 1 && token.length >= 4) {
          final limit = token.length < 8 ? 1 : 2;
          for (final term in vocabulary) {
            final head = term.length > token.length + limit ? term.substring(0, token.length) : term;
            if (_editDistance(token, head, limit) <= limit) forms.add(_quoted(term));
            if (forms.length >= 40) break;
          }
        }
      }
      parts.add(forms.length == 1 ? forms.first : '(${forms.join(' OR ')})');
    }
    return parts.join(' AND ');
  }

  /// Distance de Damerau-Levenshtein, abandonnée dès qu'elle dépasse [limit].
  static int _editDistance(String a, String b, int limit) {
    if ((a.length - b.length).abs() > limit) return limit + 1;
    var before = Uint8List(b.length + 1), previous = Uint8List(b.length + 1), current = Uint8List(b.length + 1);
    for (var j = 0; j <= b.length; j++) {
      previous[j] = j;
    }
    for (var i = 1; i <= a.length; i++) {
      current[0] = i;
      var best = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        var value = min(min(previous[j] + 1, current[j - 1] + 1), previous[j - 1] + cost);
        if (i > 1 && j > 1 && a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) && a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1)) {
          value = min(value, before[j - 2] + 1);
        }
        current[j] = value;
        best = min(best, value);
      }
      if (best > limit) return limit + 1;
      final swap = before;
      before = previous;
      previous = current;
      current = swap;
    }
    return previous[b.length];
  }

  static int _count(Database db, BrowseQuery q) {
    final (where, args) = _filter(db, q);
    return db.select('SELECT count(*) FROM items i WHERE $where', args).first.columnAt(0) as int;
  }

  static const _itemColumns = 'i.id, i.source_id, i.type, i.name, i.logo, i.country, i.rating, i.extension, c.name';

  /// Programme en cours d'une chaîne, cherché seulement pour les lignes affichées.
  static String _nowColumn(int now) =>
      '(SELECT p.title || char(31) || p.start || char(31) || p.stop FROM epg_links l JOIN epg_programs p ON p.channel = l.channel '
      'WHERE l.item_id = i.id AND p.stop > $now AND p.start <= $now ORDER BY p.stop LIMIT 1)';

  static Item _liveItem(Row r, int now) {
    final base = _item(r);
    final program = r.columnAt(9) as String?;
    if (program == null) return base;
    final parts = program.split('\u001f');
    final start = int.parse(parts[1]), stop = int.parse(parts[2]);
    return Item(
      id: base.id,
      sourceId: base.sourceId,
      type: base.type,
      name: base.name,
      logo: base.logo,
      categoryName: base.categoryName,
      country: base.country,
      rating: base.rating,
      extension: base.extension,
      nowTitle: parts.first,
      nowProgress: stop > start ? (now - start) / (stop - start) : 0,
    );
  }

  static Item _item(Row r) => Item(
        id: r.columnAt(0) as int,
        sourceId: r.columnAt(1) as int,
        type: ItemType.values[r.columnAt(2) as int],
        name: r.columnAt(3) as String,
        logo: r.columnAt(4) as String,
        country: r.columnAt(5) as String,
        rating: r.columnAt(6) as double?,
        extension: r.columnAt(7) as String,
        categoryName: r.columnAt(8) as String,
      );

  static (String, List<Object?>) _order(BrowseQuery q) {
    final query = sortKey(q.text);
    return switch (q.sort) {
      ItemSort.nameAscending => ('i.sort_name, i.id', const []),
      ItemSort.nameDescending => ('i.sort_name DESC, i.id', const []),
      ItemSort.recent => ('i.added_at IS NULL, i.added_at DESC, i.id', const []),
      ItemSort.rating => ('i.rating IS NULL, i.rating DESC, i.sort_name', const []),
      // Pendant une recherche : nom exact, puis début du nom, puis noms courts.
      ItemSort.source when query.isNotEmpty => (
          'CASE WHEN i.sort_name = ? THEN 0 WHEN i.sort_name GLOB ? THEN 1 WHEN i.sort_name GLOB ? THEN 2 ELSE 3 END, length(i.sort_name), i.sort_name',
          [query, '$query*', '*$query*'],
        ),
      ItemSort.source => (q.categoryId != null ? 'i.position' : 'i.source_id, i.position', const []),
    };
  }

  /// Une tranche de la liste.
  Future<List<Item>> page(BrowseQuery q, int offset, int limit) => _reader.run((db) => _page(db, q, offset, limit));

  static List<Item> _page(Database db, BrowseQuery q, int offset, int limit) {
    final (where, args) = _filter(db, q);
    final (order, orderArgs) = _order(q);
    final live = q.type == ItemType.live;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final columns = live ? '$_itemColumns, ${_nowColumn(now)}' : _itemColumns;
    final rows = db.select(
      'SELECT $columns FROM items i CROSS JOIN categories c ON c.id = i.category_id WHERE $where ORDER BY $order LIMIT ? OFFSET ?',
      [...args, ...orderArgs, limit, offset],
    );
    return live ? [for (final r in rows) _liveItem(r, now)] : rows.map(_item).toList();
  }

  /// Programmes d'une chaîne qui recoupent cette période.
  Future<List<Program>> programs(int itemId, DateTime from, DateTime to) => _reader.run((db) => _programs(db, itemId, from, to));

  static List<Program> _programs(Database db, int itemId, DateTime from, DateTime to) {
    final rows = db.select(
      'SELECT p.channel, p.start, p.stop, p.title, p.description, p.epg_id FROM epg_links l JOIN epg_programs p ON p.channel = l.channel '
      'WHERE l.item_id = ? AND p.stop > ? AND p.start < ? ORDER BY p.epg_id, p.start',
      [itemId, from.millisecondsSinceEpoch ~/ 1000, to.millisecondsSinceEpoch ~/ 1000],
    );
    if (rows.isEmpty) return const [];
    // Une même chaîne peut venir de plusieurs guides : on n'en lit qu'un, sinon les horaires se chevauchent.
    final guide = rows.first.columnAt(5);
    return [
      for (final r in rows)
        if (r.columnAt(5) == guide)
          Program(channel: r.columnAt(0) as String, start: r.columnAt(1) as int, stop: r.columnAt(2) as int, title: r.columnAt(3) as String, description: r.columnAt(4) as String),
    ];
  }

  Future<List<EpgSource>> epgSources() => _reader.run(_epgSources);

  static List<EpgSource> _epgSources(Database db) => [
        for (final r in db.select('SELECT id, name, url, path, source_id, refreshed_at, error, programs FROM epg_sources ORDER BY id'))
          EpgSource(
            id: r.columnAt(0) as int,
            name: r.columnAt(1) as String,
            url: r.columnAt(2) as String,
            path: r.columnAt(3) as String,
            sourceId: r.columnAt(4) as int?,
            // En secondes, comme les heures du guide, contrairement aux dates des sources.
            refreshedAt: r.columnAt(5) == null ? null : _date((r.columnAt(5) as int) * 1000),
            error: r.columnAt(6) as String?,
            programs: r.columnAt(7) as int,
          ),
      ];

  /// Ajoute une source de guide : une adresse, ou [path] pour un fichier local.
  Future<int> addEpgSource(String name, String url, {String path = '', int? sourceId}) => _writer.run((db) => _addEpg(db, name, url, path, sourceId));

  static int _addEpg(Database db, String name, String url, String path, int? sourceId) {
    db.execute('INSERT OR IGNORE INTO epg_sources(name, url, path, source_id) VALUES(?,?,?,?)', [name, url, path, sourceId]);
    if (sourceId != null) {
      db.execute('UPDATE epg_sources SET name = ?, url = ? WHERE source_id = ?', [name, url, sourceId]);
      return db.select('SELECT id FROM epg_sources WHERE source_id = ?', [sourceId]).first.columnAt(0) as int;
    }
    return db.lastInsertRowId;
  }

  Future<Map<String, Object?>> exportBackup({required bool secrets}) => _reader.run((db) => readBackup(db, secrets: secrets));

  Future<RestoreReport> restoreBackup(Map<String, dynamic> data) => _writer.run((db) => applyBackup(db, data));

  Future<void> resolvePending() => _writer.run(attachPending);

  Future<List<Download>> downloads() => _reader.run(_downloads);

  static List<Download> _downloads(Database db) => [
        for (final r in db.select('SELECT * FROM downloads ORDER BY id'))
          Download(
            id: r['id'] as int,
            sourceId: r['source_id'] as int,
            type: ItemType.values[r['type'] as int],
            streamKey: r['stream_key'] as String,
            title: r['title'] as String,
            subtitle: r['subtitle'] as String,
            logo: r['logo'] as String,
            extension: r['extension'] as String,
            path: r['path'] as String,
            url: r['url'] as String,
            headers: r['headers'] as String,
            state: DownloadState.values.asNameMap()[r['state']] ?? DownloadState.queued,
            received: r['received'] as int,
            total: r['total'] as int?,
            error: DownloadError.values.asNameMap()[r['error']],
          ),
      ];

  Future<int> addDownload(Download d) => _writer.run((db) => _addDownload(db, d));

  static int _addDownload(Database db, Download d) {
    db.execute(
      'INSERT INTO downloads(source_id, type, stream_key, title, subtitle, logo, extension, path, url, headers, state) VALUES(?,?,?,?,?,?,?,?,?,?,?)',
      [d.sourceId, d.type.index, d.streamKey, d.title, d.subtitle, d.logo, d.extension, d.path, d.url, d.headers, d.state.name],
    );
    return db.lastInsertRowId;
  }

  Future<void> saveDownload(Download d) => _writer.run((db) => _saveDownload(db, d));

  static void _saveDownload(Database db, Download d) => db.execute(
        'UPDATE downloads SET state = ?, received = ?, total = ?, error = ?, path = ? WHERE id = ?',
        [d.state.name, d.received, d.total, d.error?.name, d.path, d.id],
      );

  Future<void> deleteDownload(int id) => _writer.run((db) => _deleteDownload(db, id));

  static void _deleteDownload(Database db, int id) => db.execute('DELETE FROM downloads WHERE id = ?', [id]);

  /// Efface tout ce que l'app a enregistré sur cet appareil.
  Future<void> wipe() => _writer.run(_wipe);

  static void _wipe(Database db) {
    db.execute('BEGIN IMMEDIATE');
    for (final table in const [
      'downloads', 'fav_items', 'fav_lists', 'epg_links', 'epg_programs', 'epg_channels', 'epg_sources', 'restore_pending', 'items', 'categories', 'sources', 'settings',
    ]) {
      db.execute('DELETE FROM $table');
    }
    db.execute('COMMIT');
    db.execute('VACUUM');
    // Sans cela, les anciennes pages restent dans le journal et le fichier garde sa taille.
    db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
  }

  /// Rattache les chaînes au guide, après un changement du catalogue.
  Future<void> relinkGuide() => _writer.run(relinkChannels);

  Future<void> deleteEpgSource(int id) => _writer.run((db) => _deleteEpg(db, id));

  static void _deleteEpg(Database db, int id) {
    db.execute('BEGIN IMMEDIATE');
    db.execute('DELETE FROM epg_programs WHERE epg_id = ?', [id]);
    db.execute('DELETE FROM epg_sources WHERE id = ?', [id]);
    db.execute('COMMIT');
  }

  /// Association manuelle d'une chaîne au guide : les actualisations la respectent.
  Future<void> linkToGuide(int itemId, String channel) => _writer.run((db) => _link(db, itemId, channel));

  static void _link(Database db, int itemId, String channel) =>
      db.execute('INSERT OR REPLACE INTO epg_links(item_id, channel, manual) VALUES(?, ?, 1)', [itemId, channel]);

  /// Chaînes du guide dont l'identifiant ou le nom contient ce texte.
  Future<List<String>> searchGuideChannels(String text) => _reader.run((db) => _searchChannels(db, text));

  static List<String> _searchChannels(Database db, String text) {
    final like = '%${normalizeText(text)}%';
    return [
      for (final r in db.select('SELECT DISTINCT channel FROM epg_channels WHERE channel LIKE ? OR name_key LIKE ? ORDER BY channel LIMIT 40', [like, like]))
        r.columnAt(0) as String,
    ];
  }

  /// Pays et langues présents dans un type de contenu, avec leur nombre d'éléments.
  Future<List<(String, int)>> countries(ItemType type) => _reader.run((db) => _countries(db, type));

  static List<(String, int)> _countries(Database db, ItemType type) => [
        for (final r in db.select(
          "SELECT country, count(*) n FROM items WHERE type = ? AND missing_since IS NULL AND country <> '' "
          'AND source_id IN (SELECT id FROM sources WHERE enabled = 1) GROUP BY country ORDER BY n DESC',
          [type.index],
        ))
          (r.columnAt(0) as String, r.columnAt(1) as int),
      ];

  /// Pour chaque groupe du direct, le pays porté par plus des deux tiers de ses chaînes.
  Future<Map<int, String>> dominantCountries() => _reader.run(_dominantCountries);

  static Map<int, String> _dominantCountries(Database db) {
    final rows = db.select(
      "SELECT category_id, country, count(*) n, (SELECT item_count FROM categories c WHERE c.id = i.category_id) total "
      "FROM items i WHERE type = 0 AND country <> '' AND missing_since IS NULL GROUP BY category_id, country",
    );
    return {
      for (final r in rows)
        if ((r.columnAt(2) as int) * 3 >= (r.columnAt(3) as int? ?? 0) * 2) r.columnAt(0) as int: r.columnAt(1) as String,
    };
  }

  Future<List<FavoriteList>> favoriteLists() => _reader.run(_favoriteLists);

  static List<FavoriteList> _favoriteLists(Database db) => [
        for (final r in db.select(
          'SELECT l.id, l.name, l.icon, (SELECT count(*) FROM fav_items f JOIN items i ON i.id = f.item_id '
          'WHERE f.list_id = l.id AND i.missing_since IS NULL) FROM fav_lists l ORDER BY l.position, l.id',
        ))
          FavoriteList(id: r.columnAt(0) as int, name: r.columnAt(1) as String, icon: r.columnAt(2) as String, itemCount: r.columnAt(3) as int),
      ];

  /// Pour chaque élément en favori, les listes qui le contiennent.
  Future<Map<int, Set<int>>> favoriteMemberships() => _reader.run(_memberships);

  static Map<int, Set<int>> _memberships(Database db) {
    final result = <int, Set<int>>{};
    for (final r in db.select('SELECT item_id, list_id FROM fav_items')) {
      (result[r.columnAt(0) as int] ??= {}).add(r.columnAt(1) as int);
    }
    return result;
  }

  Future<int> createFavoriteList(String name, String icon) => _writer.run((db) => _createList(db, name, icon));

  static int _createList(Database db, String name, String icon) {
    db.execute('INSERT INTO fav_lists(name, icon, position) VALUES(?, ?, (SELECT coalesce(max(position), 0) + 1 FROM fav_lists))', [name, icon]);
    return db.lastInsertRowId;
  }

  Future<void> updateFavoriteList(int id, String name, String icon) => _writer.run((db) => _updateList(db, id, name, icon));

  static void _updateList(Database db, int id, String name, String icon) =>
      db.execute('UPDATE fav_lists SET name = ?, icon = ? WHERE id = ?', [name, icon, id]);

  Future<void> deleteFavoriteList(int id) => _writer.run((db) => _deleteList(db, id));

  static void _deleteList(Database db, int id) {
    db.execute('BEGIN IMMEDIATE');
    db.execute('DELETE FROM fav_items WHERE list_id = ?', [id]);
    db.execute('DELETE FROM fav_lists WHERE id = ?', [id]);
    db.execute('COMMIT');
  }

  Future<void> reorderFavoriteLists(List<int> ids) => _writer.run((db) => _reorderLists(db, ids));

  static void _reorderLists(Database db, List<int> ids) {
    db.execute('BEGIN IMMEDIATE');
    for (final (i, id) in ids.indexed) {
      db.execute('UPDATE fav_lists SET position = ? WHERE id = ?', [i, id]);
    }
    db.execute('COMMIT');
  }

  Future<void> addToFavoriteList(int listId, int itemId) => _writer.run((db) => _addFavorite(db, listId, itemId));

  static void _addFavorite(Database db, int listId, int itemId) => db.execute(
        'INSERT OR IGNORE INTO fav_items(list_id, item_id, position) '
        'VALUES(?1, ?2, (SELECT coalesce(max(position), 0) + 1 FROM fav_items WHERE list_id = ?1))',
        [listId, itemId],
      );

  Future<void> removeFromFavoriteList(int listId, int itemId) => _writer.run((db) => _removeFavorite(db, listId, itemId));

  static void _removeFavorite(Database db, int listId, int itemId) =>
      db.execute('DELETE FROM fav_items WHERE list_id = ? AND item_id = ?', [listId, itemId]);

  /// Les éléments d'une liste, dans l'ordre choisi. Une chaîne disparue de sa source reste
  /// dans la liste mais n'est pas proposée : elle reviendra si la source la rétablit.
  Future<List<Item>> favoriteItems(int listId) => _reader.run((db) => _favoriteItems(db, listId));

  static List<Item> _favoriteItems(Database db, int listId) => db
      .select(
        'SELECT $_itemColumns FROM fav_items f JOIN items i ON i.id = f.item_id JOIN categories c ON c.id = i.category_id '
        'WHERE f.list_id = ? AND i.missing_since IS NULL ORDER BY f.position',
        [listId],
      )
      .map(_item)
      .toList();

  Future<void> reorderFavoriteItems(int listId, List<int> itemIds) => _writer.run((db) => _reorderItems(db, listId, itemIds));

  static void _reorderItems(Database db, int listId, List<int> itemIds) {
    db.execute('BEGIN IMMEDIATE');
    for (final (i, id) in itemIds.indexed) {
      db.execute('UPDATE fav_items SET position = ? WHERE list_id = ? AND item_id = ?', [i, listId, id]);
    }
    db.execute('COMMIT');
  }

  Future<StreamInfo?> streamInfo(int itemId) => _reader.run((db) => _streamInfo(db, itemId));

  static StreamInfo? _streamInfo(Database db, int itemId) {
    final rows = db.select('SELECT type, stable_key, url, extension, http_headers, catchup, catchup_days, catchup_source FROM items WHERE id = ?', [itemId]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return StreamInfo(
      type: ItemType.values[r.columnAt(0) as int],
      stableKey: r.columnAt(1) as String,
      url: r.columnAt(2) as String,
      extension: r.columnAt(3) as String,
      httpHeaders: r.columnAt(4) as String,
      catchup: r.columnAt(5) as String,
      catchupDays: r.columnAt(6) as int,
      catchupSource: r.columnAt(7) as String,
    );
  }

  Future<Map<String, String>> settings() => _reader.run(_settings);

  static Map<String, String> _settings(Database db) => {
        for (final r in db.select("SELECT key, value FROM settings WHERE key NOT LIKE 'filtered.%'")) r.columnAt(0) as String: r.columnAt(1) as String,
      };

  /// Une valeur de grande taille, lue seulement quand on en a besoin (classement FILTERED).
  Future<String?> loadSetting(String key) => _reader.run((db) => _loadSetting(db, key));

  static String? _loadSetting(Database db, String key) {
    final rows = db.select('SELECT value FROM settings WHERE key = ?', [key]);
    return rows.isEmpty ? null : rows.first.columnAt(0) as String;
  }

  Future<void> saveSetting(String key, String value) => _writer.run((db) => _saveSetting(db, key, value));

  static void _saveSetting(Database db, String key, String value) => db.execute(
        'INSERT INTO settings(key, value) VALUES(?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value',
        [key, value],
      );
}
