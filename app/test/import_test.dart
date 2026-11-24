import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/data/database.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/import/entry.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';

/// Faux fournisseur Xtream : le test modifie ces listes entre deux actualisations.
class FakeServer {
  var account = <String, Object?>{'auth': 1, 'status': 'Active', 'exp_date': '1818925334', 'max_connections': '2'};
  var live = <Map<String, Object?>>[
    {'name': 'FR| TF1', 'stream_id': 1, 'stream_icon': 'http://l/1.png', 'category_id': '10', 'epg_channel_id': 'tf1.fr'},
    {'name': 'FR| France 2', 'stream_id': 2, 'stream_icon': '', 'category_id': '10', 'epg_channel_id': null},
    {'name': 'UK: BBC One', 'stream_id': 3, 'stream_icon': '', 'category_id': '20', 'tv_archive': 1, 'tv_archive_duration': '3'},
  ];
  var movies = <Map<String, Object?>>[
    {'name': 'Film A', 'stream_id': 100, 'stream_icon': '', 'category_id': '30', 'rating': '7', 'container_extension': 'mp4'},
  ];
  var series = <Map<String, Object?>>[
    {'name': 'Série A', 'series_id': 200, 'cover': '', 'category_id': '40'},
  ];
  final calls = <String>[];
  http.Response? Function(String action)? override;

  http.Client get client => MockClient((request) async {
        final action = request.url.queryParameters['action'] ?? 'auth';
        calls.add(action);
        final custom = override?.call(action);
        if (custom != null) return custom;
        final Object body = switch (action) {
          'auth' => {'user_info': account},
          'get_live_categories' => [
              {'category_id': '10', 'category_name': 'France'},
              {'category_id': '20', 'category_name': 'UK'},
            ],
          'get_vod_categories' => [
              {'category_id': '30', 'category_name': 'Films'},
            ],
          'get_series_categories' => [
              {'category_id': '40', 'category_name': 'Séries'},
            ],
          'get_live_streams' => live,
          'get_vod_streams' => movies,
          'get_series' => series,
          _ => throw StateError(action),
        };
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      });
}

void main() {
  late Directory dir;
  late String path;
  late Repository repository;
  late FakeServer server;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chud_test');
    path = '${dir.path}/test.db';
    repository = await Repository.open(path);
    server = FakeServer();
  });

  tearDown(() async {
    await repository.close();
    await dir.delete(recursive: true);
  });

  Future<Source> addXtream({bool movies = true, bool series = true}) async {
    final id = await repository.addSource(Source(
      name: 'Test',
      kind: SourceKind.xtream,
      url: 'http://x.example',
      username: 'user',
      password: 'secret',
      withMovies: movies,
      withSeries: series,
    ));
    return (await repository.sources()).firstWhere((s) => s.id == id);
  }

  Future<ImportReport> run(Source source, {bool force = false, http.Client? client, String? copy}) => runImport(
        ImportRequest(dbPath: path, tempDir: dir.path, source: source, force: force, playlistCopy: copy),
        client ?? server.client,
        (_) {},
      );

  Future<Map<String, int>> idsByName(ItemType type) async {
    final items = await repository.page(BrowseQuery(type: type), 0, 1000);
    return {for (final i in items) i.name: i.id};
  }

  T query<T>(T Function(Database) f) {
    final db = openDatabase(path);
    try {
      return f(db);
    } finally {
      db.close();
    }
  }

  test('premier import : tout est là, avec catégories et compteurs', () async {
    final source = await addXtream();
    final report = await run(source);
    expect(report.live.added, 3);
    expect(report.movies.added, 1);
    expect(report.series.added, 1);

    final s = (await repository.sources()).single;
    expect((s.liveCount, s.movieCount, s.seriesCount), (3, 1, 1));
    expect(s.refreshedAt, isNotNull);
    expect(s.maxConnections, 2);
    expect(s.expiresAt, isNotNull);

    final cats = await repository.categories(ItemType.live, null);
    expect(cats.map((c) => (c.name, c.itemCount)), [('France', 2), ('UK', 1)]);
    final items = await repository.page(const BrowseQuery(type: ItemType.live), 0, 10);
    expect(items.map((i) => i.name), ['FR| TF1', 'FR| France 2', 'UK: BBC One']);
    expect(items.first.categoryName, 'France');
    expect(items.first.country, 'FR');
  });

  test('actualiser sans changement n\'écrit rien et garde les ids', () async {
    final source = await addXtream();
    await run(source);
    final before = await idsByName(ItemType.live);
    final report = await run(source);
    expect(report.live.added, 0);
    expect(report.live.updated, 0);
    expect(report.live.missing, 0);
    expect(await idsByName(ItemType.live), before);
  });

  test('un changement de position ne change pas l\'id', () async {
    final source = await addXtream();
    await run(source);
    final before = await idsByName(ItemType.live);
    server.live = server.live.reversed.toList();
    final report = await run(source);
    expect(report.live.updated, 0);
    expect(await idsByName(ItemType.live), before);
    final items = await repository.page(const BrowseQuery(type: ItemType.live), 0, 10);
    expect(items.first.name, 'UK: BBC One');
  });

  test('renommage et nouveau logo : même id, détectés', () async {
    final source = await addXtream();
    await run(source);
    final before = await idsByName(ItemType.live);
    server.live[0] = {...server.live[0], 'name': 'FR| TF1 HD', 'stream_icon': 'http://l/new.png'};
    final report = await run(source);
    expect(report.live.renamed, 1);
    expect(report.live.relogoed, 1);
    expect((await idsByName(ItemType.live))['FR| TF1 HD'], before['FR| TF1']);
  });

  test('identifiant changé par le fournisseur : retrouvé par son tvg-id', () async {
    final source = await addXtream();
    await run(source);
    final before = await idsByName(ItemType.live);
    server.live[0] = {...server.live[0], 'stream_id': 999, 'name': 'FR| TF1 Nouvelle'};
    final report = await run(source);
    expect(report.live.added, 0);
    expect(report.live.missing, 0);
    expect((await idsByName(ItemType.live))['FR| TF1 Nouvelle'], before['FR| TF1']);
  });

  test('identifiant changé, sans tvg-id : retrouvé par son nom dans la catégorie', () async {
    final source = await addXtream();
    await run(source);
    final before = await idsByName(ItemType.live);
    server.live[1] = {...server.live[1], 'stream_id': 888};
    final report = await run(source);
    expect(report.live.added, 0);
    expect((await idsByName(ItemType.live))['FR| France 2'], before['FR| France 2']);
  });

  test('deux chaînes de même nom restent distinctes', () async {
    server.live = [
      {'name': 'Sport', 'stream_id': 1, 'category_id': '10'},
      {'name': 'Sport', 'stream_id': 2, 'category_id': '10'},
    ];
    final source = await addXtream();
    await run(source);
    final items = await repository.page(const BrowseQuery(type: ItemType.live), 0, 10);
    expect(items.map((i) => i.id).toSet(), hasLength(2));
  });

  test('chaîne disparue : masquée, puis retrouvée avec le même id', () async {
    final source = await addXtream();
    await run(source);
    final before = await idsByName(ItemType.live);
    final removed = server.live.removeLast();

    final gone = await run(source);
    expect(gone.live.missing, 1);
    expect(await repository.count(const BrowseQuery(type: ItemType.live)), 2);
    expect(query((db) => db.select('SELECT count(*) c FROM items WHERE type = 0').first['c']), 3);

    server.live.add(removed);
    final back = await run(source);
    expect(back.live.restored, 1);
    expect(back.live.added, 0);
    expect((await idsByName(ItemType.live))['UK: BBC One'], before['UK: BBC One']);
  });

  test('catégorie masquée conservée même vidée', () async {
    final source = await addXtream();
    await run(source);
    query((db) => db.execute("UPDATE categories SET hidden = 1 WHERE name = 'UK'"));
    server.live.removeLast();
    await run(source);
    expect(query((db) => db.select("SELECT count(*) c FROM categories WHERE name = 'UK'").first['c']), 1);
  });

  group('une panne ne touche pas au catalogue', () {
    Future<void> expectUnchanged(Source source, ImportError kind) async {
      final before = await idsByName(ItemType.live);
      await expectLater(run(source), throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', kind)));
      expect(await idsByName(ItemType.live), before);
      final s = (await repository.sources()).single;
      expect(s.error, kind);
      expect(s.errorAt, isNotNull);
      expect(s.liveCount, 3);
    }

    test('mauvais identifiants', () async {
      final source = await addXtream();
      await run(source);
      server.account = {'auth': 0};
      await expectUnchanged(source, ImportError.credentials);
    });

    test('abonnement expiré', () async {
      final source = await addXtream();
      await run(source);
      server.account = {'auth': 1, 'status': 'Expired'};
      await expectUnchanged(source, ImportError.expired);
    });

    test('erreur serveur sur les films, après le direct', () async {
      final source = await addXtream();
      await run(source);
      server.live.add({'name': 'Nouvelle', 'stream_id': 50, 'category_id': '10'});
      server.override = (a) => a == 'get_vod_streams' ? http.Response('oups', 500) : null;
      await expectUnchanged(source, ImportError.network);
    });

    test('réponse tronquée', () async {
      final source = await addXtream();
      await run(source);
      server.override = (a) => a == 'get_series' ? http.Response('[{"name":"Série A","series_id":200', 200) : null;
      await expectUnchanged(source, ImportError.invalidData);
    });

    test('réseau coupé', () async {
      final source = await addXtream();
      await run(source);
      final broken = MockClient((_) async => throw const SocketException('coupé'));
      final before = await idsByName(ItemType.live);
      await expectLater(run(source, client: broken), throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.network)));
      expect(await idsByName(ItemType.live), before);
    });

    test('l\'erreur disparaît à la réussite suivante', () async {
      final source = await addXtream();
      await run(source);
      server.account = {'auth': 0};
      await expectLater(run(source), throwsA(isA<ImportFailure>()));
      server.account = {'auth': 1, 'status': 'Active'};
      await run(source);
      expect((await repository.sources()).single.error, isNull);
    });
  });

  group('liste suspecte', () {
    setUp(() {
      server.live = [
        for (var i = 0; i < 100; i++) {'name': 'Chaîne $i', 'stream_id': i, 'category_id': '10'},
      ];
    });

    test('liste vide refusée', () async {
      final source = await addXtream();
      await run(source);
      server.live = [];
      await expectLater(run(source), throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.empty)));
      expect(await repository.count(const BrowseQuery(type: ItemType.live)), 100);
    });

    test('chute de plus de moitié refusée, puis acceptée à la demande', () async {
      final source = await addXtream();
      await run(source);
      server.live = server.live.sublist(0, 20);
      await expectLater(
        run(source),
        throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.suspicious).having((e) => e.detail, 'detail', '100 → 20')),
      );
      expect(await repository.count(const BrowseQuery(type: ItemType.live)), 100);

      final report = await run(source, force: true);
      expect(report.live.missing, 80);
      expect(await repository.count(const BrowseQuery(type: ItemType.live)), 20);
    });

    test('baisse normale acceptée', () async {
      final source = await addXtream();
      await run(source);
      server.live = server.live.sublist(0, 80);
      expect((await run(source)).live.missing, 20);
    });
  });

  test('sans films ni séries : rien de téléchargé', () async {
    final source = await addXtream(movies: false, series: false);
    final report = await run(source);
    expect(report.live.total, 3);
    expect(server.calls, ['auth', 'get_live_categories', 'get_live_streams']);
    expect(await repository.count(const BrowseQuery(type: ItemType.movie)), 0);
  });

  test('désactiver films libère la base, les remettre les réimporte', () async {
    final source = await addXtream();
    await run(source);
    final current = (await repository.sources()).single;
    await repository.updateSource(current.copyWith(withMovies: false));
    expect(await repository.count(const BrowseQuery(type: ItemType.movie)), 0);
    expect(await repository.categories(ItemType.movie, null), isEmpty);
    expect(await repository.count(const BrowseQuery(type: ItemType.series)), 1);
    expect((await repository.sources()).single.movieCount, 0);

    final on = (await repository.sources()).single.copyWith(withMovies: true);
    await repository.updateSource(on);
    await run(on);
    expect(await repository.count(const BrowseQuery(type: ItemType.movie)), 1);
  });

  group('playlist', () {
    const playlist = '''
#EXTM3U x-tvg-url="http://e.example/epg.xml"
#EXTINF:-1 tvg-id="tf1" group-title="France",TF1
http://s.example/live/u/p/1.ts
#EXTINF:-1 tvg-id="" group-title="France",France 2
http://s.example/live/u/p/2.ts
#EXTINF:-1 group-title="Cinéma",Film
http://s.example/movie/u/p/3.mkv
''';

    Future<Source> addM3u({bool movies = true}) async {
      final id = await repository.addSource(Source(name: 'P', kind: SourceKind.m3uUrl, url: 'http://p.example/list.m3u', withMovies: movies));
      return (await repository.sources()).firstWhere((s) => s.id == id);
    }

    http.Client client(String text) => MockClient((_) async => http.Response.bytes(utf8.encode(text), 200));

    test('import et guide annoncé', () async {
      final source = await addM3u();
      final report = await run(source, client: client(playlist));
      expect(report.live.total, 2);
      expect(report.movies.total, 1);
      expect((await repository.sources()).single.epgUrl, 'http://e.example/epg.xml');
    });

    test('films désactivés : ignorés à l\'import', () async {
      final source = await addM3u(movies: false);
      final report = await run(source, client: client(playlist));
      expect(report.live.total, 2);
      expect(report.movies.total, 0);
    });

    test('nouvel hôte et nouveaux identifiants : mêmes ids', () async {
      final source = await addM3u();
      await run(source, client: client(playlist));
      final before = await idsByName(ItemType.live);
      final moved = playlist.replaceAll('s.example', 'autre.example').replaceAll('/u/p/', '/alice/pw/');
      final report = await run(source, client: client(moved));
      expect(report.live.added, 0);
      expect(await idsByName(ItemType.live), before);
    });

    test('lignes dupliquées gardées séparément', () async {
      const dup = '#EXTM3U\n#EXTINF:-1,A\nhttp://s.example/a.m3u8\n#EXTINF:-1,A bis\nhttp://s.example/a.m3u8\n';
      final source = await addM3u();
      final report = await run(source, client: client(dup));
      expect(report.live.added, 2);
      final again = await run(source, client: client(dup));
      expect(again.live.added, 0);
    });

    test('page HTML : refusée, catalogue conservé', () async {
      final source = await addM3u();
      await run(source, client: client(playlist));
      await expectLater(
        run(source, client: client('<html>503</html>')),
        throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.notPlaylist)),
      );
      expect(await repository.count(const BrowseQuery(type: ItemType.live)), 2);
    });

    test('fichier local, puis repli sur la copie gardée', () async {
      final file = File('${dir.path}/ma liste.m3u')..writeAsStringSync(playlist);
      final copy = File('${dir.path}/copie.m3u')..writeAsStringSync(playlist);
      final id = await repository.addSource(Source(name: 'F', kind: SourceKind.m3uFile, url: file.path));
      final source = (await repository.sources()).firstWhere((s) => s.id == id);
      await run(source, copy: copy.path);
      file.deleteSync();
      final report = await run(source, copy: copy.path);
      expect(report.live.total, 2);
      copy.deleteSync();
      await expectLater(run(source, copy: copy.path), throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.fileMissing)));
    });
  });

  test('plusieurs sources : indépendantes, chacune ses ids', () async {
    final a = await addXtream();
    await run(a);
    final b = await addXtream();
    await run(b);
    expect((await repository.sources()).first.isDefault, isTrue);
    expect(await repository.count(const BrowseQuery(type: ItemType.live)), 6);
    expect(await repository.count(BrowseQuery(type: ItemType.live, sourceId: a.id)), 3);

    await repository.deleteSource(a.id);
    final left = await repository.sources();
    expect(left.single.id, b.id);
    expect(left.single.isDefault, isTrue, reason: 'la source par défaut est remplacée');
    expect(await repository.count(const BrowseQuery(type: ItemType.live)), 3);
  });

  test('une source désactivée sort des listes', () async {
    final source = await addXtream();
    await run(source);
    final s = (await repository.sources()).single;
    await repository.updateSource(s.copyWith(enabled: false));
    expect(await repository.count(const BrowseQuery(type: ItemType.live)), 0);
    expect(await repository.categories(ItemType.live, null), isEmpty);
  });

  test('import dans son isolat, avec un vrai serveur local', () async {
    final source = await addXtream(movies: false, series: false);
    final local = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    local.listen((r) {
      r.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(switch (r.uri.queryParameters['action']) {
          null => {'user_info': server.account},
          'get_live_streams' => server.live,
          _ => [],
        }));
      r.response.close();
    });
    await repository.updateSource(source.copyWith(url: 'http://127.0.0.1:${local.port}'));
    final updated = (await repository.sources()).single;
    final stages = <ImportStage>[];
    final report = await importInIsolate(ImportRequest(dbPath: path, tempDir: dir.path, source: updated), (p) => stages.add(p.stage));
    await local.close(force: true);
    expect(report.live.total, 3);
    expect(stages, containsAllInOrder([ImportStage.connecting, ImportStage.downloadingLive, ImportStage.writing]));
  });

  test('l\'isolat renvoie l\'échec', () async {
    final source = await addXtream();
    final broken = source.copyWith(url: 'http://127.0.0.1:1');
    await expectLater(
      importInIsolate(ImportRequest(dbPath: path, tempDir: dir.path, source: broken), (_) {}),
      throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.network)),
    );
  });

  test('migrations : une base existante garde ses données', () {
    final file = '${dir.path}/old.db';
    final db = sqlite3.open(file);
    db.execute(migrations.first);
    db.execute('PRAGMA user_version = 1');
    db.execute("INSERT INTO sources(name, kind) VALUES('Ancienne', 'xtream')");
    db.close();
    final again = openDatabase(file);
    expect(again.select('PRAGMA user_version').first.values.first, migrations.length);
    expect(again.select('SELECT name FROM sources').single['name'], 'Ancienne');
    again.close();
  });

  test('base d\'une version plus récente refusée', () {
    final file = '${dir.path}/new.db';
    final db = sqlite3.open(file);
    db.execute('PRAGMA user_version = 999');
    db.close();
    expect(() => openDatabase(file), throwsStateError);
  });
}
