// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/epg/epg_import.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/import/xtream.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:sqlite3/sqlite3.dart';

/// Hors CI : importe le vrai guide d'un vrai compte.
/// `flutter test test_live/live_guide_test.dart --dart-define=SOURCE=chemin/vers/source.json`
void main() {
  const path = String.fromEnvironment('SOURCE');

  test('guide réel', skip: path.isEmpty ? 'SOURCE non défini' : false, timeout: const Timeout(Duration(minutes: 8)), () async {
    final json = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final dir = await Directory.systemTemp.createTemp('chud_live_guide');
    final db = '${dir.path}/live.db';
    final repository = await Repository.open(db);
    final id = await repository.addSource(Source(
      name: 'Test',
      kind: SourceKind.xtream,
      url: json['server'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      withMovies: false,
      withSeries: false,
    ));
    final source = (await repository.sources()).firstWhere((s) => s.id == id);
    final client = IOClient(HttpClient());
    await runImport(ImportRequest(dbPath: db, tempDir: dir.path, source: source), client, (_) {});
    final imported = (await repository.sources()).firstWhere((s) => s.id == id);
    final epg = await repository.addEpgSource('Test', '', sourceId: id);
    final clock = Stopwatch()..start();
    final report = await runEpgImport(db, dir.path, [EpgJob(id: epg, name: 'Test', url: xtreamGuideUrl(imported))], client, (_) {});
    print('guide : ${clock.elapsed}, ${report.programs} programmes, ${report.linked} chaînes associées, échecs ${report.failed.length}');
    print('décalage serveur : ${imported.serverOffset} min, taille ${File(db).lengthSync() ~/ (1024 * 1024)} Mo');
    clock.reset();
    final first = await repository.page(const BrowseQuery(type: ItemType.live, onlyGuide: true), 0, 120);
    print('page avec programme en cours : ${clock.elapsedMilliseconds} ms, ${first.where((i) => i.nowTitle != null).length} sur ${first.length}');
    clock.reset();
    final now = DateTime.now();
    await repository.programs(first.first.id, now.subtract(const Duration(hours: 12)), now.add(const Duration(hours: 12)));
    print('programmes d\'une chaîne : ${clock.elapsedMilliseconds} ms');
    final check = sqlite3.open(db);
    print(check.select('SELECT count(*) a, sum(l.channel = lower(i.tvg_id)) b FROM epg_links l JOIN items i ON i.id = l.item_id').first.values);
    print('avec programme : ${check.select('SELECT count(DISTINCT l.item_id) FROM epg_links l JOIN epg_programs p ON p.channel = l.channel').first.values.first}');
    for (final r in check.select("SELECT i.sort_name, l.channel FROM epg_links l JOIN items i ON i.id = l.item_id WHERE l.channel <> lower(i.tvg_id) ORDER BY random() LIMIT 25")) {
      print('${r.columnAt(0)}  ->  ${r.columnAt(1)}');
    }
    check.close();
    expect(report.failed, isEmpty);
    expect(report.linked, greaterThan(0));
    client.close();
    await repository.close();
    await dir.delete(recursive: true);
  });
}
