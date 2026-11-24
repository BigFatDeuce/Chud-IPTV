import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/data/database.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/import/text.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';

const playlist = '''
#EXTM3U
#EXTINF:-1 group-title="FRANCE GENERALE",FR| TF1 HD
http://s.example/live/u/p/1.ts
#EXTINF:-1 group-title="FRANCE GENERALE",FR| France 2
http://s.example/live/u/p/2.ts
#EXTINF:-1 group-title="FRANCE SPORTS",FR| Eurosport 1
http://s.example/live/u/p/3.ts
#EXTINF:-1 group-title="FRANCE SPORTS",FR| Téléfoot
http://s.example/live/u/p/4.ts
#EXTINF:-1 tvg-name="Bayerischer Rundfunk" group-title="GERMANY GENERAL",DE: BR Fernsehen
http://s.example/live/u/p/5.ts
#EXTINF:-1 group-title="UK SPORT",UK: Sky Sports Main Event
http://s.example/live/u/p/6.ts
#EXTINF:-1 group-title="Sans pays",Canal Inconnu
http://s.example/live/u/p/7.ts
#EXTINF:-1 group-title="[FR] FILMS",Le Grand Bain
http://s.example/movie/u/p/8.mkv
''';

void main() {
  late Directory dir;
  late String path;
  late Repository repository;
  late Source source;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('chud_search');
    path = '${dir.path}/test.db';
    repository = await Repository.open(path);
    final id = await repository.addSource(const Source(name: 'P', kind: SourceKind.m3uUrl, url: 'http://p.example/l.m3u'));
    source = (await repository.sources()).firstWhere((s) => s.id == id);
    await runImport(
      ImportRequest(dbPath: path, tempDir: dir.path, source: source),
      MockClient((_) async => http.Response.bytes(utf8.encode(playlist), 200)),
      (_) {},
    );
  });

  tearDown(() async {
    await repository.close();
    await dir.delete(recursive: true);
  });

  Future<List<String>> search(String text, {ItemType type = ItemType.live, String country = '', ItemSort sort = ItemSort.source}) async {
    final items = await repository.page(BrowseQuery(type: type, text: text, country: country, sort: sort), 0, 50);
    return items.map((i) => i.name).toList();
  }

  group('recherche', () {
    test('début de mot, dès les premières lettres', () async {
      expect(await search('tf'), ['FR| TF1 HD']);
      expect(await search('eur'), ['FR| Eurosport 1']);
    });

    test('majuscules et accents ignorés', () async {
      expect(await search('TELEFOOT'), hasLength(1));
      expect(await search('téléfoot'), hasLength(1));
      expect(await search('telefoot'), hasLength(1));
    });

    test('morceau de mot', () async => expect(await search('sport'), containsAll(['FR| Eurosport 1', 'UK: Sky Sports Main Event'])));

    test('tolère les fautes de frappe', () async {
      expect(await search('telefot'), hasLength(1));
      expect(await search('eurosprot'), hasLength(1));
    });

    test('plusieurs mots, dans n\'importe quel ordre', () async {
      expect(await search('event sky'), ['UK: Sky Sports Main Event']);
    });

    test('nom alternatif', () async => expect(await search('bayerischer'), ['DE: BR Fernsehen']));

    test('le nom exact passe devant', () async {
      expect((await search('france')).first, 'FR| France 2');
    });

    test('rien de trouvé', () async => expect(await search('zzzzzz'), isEmpty));

    test('saisie sans mot : toute la liste', () async => expect(await search(' -- '), hasLength(7)));

    test('caractères spéciaux sans danger', () async {
      expect(await search('"'), hasLength(7));
      expect(await search('a"b'), isEmpty);
      expect(await search('foo OR bar'), isEmpty);
    });

    test('le compte suit la recherche', () async {
      expect(await repository.count(const BrowseQuery(type: ItemType.live, text: 'sport')), 2);
    });

    test('limité au type affiché', () async {
      expect(await search('grand'), isEmpty);
      expect(await search('grand', type: ItemType.movie), ['Le Grand Bain']);
    });
  });

  group('filtres et tri', () {
    test('par pays, y compris déduit du groupe', () async {
      expect(await search('', country: 'DE'), ['DE: BR Fernsehen']);
      expect(await search('', type: ItemType.movie, country: 'FR'), ['Le Grand Bain'], reason: 'pays du groupe « [FR] FILMS »');
    });

    test('liste des pays', () async {
      final countries = await repository.countries(ItemType.live);
      expect(countries.first, ('FR', 4));
      expect(countries.map((c) => c.$1), containsAll(['DE', 'GB']));
    });

    test('recherche et filtre se combinent', () async {
      expect(await search('sport', country: 'GB'), ['UK: Sky Sports Main Event']);
    });

    test('par plusieurs groupes à la fois', () async {
      final cats = await repository.categories(ItemType.live, null);
      final ids = cats.where((c) => c.name.startsWith('FRANCE')).map((c) => c.id).toList();
      expect(await repository.count(BrowseQuery(type: ItemType.live, categoryIds: ids)), 4);
    });

    test('tri par nom, sans le préfixe de pays', () async {
      final names = await search('', sort: ItemSort.nameAscending);
      expect(names.first, 'DE: BR Fernsehen');
      expect(names.last, 'FR| TF1 HD');
      expect(await search('', sort: ItemSort.nameDescending), names.reversed);
    });

    test('la clé de tri retire le préfixe', () {
      expect(sortKey('FR| TF1 HD'), 'tf1 hd');
      expect(sortKey('[EN] Some Movie'), 'some movie');
      expect(sortKey('FR-REU| Kolotv'), 'kolotv');
      expect(sortKey('TF1'), 'tf1');
    });
  });

  group('favoris', () {
    Future<int> itemId(String name) async => (await repository.page(BrowseQuery(type: ItemType.live, text: name), 0, 1)).first.id;

    test('une chaîne dans plusieurs listes, sans être dupliquée', () async {
      final sport = await repository.createFavoriteList('Sport', 'sports');
      final news = await repository.createFavoriteList('News', 'news');
      final id = await itemId('telefoot');
      await repository.addToFavoriteList(sport, id);
      await repository.addToFavoriteList(news, id);
      await repository.addToFavoriteList(sport, id);
      expect((await repository.favoriteMemberships())[id], {sport, news});
      expect(await repository.favoriteItems(sport), hasLength(1));
      expect(await repository.count(const BrowseQuery(type: ItemType.live)), 7);
    });

    test('renommer, supprimer et réorganiser les listes', () async {
      final a = await repository.createFavoriteList('A', 'star');
      final b = await repository.createFavoriteList('B', 'star');
      await repository.reorderFavoriteLists([b, a]);
      expect((await repository.favoriteLists()).map((l) => l.name), ['B', 'A']);
      await repository.updateFavoriteList(a, 'Renommée', 'movie');
      expect((await repository.favoriteLists()).last.icon, 'movie');
      await repository.deleteFavoriteList(b);
      expect((await repository.favoriteLists()).map((l) => l.name), ['Renommée']);
    });

    test('réorganiser les chaînes d\'une liste', () async {
      final list = await repository.createFavoriteList('L', 'star');
      final x = await itemId('tf1');
      final y = await itemId('telefoot');
      final z = await itemId('eurosport');
      for (final id in [x, y, z]) {
        await repository.addToFavoriteList(list, id);
      }
      await repository.reorderFavoriteItems(list, [z, x, y]);
      expect((await repository.favoriteItems(list)).map((i) => i.id), [z, x, y]);
    });

    test('retirer d\'une liste ne touche pas aux autres', () async {
      final a = await repository.createFavoriteList('A', 'star');
      final b = await repository.createFavoriteList('B', 'star');
      final id = await itemId('tf1');
      await repository.addToFavoriteList(a, id);
      await repository.addToFavoriteList(b, id);
      await repository.removeFromFavoriteList(a, id);
      expect((await repository.favoriteMemberships())[id], {b});
    });

    test('supprimer une source retire ses favoris', () async {
      final list = await repository.createFavoriteList('L', 'star');
      await repository.addToFavoriteList(list, await itemId('tf1'));
      await repository.deleteSource(source.id);
      expect(await repository.favoriteMemberships(), isEmpty);
    });

    test('survivent à une actualisation, à un renommage et à une disparition temporaire', () async {
      final list = await repository.createFavoriteList('L', 'star');
      final id = await itemId('tf1');
      await repository.addToFavoriteList(list, id);

      Future<void> refresh(String text) => runImport(
            ImportRequest(dbPath: path, tempDir: dir.path, source: source, force: true),
            MockClient((_) async => http.Response(text, 200)),
            (_) {},
          );

      const ascii = '''
#EXTM3U
#EXTINF:-1 group-title="FRANCE GENERALE",FR| TF1 FHD
http://autre.example/live/x/y/1.ts
#EXTINF:-1 group-title="FRANCE GENERALE",FR| France 2
http://s.example/live/u/p/2.ts
''';
      await refresh(ascii);
      expect((await repository.favoriteItems(list)).single.name, 'FR| TF1 FHD');

      await refresh('#EXTM3U\n#EXTINF:-1,Autre\nhttp://s.example/live/u/p/2.ts\n');
      expect(await repository.favoriteItems(list), isEmpty, reason: 'disparue : pas proposée');
      expect((await repository.favoriteMemberships())[id], {list}, reason: 'mais pas oubliée');

      await refresh(ascii);
      expect((await repository.favoriteItems(list)).single.id, id);
    });
  });

  test('la recherche suit les changements du catalogue', () async {
    await runImport(
      ImportRequest(dbPath: path, tempDir: dir.path, source: source, force: true),
      MockClient((_) async => http.Response('#EXTM3U\n#EXTINF:-1,Nouvelle Zygomatique\nhttp://s.example/live/u/p/50.ts\n#EXTINF:-1,TF9\nhttp://s.example/live/u/p/51.ts\n', 200)),
      (_) {},
    );
    expect(await search('zygomatique'), hasLength(1));
    expect(await search('zygomatiqe'), hasLength(1), reason: 'le vocabulaire a été relu');
    expect(await search('telefoot'), isEmpty, reason: 'disparue');
  });

  test('migration : une base v1 garde tout et devient cherchable', () async {
    final file = '${dir.path}/v1.db';
    final db = sqlite3.open(file);
    db.execute(migrations.first);
    db.execute('PRAGMA user_version = 1');
    db.execute("INSERT INTO sources(id, name, kind) VALUES(1, 'Ancienne', 'xtream')");
    db.execute("INSERT INTO categories(id, source_id, type, remote_id, name, position, item_count) VALUES(1, 1, 1, '9', '[FR] FILMS', 0, 1)");
    db.execute(
      'INSERT INTO items(id, source_id, type, category_id, stable_key, fingerprint, position, name, name_norm) '
      "VALUES(5, 1, 1, 1, 'id:5', 1, 0, 'EN| Téléfilm Rare', 'en telefilm rare')",
    );
    db.close();

    final migrated = await Repository.open(file);
    expect((await migrated.sources()).single.name, 'Ancienne');
    final found = await migrated.page(const BrowseQuery(type: ItemType.movie, text: 'telefilm'), 0, 5);
    expect(found.single.id, 5, reason: 'même id : les futures références tiennent');
    expect(found.single.country, 'FR', reason: 'pays déduit du groupe');
    final sorted = await migrated.page(const BrowseQuery(type: ItemType.movie, sort: ItemSort.nameAscending), 0, 5);
    expect(sorted, hasLength(1));
    await migrated.close();

    final check = openDatabase(file);
    expect(check.select('PRAGMA user_version').first.values.first, migrations.length);
    expect(check.select('SELECT sort_name FROM items').single['sort_name'], 'telefilm rare');
    check.close();
  });
}
