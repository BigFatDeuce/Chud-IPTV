// Essai sur un vrai abonnement. Hors de `test/` : il ne tourne jamais en CI.
//   flutter test test_live --dart-define=SOURCE=chemin/vers/test-source.json
// Le fichier JSON (server, username, password) reste hors du dépôt.
import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/import/catalog_writer.dart';
import 'package:chud_iptv/import/entry.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';

const sourceFile = String.fromEnvironment('SOURCE');

String line(TypeReport r) =>
    'total ${r.total}, ajoutés ${r.added}, modifiés ${r.updated}, renommés ${r.renamed}, logos ${r.relogoed}, disparus ${r.missing}, revenus ${r.restored}';

void main() {
  late Directory dir;
  late String path;
  late Repository repository;
  late Source source;

  Future<T> timed<T>(String label, Future<T> Function() job) async {
    final watch = Stopwatch()..start();
    final result = await job();
    // ignore: avoid_print
    print('$label : ${(watch.elapsedMicroseconds / 1000).toStringAsFixed(1)} ms');
    return result;
  }

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('chud_live');
    path = '${dir.path}/live.db';
    repository = await Repository.open(path);
    final config = jsonDecode(File(sourceFile).readAsStringSync()) as Map<String, dynamic>;
    final id = await repository.addSource(Source(
      name: 'Abonnement',
      kind: SourceKind.xtream,
      url: config['server'] as String,
      username: config['username'] as String,
      password: config['password'] as String,
    ));
    source = (await repository.sources()).firstWhere((s) => s.id == id);
  });

  tearDownAll(() async {
    await repository.close();
    await dir.delete(recursive: true);
  });

  test('premier import, puis actualisation sans changement', () async {
    final stages = <ImportStage>{};
    final first = await timed('Import complet', () => importInIsolate(ImportRequest(dbPath: path, tempDir: dir.path, source: source), (p) => stages.add(p.stage)));
    // ignore: avoid_print
    print('Direct : ${line(first.live)}\nFilms : ${line(first.movies)}\nSéries : ${line(first.series)}');
    // ignore: avoid_print
    print('Base : ${(File(path).lengthSync() / 1e6).toStringAsFixed(1)} Mo, mémoire max du test : ${(ProcessInfo.maxRss / 1e6).toStringAsFixed(0)} Mo');
    expect(first.live.total, greaterThan(1000));
    expect(stages, contains(ImportStage.writing));

    final s = (await repository.sources()).single;
    // ignore: avoid_print
    print('Expire : ${s.expiresAt}, connexions : ${s.maxConnections}');
    expect(s.error, isNull);

    final second = await timed('Actualisation', () => importInIsolate(ImportRequest(dbPath: path, tempDir: dir.path, source: source), (_) {}));
    // ignore: avoid_print
    print('Direct : ${line(second.live)}\nFilms : ${line(second.movies)}\nSéries : ${line(second.series)}');
    expect(second.live.added + second.movies.added + second.series.added, lessThan(first.total ~/ 100));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('listes : comptes et pages, y compris très loin', () async {
    const all = BrowseQuery(type: ItemType.movie);
    final total = await timed('Compte des films', () => repository.count(all));
    final first = await timed('Page 1', () => repository.page(all, 0, 120));
    final deep = await timed('Page au fond', () => repository.page(all, total - 200, 120));
    expect(first, hasLength(120));
    expect(deep, hasLength(120));
    final cats = await timed('Catégories du direct', () => repository.categories(ItemType.live, null));
    expect(cats, isNotEmpty);
    final biggest = cats.reduce((a, b) => a.itemCount > b.itemCount ? a : b);
    final q = BrowseQuery(type: ItemType.live, categoryId: biggest.id);
    await timed('Page dans la plus grande catégorie (${biggest.itemCount})', () => repository.page(q, 0, 120));
    // ignore: avoid_print
    print('Exemples : ${first.take(3).map((i) => '${i.name} [${i.country}]').join(' ; ')}');
    // ignore: avoid_print
    print('Direct : ${cats.take(4).map((c) => '${c.name} (${c.itemCount})').join(' ; ')}');
  });

  test('mauvais mot de passe : refusé, catalogue intact', () async {
    final before = await repository.count(const BrowseQuery(type: ItemType.live));
    await expectLater(
      importInIsolate(ImportRequest(dbPath: path, tempDir: dir.path, source: source.copyWith(password: 'mauvais-${source.password}')), (_) {}),
      throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.credentials)),
    );
    expect(await repository.count(const BrowseQuery(type: ItemType.live)), before);
  });
}
