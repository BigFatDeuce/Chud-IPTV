import 'package:sqlite3/sqlite3.dart';

import '../filtered/classifier.dart';
import '../models/catalog.dart';
import '../models/source.dart';
import 'entry.dart';
import 'text.dart';

/// Bilan d'une actualisation pour un type de contenu.
class TypeReport {
  const TypeReport({
    this.total = 0,
    this.added = 0,
    this.updated = 0,
    this.renamed = 0,
    this.relogoed = 0,
    this.restored = 0,
    this.missing = 0,
  });

  final int total;
  final int added;
  final int updated;
  final int renamed;
  final int relogoed;
  final int restored;
  final int missing;
}

/// Ce qu'on sait déjà d'un élément, pour le reconnaître.
class _Known {
  _Known(this.id, this.key, this.name, this.nameNorm, this.logo, this.tvgId, this.categoryId, this.fingerprint, this.position, this.missing);

  final int id;
  final String key;
  final String name;
  final String nameNorm;
  final String logo;
  final String tvgId;
  final int categoryId;
  final int fingerprint;
  final int position;
  final bool missing;
  bool taken = false;
}

/// Rapproche les éléments reçus d'un type de ceux en base, à l'intérieur de la transaction de
/// l'import. Reconnaître un élément lui fait garder son id, donc ses favoris et ses groupes :
/// d'abord par sa clé stable, puis par son tvg-id, enfin par son nom dans la même catégorie.
class TypeSync {
  TypeSync(this._db, this.sourceId, this.type, this.now) {
    final known = _db.prepare(
      'SELECT id, stable_key, name, name_norm, logo, tvg_id, category_id, fingerprint, position, missing_since '
      'FROM items WHERE source_id = ? AND type = ?',
    );
    final rows = known.selectCursor([sourceId, type.index]);
    while (rows.moveNext()) {
      final r = rows.current;
      final entry = _Known(r.columnAt(0) as int, r.columnAt(1) as String, r.columnAt(2) as String, r.columnAt(3) as String,
          r.columnAt(4) as String, r.columnAt(5) as String, r.columnAt(6) as int, r.columnAt(7) as int, r.columnAt(8) as int,
          r.columnAt(9) != null);
      _byKey[entry.key] = entry;
      if (!entry.missing) _activeBefore++;
    }
    known.close();
    final categories = _db.select(
      'SELECT id, remote_id, name, position FROM categories WHERE source_id = ? AND type = ?',
      [sourceId, type.index],
    );
    for (final c in categories) {
      _categories[c.columnAt(1) as String] = c.columnAt(0) as int;
      _categoryNames[c.columnAt(0) as int] = c.columnAt(2) as String;
      if ((c.columnAt(3) as int) >= _nextCategoryPosition) _nextCategoryPosition = (c.columnAt(3) as int) + 1;
    }
    _insert = _db.prepare(
      'INSERT INTO items(source_id, type, category_id, stable_key, fingerprint, position, name, name_norm, logo, country, '
      'tvg_id, tvg_name, url, extension, catchup, catchup_days, catchup_source, http_headers, rating, added_at, sort_name) '
      'VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    );
    _update = _db.prepare(
      'UPDATE items SET category_id=?, stable_key=?, fingerprint=?, position=?, name=?, name_norm=?, logo=?, country=?, '
      'tvg_id=?, tvg_name=?, url=?, extension=?, catchup=?, catchup_days=?, catchup_source=?, http_headers=?, rating=?, '
      'added_at=?, sort_name=?, missing_since=NULL WHERE id=?',
    );
    _move = _db.prepare('UPDATE items SET position=? WHERE id=?');
    _insertCategory = _db.prepare('INSERT INTO categories(source_id, type, remote_id, name, position) VALUES(?,?,?,?,?)');
    _renameCategory = _db.prepare('UPDATE categories SET name=?, position=? WHERE id=?');
  }

  final Database _db;
  final int sourceId;
  final ItemType type;
  final int now;

  final _byKey = <String, _Known>{};
  final _categories = <String, int>{};
  final _categoryNames = <int, String>{};
  final _categoryCountry = <int, String>{};
  final _seenKeys = <String, int>{};
  final _pending = <ImportEntry>[];
  var _nextCategoryPosition = 0;
  var _activeBefore = 0;
  var _position = 0;
  var _added = 0, _updated = 0, _renamed = 0, _relogoed = 0, _restored = 0;

  late final PreparedStatement _insert, _update, _move, _insertCategory, _renameCategory;

  /// Déclare une catégorie annoncée par la source, dans l'ordre de la source.
  void declareCategory(String remoteId, String name) => _category(remoteId, name, reposition: true);

  int _category(String remoteId, String? name, {bool reposition = false}) {
    final existing = _categories[remoteId];
    if (existing != null) {
      if (name != null && (reposition || name != _categoryNames[existing])) {
        _renameCategory.execute([name, _nextCategoryPosition++, existing]);
        _categoryNames[existing] = name;
      }
      return existing;
    }
    _insertCategory.execute([sourceId, type.index, remoteId, name ?? '', _nextCategoryPosition++]);
    final id = _db.lastInsertRowId;
    _categories[remoteId] = id;
    _categoryNames[id] = name ?? '';
    return id;
  }

  void add(ImportEntry entry) {
    final position = _position++;
    // Deux lignes identiques dans une playlist : chacune garde sa place avec une clé propre.
    final seen = _seenKeys.update(entry.key, (n) => n + 1, ifAbsent: () => 1);
    final key = seen == 1 ? entry.key : '${entry.key}#$seen';
    final known = _byKey[key];
    if (known == null || known.taken) {
      _pending.add(entry);
      _pendingKeys.add((key, position));
      return;
    }
    known.taken = true;
    _write(known, entry, key, position);
  }

  final _pendingKeys = <(String, int)>[];

  void _write(_Known? known, ImportEntry e, String key, int position) {
    final category = _category(e.categoryRemote, e.categoryName);
    final fingerprint = e.fingerprintValue;
    // Sans pays dans son nom, l'élément prend celui de son groupe.
    final country = e.country.isNotEmpty ? e.country : _categoryCountry.putIfAbsent(category, () => groupCountry(_categoryNames[category] ?? ''));
    if (known == null) {
      _insert.execute([
        sourceId, type.index, category, key, fingerprint, position, e.name, e.nameNorm, e.logo, country,
        e.tvgId, e.tvgName, e.url, e.extension, e.catchup, e.catchupDays, e.catchupSource, e.httpHeaders, e.rating, e.addedAt,
        sortKey(e.name),
      ]);
      _added++;
      return;
    }
    if (known.missing) _restored++;
    final same = known.fingerprint == fingerprint && known.key == key && known.categoryId == category && !known.missing;
    if (same) {
      if (known.position != position) _move.execute([position, known.id]);
      return;
    }
    if (known.name != e.name) _renamed++;
    if (known.logo != e.logo) _relogoed++;
    _updated++;
    _update.execute([
      category, key, fingerprint, position, e.name, e.nameNorm, e.logo, country, e.tvgId, e.tvgName, e.url,
      e.extension, e.catchup, e.catchupDays, e.catchupSource, e.httpHeaders, e.rating, e.addedAt, sortKey(e.name), known.id,
    ]);
  }

  /// Libère les requêtes préparées, y compris après un échec : sans cela, la connexion SQLite
  /// resterait ouverte et garderait le fichier verrouillé.
  void close() {
    for (final s in [_insert, _update, _move, _insertCategory, _renameCategory]) {
      s.close();
    }
  }

  /// Tente de reconnaître les éléments dont la clé a changé, puis insère les vraiment nouveaux,
  /// marque les disparus et vérifie que le résultat est plausible.
  TypeReport finish({required bool force}) {
    final remaining = _byKey.values.where((k) => !k.taken);
    final byTvgId = <String, List<_Known>>{};
    final byName = <String, List<_Known>>{};
    for (final k in remaining) {
      if (k.tvgId.isNotEmpty) (byTvgId[k.tvgId] ??= []).add(k);
      (byName['${k.categoryId}|${k.nameNorm}'] ??= []).add(k);
    }
    _Known? claim(List<_Known>? list) {
      if (list == null) return null;
      for (final k in list) {
        if (!k.taken) return k..taken = true;
      }
      return null;
    }

    for (var i = 0; i < _pending.length; i++) {
      final e = _pending[i];
      final (key, position) = _pendingKeys[i];
      final category = _categories[e.categoryRemote];
      final known = (e.tvgId.isEmpty ? null : claim(byTvgId[e.tvgId])) ?? claim(byName['$category|${e.nameNorm}']);
      _write(known, e, key, position);
    }

    final total = _position;
    if (_activeBefore > 0) {
      if (total == 0 && !force) throw ImportFailure(ImportError.empty, '$_activeBefore → 0');
      if (_activeBefore >= 50 && total < _activeBefore / 2 && !force) {
        throw ImportFailure(ImportError.suspicious, '$_activeBefore → $total');
      }
    }

    var missing = 0;
    final markMissing = _db.prepare('UPDATE items SET missing_since=? WHERE id=?');
    for (final k in remaining) {
      if (k.taken || k.missing) continue;
      markMissing.execute([now, k.id]);
      missing++;
    }
    markMissing.close();

    // Catégorie vide : retirée, sauf si l'utilisateur l'a masquée (son choix doit survivre).
    _db.execute(
      'UPDATE categories SET item_count = (SELECT count(*) FROM items i WHERE i.category_id = categories.id AND i.missing_since IS NULL) '
      'WHERE source_id = ? AND type = ?',
      [sourceId, type.index],
    );
    _db.execute(
      'DELETE FROM categories WHERE source_id = ? AND type = ? AND item_count = 0 AND hidden = 0 '
      'AND id NOT IN (SELECT DISTINCT category_id FROM items WHERE source_id = ? AND type = ?)',
      [sourceId, type.index, sourceId, type.index],
    );
    return TypeReport(
      total: total,
      added: _added,
      updated: _updated,
      renamed: _renamed,
      relogoed: _relogoed,
      restored: _restored,
      missing: missing,
    );
  }
}
