import 'dart:io';

import 'package:chud_iptv/app_controller.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/epg/epg_import.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/download.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository implements Repository {
  _Repository(this.list, {this.guides = const []});

  final List<Source> list;
  final List<EpgSource> guides;

  @override
  Future<List<Source>> sources() async => list;
  @override
  Future<List<EpgSource>> epgSources() async => guides;
  @override
  Future<List<Download>> downloads() async => const [];
  @override
  Future<Map<String, String>> settings() async => const {};
  @override
  Future<void> saveSetting(String key, String value) async {}
  @override
  Future<String?> loadSetting(String key) async => null;
  @override
  Future<List<FavoriteList>> favoriteLists() async => const [];
  @override
  Future<Map<int, Set<int>>> favoriteMemberships() async => const {};
  @override
  Future<void> resolvePending() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _first = Source(id: 1, name: 'Première', kind: SourceKind.m3uUrl, url: 'http://a.example/liste.m3u');
const _second = Source(id: 2, name: 'Seconde', kind: SourceKind.m3uUrl, url: 'http://b.example/liste.m3u');

void main() {
  Future<AppController> controller(Repository repository, {ImportRunner? runner, GuideRunner? guideRunner}) async {
    final c = AppController(
      repository: repository,
      dbPath: '',
      tempDir: Directory.systemTemp.path,
      playlistsDir: Directory.systemTemp.path,
      runner: runner,
      guideRunner: guideRunner,
    );
    addTearDown(c.dispose);
    await c.start();
    return c;
  }

  group('file des actualisations', () {
    test('rien, en attente, en cours, puis rien', () async {
      final seen = <int, List<SourceActivity>>{1: [], 2: []};
      late AppController c;
      c = await controller(_Repository(const [_first, _second]), runner: (request, _) async {
        for (final id in seen.keys) {
          seen[id]!.add(c.activityOf(id));
        }
        return const ImportReport();
      });
      expect(c.activityOf(1), SourceActivity.idle);
      c.refreshAll();
      expect(c.activityOf(1), SourceActivity.importing);
      expect(c.activityOf(2), SourceActivity.queued);
      await pumpEventQueue();
      expect(seen[1], [SourceActivity.importing, SourceActivity.idle]);
      expect(seen[2], [SourceActivity.queued, SourceActivity.importing], reason: 'une source à la fois');
      expect(c.busy, isFalse);
    });

    test('import qui plante sans prévenir : échec annoncé, la source suivante passe', () async {
      final c = await controller(_Repository(const [_first, _second]), runner: (request, _) async {
        if (request.source.id == 1) throw StateError('isolat impossible à lancer');
        return const ImportReport();
      });
      final outcomes = <ImportOutcome>[];
      c.outcomes.listen(outcomes.add);
      c.refreshAll();
      await pumpEventQueue();
      expect(outcomes.map((o) => (o.source.id, o.failure?.kind)), [(1, ImportError.unknown), (2, null)]);
      expect(c.busy, isFalse, reason: 'sinon tous les boutons des sources restent grisés jusqu\'au redémarrage');
      expect(c.activityOf(1), SourceActivity.idle);
    });
  });

  test('guide qui plante sans prévenir : le chargement s\'arrête, l\'échec est annoncé', () async {
    final c = await controller(
      _Repository(const [], guides: const [EpgSource(id: 7, name: 'Guide', url: 'http://g.example/guide.xml')]),
      guideRunner: (_, _, _, _) async => throw StateError('isolat impossible à lancer'),
    );
    final reports = <EpgReport>[];
    c.guideReports.listen(reports.add);
    await c.refreshGuides();
    await pumpEventQueue();
    expect(c.guideBusy, isFalse, reason: 'sinon « Actualiser le guide » reste grisé jusqu\'au redémarrage');
    expect(reports.single.failed, ['Guide']);
  });
}
