// Key derivation is deliberately slow (PBKDF2, 600,000 rounds): on a busy machine running the whole
// suite in parallel, the default 30 s timeout is not enough.
@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/backup/backup.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _playlist = '#EXTM3U\n#EXTINF:-1 tvg-id="a",Chaîne A\nhttp://s/live/1.ts\n#EXTINF:-1 tvg-id="b",Chaîne B\nhttp://s/live/2.ts\n';
const _xtream = Source(name: 'Compte', kind: SourceKind.xtream, url: 'http://x.example', username: 'moi', password: 'super-secret');
const _list = Source(name: 'Liste', kind: SourceKind.m3uUrl, url: 'http://p.example/get.php?username=moi&password=autre-secret');

void main() {
  late Directory dir;
  var counter = 0;

  setUp(() async => dir = await Directory.systemTemp.createTemp('chud_backup'));
  tearDown(() => dir.delete(recursive: true));

  final paths = <Repository, String>{};
  Future<Repository> open() async {
    final path = '${dir.path}/${counter++}.db';
    final repository = await Repository.open(path);
    paths[repository] = path;
    return repository;
  }

  Future<void> import(Repository repository, int id) async {
    final source = (await repository.sources()).firstWhere((s) => s.id == id);
    await runImport(ImportRequest(dbPath: paths[repository]!, tempDir: dir.path, source: source), MockClient((_) async => http.Response.bytes(utf8.encode(_playlist), 200)), (_) {});
    await repository.resolvePending();
  }

  /// Une source importée, une liste de favoris avec une chaîne.
  Future<Repository> filled() async {
    final repository = await open();
    final id = await repository.addSource(_list);
    await import(repository, id);
    final list = await repository.createFavoriteList('Sport', 'sports');
    final item = (await repository.page(const BrowseQuery(type: ItemType.live, text: 'chaine b'), 0, 1)).first;
    await repository.addToFavoriteList(list, item.id);
    await repository.saveSetting('theme', 'light');
    await repository.saveSetting('player.external', 'C:/vlc.exe');
    await repository.saveSetting('filtered.edits', '{"x":1}');
    await repository.linkToGuide(item.id, 'chaine.b');
    return repository;
  }

  test('sans chiffrement, aucun secret ne sort', () async {
    final repository = await open();
    await repository.addSource(_xtream);
    await repository.addSource(_list);
    await repository.addEpgSource('Manuel', 'http://e.example/g.xml?token=guide-secret');
    final text = await encodeBackup(await repository.exportBackup(secrets: false), '1.0');
    expect(text, isNot(contains('super-secret')));
    expect(text, isNot(contains('autre-secret')));
    expect(text, isNot(contains('guide-secret')));
    expect(text, contains('chud-iptv-backup'));
    await repository.close();
  });

  test('chiffré : illisible sans la phrase, complet avec', () async {
    final repository = await open();
    await repository.addSource(_xtream);
    final text = await encodeBackup(await repository.exportBackup(secrets: true), '1.0', passphrase: 'une phrase longue');
    expect(text, isNot(contains('super-secret')));
    expect(text, isNot(contains('moi')));
    final header = readHeader(text);
    expect(header.encrypted, isTrue);
    expect(header.sources, 1);
    final data = await decodeBackup(text, passphrase: 'une phrase longue');
    expect(((data['sources'] as List).first as Map)['password'], 'super-secret');
    await repository.close();
  });

  test('mauvaise phrase, fichier modifié, autre fichier, version future', () async {
    final text = await encodeBackup({'sources': [], 'lists': [], 'favorites': []}, '1.0', passphrase: 'une phrase longue');
    await expectLater(decodeBackup(text, passphrase: 'autre phrase'), throwsA(isA<BackupFailure>().having((e) => e.error, 'error', BackupError.wrongPassphrase)));
    final json = jsonDecode(text) as Map<String, dynamic>;
    final bytes = base64.decode(json['data'] as String)..[0] ^= 1;
    await expectLater(
      decodeBackup(jsonEncode({...json, 'data': base64.encode(bytes)}), passphrase: 'une phrase longue'),
      throwsA(isA<BackupFailure>().having((e) => e.error, 'error', BackupError.wrongPassphrase)),
    );
    expect(() => readHeader('{"a":1}'), throwsA(isA<BackupFailure>().having((e) => e.error, 'error', BackupError.notBackup)));
    expect(() => readHeader('pas du json'), throwsA(isA<BackupFailure>().having((e) => e.error, 'error', BackupError.notBackup)));
    expect(
      () => readHeader(jsonEncode({...json, 'version': backupVersion + 1})),
      throwsA(isA<BackupFailure>().having((e) => e.error, 'error', BackupError.tooNew)),
    );
  });

  test('restauration sur une app vierge : les favoris attendent leur import', () async {
    final first = await filled();
    final text = await encodeBackup(await first.exportBackup(secrets: true), '1.0', passphrase: 'une phrase longue');
    await first.close();

    final second = await open();
    final report = await second.restoreBackup(await decodeBackup(text, passphrase: 'une phrase longue'));
    expect(report.incomplete, 0);
    expect(report.toRefresh, hasLength(1));
    expect(await second.loadSetting('theme'), 'light');
    expect(await second.loadSetting('filtered.edits'), '{"x":1}');
    expect(await second.loadSetting('player.external'), isNull, reason: 'chemin propre à une machine');
    final sport = (await second.favoriteLists()).firstWhere((l) => l.name == 'Sport');
    expect(sport.itemCount, 0);

    await import(second, report.toRefresh.single);
    final items = await second.favoriteItems(sport.id);
    expect(items.map((i) => i.name), ['Chaîne B']);
    await second.close();
  });

  test('sans secrets : la source revient à compléter, sans être lancée', () async {
    final first = await open();
    await first.addSource(_xtream);
    final data = jsonDecode(await encodeBackup(await first.exportBackup(secrets: false), '1.0')) as Map<String, dynamic>;
    await first.close();

    final second = await open();
    final report = await second.restoreBackup(data['data'] as Map<String, dynamic>);
    expect(report.incomplete, 1);
    expect(report.toRefresh, isEmpty);
    final source = (await second.sources()).single;
    expect(source.password, isEmpty);
    expect(source.error, ImportError.credentials);
    await second.close();
  });

  test('restaurer deux fois ne duplique rien, et ne retire rien', () async {
    final repository = await filled();
    final mine = await repository.createFavoriteList('À moi', 'star');
    final data = await repository.exportBackup(secrets: true);
    await repository.restoreBackup(data);
    await repository.restoreBackup(data);
    expect(await repository.sources(), hasLength(1));
    final lists = await repository.favoriteLists();
    expect(lists.where((l) => l.name == 'Sport'), hasLength(1));
    expect(lists.where((l) => l.id == mine), hasLength(1));
    expect((await repository.favoriteItems(lists.firstWhere((l) => l.name == 'Sport').id)), hasLength(1));
    await repository.close();
  });

  test('tout effacer', () async {
    final repository = await filled();
    await repository.wipe();
    expect(await repository.sources(), isEmpty);
    expect(await repository.count(const BrowseQuery(type: ItemType.live)), 0);
    expect(await repository.loadSetting('theme'), isNull);
    await repository.close();
  });
}
