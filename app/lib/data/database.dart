import 'package:sqlite3/sqlite3.dart';

import '../filtered/classifier.dart';
import '../import/text.dart';

/// Schéma de la base, une entrée par version. Une version publiée ne change plus jamais : toute
/// évolution s'ajoute à la fin, pour que les données de l'utilisateur survivent aux mises à jour.
const migrations = <String>[
  // Version 1.
  '''
  CREATE TABLE sources(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    kind TEXT NOT NULL,
    url TEXT NOT NULL DEFAULT '',
    username TEXT NOT NULL DEFAULT '',
    password TEXT NOT NULL DEFAULT '',
    enabled INTEGER NOT NULL DEFAULT 1,
    is_default INTEGER NOT NULL DEFAULT 0,
    with_movies INTEGER NOT NULL DEFAULT 1,
    with_series INTEGER NOT NULL DEFAULT 1,
    epg_url TEXT NOT NULL DEFAULT '',
    expires_at INTEGER,
    max_connections INTEGER,
    refreshed_at INTEGER,
    error TEXT,
    error_detail TEXT NOT NULL DEFAULT '',
    error_at INTEGER,
    live_count INTEGER NOT NULL DEFAULT 0,
    movie_count INTEGER NOT NULL DEFAULT 0,
    series_count INTEGER NOT NULL DEFAULT 0
  );

  CREATE TABLE categories(
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL,
    type INTEGER NOT NULL,
    remote_id TEXT NOT NULL,
    name TEXT NOT NULL,
    position INTEGER NOT NULL,
    item_count INTEGER NOT NULL DEFAULT 0,
    hidden INTEGER NOT NULL DEFAULT 0,
    UNIQUE(source_id, type, remote_id)
  );

  -- Un élément garde son id d'une actualisation à l'autre tant qu'on le reconnaît : c'est sur cet
  -- id que s'appuieront favoris et groupes. Disparu de la source, il reste en base avec
  -- missing_since renseigné, et retrouve sa place s'il revient.
  CREATE TABLE items(
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL,
    type INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    stable_key TEXT NOT NULL,
    fingerprint INTEGER NOT NULL,
    position INTEGER NOT NULL,
    name TEXT NOT NULL,
    name_norm TEXT NOT NULL,
    logo TEXT NOT NULL DEFAULT '',
    country TEXT NOT NULL DEFAULT '',
    tvg_id TEXT NOT NULL DEFAULT '',
    tvg_name TEXT NOT NULL DEFAULT '',
    url TEXT NOT NULL DEFAULT '',
    extension TEXT NOT NULL DEFAULT '',
    catchup TEXT NOT NULL DEFAULT '',
    catchup_days INTEGER NOT NULL DEFAULT 0,
    catchup_source TEXT NOT NULL DEFAULT '',
    http_headers TEXT NOT NULL DEFAULT '',
    rating REAL,
    added_at INTEGER,
    missing_since INTEGER,
    UNIQUE(source_id, type, stable_key)
  );
  CREATE INDEX items_list ON items(source_id, type, position) WHERE missing_since IS NULL;
  CREATE INDEX items_category ON items(category_id, position) WHERE missing_since IS NULL;

  CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT NOT NULL) WITHOUT ROWID;
  ''',
  // Version 2 : recherche, tri et favoris multiples.
  '''
  ALTER TABLE items ADD COLUMN sort_name TEXT NOT NULL DEFAULT '';
  CREATE INDEX items_name ON items(type, sort_name) WHERE missing_since IS NULL;
  CREATE INDEX items_country ON items(type, country) WHERE missing_since IS NULL;

  -- Index plein texte, tenu à jour par des déclencheurs. La casse et les accents y sont ignorés.
  CREATE VIRTUAL TABLE items_fts USING fts5(
    name, tvg_name, content='items', content_rowid='id', tokenize='unicode61 remove_diacritics 2', prefix='2 3'
  );
  INSERT INTO items_fts(items_fts) VALUES('rebuild');
  CREATE VIRTUAL TABLE items_vocab USING fts5vocab(items_fts, 'row');
  CREATE TRIGGER items_fts_insert AFTER INSERT ON items BEGIN
    INSERT INTO items_fts(rowid, name, tvg_name) VALUES (new.id, new.name, new.tvg_name);
  END;
  CREATE TRIGGER items_fts_delete AFTER DELETE ON items BEGIN
    INSERT INTO items_fts(items_fts, rowid, name, tvg_name) VALUES ('delete', old.id, old.name, old.tvg_name);
  END;
  CREATE TRIGGER items_fts_update AFTER UPDATE OF name, tvg_name ON items BEGIN
    INSERT INTO items_fts(items_fts, rowid, name, tvg_name) VALUES ('delete', old.id, old.name, old.tvg_name);
    INSERT INTO items_fts(rowid, name, tvg_name) VALUES (new.id, new.name, new.tvg_name);
  END;

  -- Une chaîne peut être dans plusieurs listes : seule l'appartenance est stockée ici.
  CREATE TABLE fav_lists(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    icon TEXT NOT NULL DEFAULT 'star',
    position INTEGER NOT NULL
  );
  CREATE TABLE fav_items(
    list_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    position INTEGER NOT NULL,
    PRIMARY KEY(list_id, item_id)
  ) WITHOUT ROWID;
  CREATE INDEX fav_items_item ON fav_items(item_id);
  ''',
  // Version 3 : guide des programmes.
  '''
  ALTER TABLE sources ADD COLUMN server_offset INTEGER NOT NULL DEFAULT 0;
  CREATE TABLE epg_sources(
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    url TEXT NOT NULL DEFAULT '',
    path TEXT NOT NULL DEFAULT '',
    source_id INTEGER UNIQUE,
    refreshed_at INTEGER,
    error TEXT,
    programs INTEGER NOT NULL DEFAULT 0
  );
  CREATE TABLE epg_programs(
    id INTEGER PRIMARY KEY,
    epg_id INTEGER NOT NULL,
    channel TEXT NOT NULL,
    start INTEGER NOT NULL,
    stop INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT ''
  );
  CREATE INDEX epg_programs_channel ON epg_programs(channel, stop);
  CREATE INDEX epg_programs_source ON epg_programs(epg_id);
  CREATE TABLE epg_channels(channel TEXT NOT NULL, name_key TEXT NOT NULL, PRIMARY KEY(channel, name_key)) WITHOUT ROWID;
  CREATE TABLE epg_links(item_id INTEGER PRIMARY KEY, channel TEXT NOT NULL, manual INTEGER NOT NULL DEFAULT 0);
  -- Favoris et associations d'une sauvegarde, en attente de l'import de leur source.
  CREATE TABLE restore_pending(
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL,
    type INTEGER NOT NULL,
    stable_key TEXT NOT NULL,
    list_id INTEGER,
    position INTEGER NOT NULL DEFAULT 0,
    channel TEXT
  );
  ''',
  // Version 4 : téléchargements. L'adresse d'un compte Xtream n'y est jamais : elle contient le mot de passe.
  '''
  CREATE TABLE downloads(
    id INTEGER PRIMARY KEY,
    source_id INTEGER NOT NULL,
    type INTEGER NOT NULL,
    stream_key TEXT NOT NULL,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL DEFAULT '',
    logo TEXT NOT NULL DEFAULT '',
    extension TEXT NOT NULL DEFAULT '',
    path TEXT NOT NULL,
    url TEXT NOT NULL DEFAULT '',
    headers TEXT NOT NULL DEFAULT '',
    state TEXT NOT NULL,
    received INTEGER NOT NULL DEFAULT 0,
    total INTEGER,
    error TEXT,
    UNIQUE(source_id, type, stream_key)
  );
  ''',
];

/// Étapes qui demandent du code Dart, après le SQL de la version indiquée.
const _afterMigration = <int, void Function(Database)>{2: _fillSortAndCountry};

void _fillSortAndCountry(Database db) {
  db.createFunction(
    functionName: 'chud_sort_key',
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    function: (args) => sortKey(args.first as String),
  );
  db.execute('UPDATE items SET sort_name = chud_sort_key(name)');
  // Un film de « [FR] FILMS » sans préfixe dans son nom est français : le groupe le dit.
  final update = db.prepare("UPDATE items SET country = ? WHERE category_id = ? AND country = ''");
  for (final c in db.select('SELECT id, name FROM categories')) {
    final country = groupCountry(c.columnAt(1) as String);
    if (country.isNotEmpty) update.execute([country, c.columnAt(0)]);
  }
  update.close();
}

/// Ouvre la base et applique les migrations manquantes, chacune dans une transaction.
Database openDatabase(String path) {
  final db = sqlite3.open(path);
  db.execute('PRAGMA journal_mode = WAL');
  db.execute('PRAGMA synchronous = NORMAL');
  // Plusieurs connexions peuvent écrire (import, interface) : la seconde attend au lieu d'échouer.
  db.execute('PRAGMA busy_timeout = 120000');
  migrate(db);
  return db;
}

void migrate(Database db) {
  final current = db.select('PRAGMA user_version').first.values.first as int;
  if (current > migrations.length) {
    db.close();
    throw StateError('Base créée par une version plus récente de l\'app ($current)');
  }
  for (var v = current; v < migrations.length; v++) {
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute(migrations[v]);
      _afterMigration[v + 1]?.call(db);
      db.execute('PRAGMA user_version = ${v + 1}');
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}
