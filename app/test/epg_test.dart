import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/data/database.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/epg/catchup.dart';
import 'package:chud_iptv/epg/epg_import.dart';
import 'package:chud_iptv/epg/xmltv.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqlite3/sqlite3.dart';

String xmlTime(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  final u = t.toUtc();
  return '${u.year}${two(u.month)}${two(u.day)}${two(u.hour)}${two(u.minute)}${two(u.second)} +0000';
}

String guide(DateTime now, {String title = 'Journal &amp; météo'}) => '''<?xml version="1.0" encoding="utf-8"?>
<tv>
<channel id="TF1.fr"><display-name>TF1 HD</display-name></channel>
<channel id="arte.fr"><display-name>Arte</display-name></channel>
<programme start="${xmlTime(now.subtract(const Duration(hours: 1)))}" stop="${xmlTime(now.add(const Duration(hours: 1)))}" channel="TF1.fr">
  <title lang="fr">$title</title><desc lang="fr">Le récit</desc>
</programme>
<programme start="${xmlTime(now.add(const Duration(hours: 1)))}" stop="${xmlTime(now.add(const Duration(hours: 2)))}" channel="TF1.fr"><title>Suivant</title></programme>
<programme start="${xmlTime(now.subtract(const Duration(days: 30)))}" stop="${xmlTime(now.subtract(const Duration(days: 29)))}" channel="TF1.fr"><title>Trop vieux</title></programme>
<programme start="${xmlTime(now)}" stop="${xmlTime(now.add(const Duration(hours: 3)))}" channel="arte.fr"><title><![CDATA[Soirée <Arte>]]></title></programme>
</tv>
''';

void main() {
  group('XMLTV', () {
    Stream<List<int>> chunks(String text, int size) {
      final bytes = utf8.encode(text);
      return Stream.fromIterable([for (var i = 0; i < bytes.length; i += size) bytes.sublist(i, (i + size).clamp(0, bytes.length))]);
    }

    test('heures et fuseaux', () {
      expect(parseXmltvTime('20261031180000 +0000'), DateTime.utc(2026, 10, 31, 18).millisecondsSinceEpoch ~/ 1000);
      expect(parseXmltvTime('20261031190000 +0100'), DateTime.utc(2026, 10, 31, 18).millisecondsSinceEpoch ~/ 1000);
      expect(parseXmltvTime('20261031130000 -0500'), DateTime.utc(2026, 10, 31, 18).millisecondsSinceEpoch ~/ 1000);
      expect(parseXmltvTime('20261031180000'), DateTime.utc(2026, 10, 31, 18).millisecondsSinceEpoch ~/ 1000, reason: 'sans fuseau : UTC');
      expect(parseXmltvTime('n importe quoi'), isNull);
    });

    test('quelle que soit la taille des morceaux', () async {
      final text = guide(DateTime.utc(2026, 10, 31, 12));
      for (final size in [7, 64, 1000, 100000]) {
        final entries = await parseXmltv(chunks(text, size)).toList();
        final programs = entries.whereType<XmltvProgram>().toList();
        expect(entries.whereType<XmltvChannel>().map((c) => c.id), ['TF1.fr', 'arte.fr'], reason: 'morceaux de $size');
        expect(programs, hasLength(4));
        expect(programs.first.title, 'Journal & météo');
        expect(programs.first.description, 'Le récit');
        expect(programs.last.title, 'Soirée <Arte>');
      }
    });

    test('description raccourcie', () async {
      final long = 'x' * 2000;
      final text = '<tv><programme start="20261031180000" stop="20261031190000" channel="a"><title>T</title><desc>$long</desc></programme></tv>';
      final p = (await parseXmltv(chunks(text, 100)).toList()).single as XmltvProgram;
      expect(p.description.length, maxDescription);
    });

    test('programme incomplet ignoré', () async {
      const text = '<tv><programme start="xx" stop="20261031190000" channel="a"><title>T</title></programme></tv>';
      expect(await parseXmltv(chunks(text, 100)).toList(), isEmpty);
    });

    test('fichier compressé', () async {
      final dir = await Directory.systemTemp.createTemp('chud_xml');
      final file = File('${dir.path}/g.xml.gz')..writeAsBytesSync(gzip.encode(utf8.encode(guide(DateTime.utc(2026, 10, 31)))));
      final entries = await parseXmltv(openXmltv(file)).toList();
      expect(entries.whereType<XmltvProgram>(), hasLength(4));
      await dir.delete(recursive: true);
    });
  });

  test('clé de nom', () {
    expect(guideNameKey('tf1 fhd'), 'tf1');
    expect(guideNameKey('france 2 uhd 4k'), 'france 2');
    expect(guideNameKey('hd'), '');
  });

  test('association par nom : jamais le mauvais pays', () {
    expect(matchByName(['cnbc.us', 'cnbc.uk'], 'GB'), 'cnbc.uk');
    expect(matchByName(['cnbc.us', 'cnbc.uk'], 'US'), 'cnbc.us');
    expect(matchByName(['cnbc.us', 'cnbc.uk'], 'FR'), isNull);
    expect(matchByName(['cnbc.us', 'cnbc.uk'], ''), isNull);
    expect(matchByName(['riceotv.de'], 'FR'), isNull);
    expect(matchByName(['arte.fr'], ''), 'arte.fr');
    expect(matchByName(['tf1'], 'FR'), 'tf1');
  });

  group('replay', () {
    final now = DateTime.utc(2026, 10, 31, 12);
    final seconds = now.millisecondsSinceEpoch ~/ 1000;
    final past = Program(channel: 'c', start: seconds - 7200, stop: seconds - 3600, title: 'T');
    const xtream = Source(id: 1, name: 'X', kind: SourceKind.xtream, url: 'http://s.example', username: 'u', password: 'p');
    const archived = StreamInfo(type: ItemType.live, stableKey: 'id:12', catchup: 'xtream', catchupDays: 2);

    test('seulement si la fiche l\'annonce', () {
      expect(canReplay(archived, past, now), isTrue);
      expect(canReplay(const StreamInfo(type: ItemType.live, stableKey: 'id:12'), past, now), isFalse);
    });

    test('pas un programme en cours ni à venir', () {
      final current = Program(channel: 'c', start: seconds - 60, stop: seconds + 60, title: 'T');
      expect(canReplay(archived, current, now), isFalse);
    });

    test('pas au-delà de la durée de conservation', () {
      final old = Program(channel: 'c', start: seconds - 3 * 86400, stop: seconds - 3 * 86400 + 3600, title: 'T');
      expect(canReplay(archived, old, now), isFalse);
    });

    test('adresse Xtream, à l\'heure du serveur', () {
      final utc = catchupRequest(xtream, archived, past, now: now)!;
      expect(utc.url, 'http://s.example/timeshift/u/p/60/2026-10-31:10-00/12.ts');
      expect(utc.live, isFalse);
      const paris = Source(id: 1, name: 'X', kind: SourceKind.xtream, url: 'http://s.example', username: 'u', password: 'p', serverOffset: 60);
      expect(catchupRequest(paris, archived, past, now: now)!.url, contains('2026-10-31:11-00'));
    });

    test('playlists : formats courants', () {
      const m3u = Source(id: 2, name: 'P', kind: SourceKind.m3uUrl);
      final start = past.start, stop = past.stop;
      expect(
        catchupRequest(m3u, const StreamInfo(type: ItemType.live, stableKey: 'k', url: 'http://c/a.m3u8', catchup: 'shift', catchupDays: 1), past, now: now)!.url,
        'http://c/a.m3u8?utc=$start&lutc=$seconds',
      );
      expect(
        catchupRequest(m3u, const StreamInfo(type: ItemType.live, stableKey: 'k', url: 'http://c/a.m3u8', catchup: 'append', catchupSource: '?t={utc}-{end}', catchupDays: 1), past, now: now)!.url,
        'http://c/a.m3u8?t=$start-$stop',
      );
      expect(
        catchupRequest(m3u, const StreamInfo(type: ItemType.live, stableKey: 'k', url: 'http://c/x/a.m3u8', catchup: 'default', catchupSource: 'http://r/{Y}/{m}/{d}/{H}{M}.ts', catchupDays: 1), past, now: now)!.url,
        'http://r/2026/10/31/1000.ts',
      );
      expect(
        catchupRequest(m3u, const StreamInfo(type: ItemType.live, stableKey: 'k', url: 'http://c/ch/index.m3u8', catchup: 'flussonic', catchupDays: 1), past, now: now)!.url,
        'http://c/ch/index-$start-3600.m3u8',
      );
    });

    test('format inconnu : pas de replay inventé', () {
      const m3u = Source(id: 2, name: 'P', kind: SourceKind.m3uUrl);
      expect(catchupRequest(m3u, const StreamInfo(type: ItemType.live, stableKey: 'k', url: 'http://c/a', catchup: 'mystere', catchupDays: 1), past, now: now), isNull);
    });
  });

  group('import', () {
    late Directory dir;
    late String path;
    late Repository repository;
    late int epgId;
    final now = DateTime.now();

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('chud_epg');
      path = '${dir.path}/test.db';
      repository = await Repository.open(path);
      final id = await repository.addSource(const Source(name: 'P', kind: SourceKind.m3uUrl, url: 'http://p.example/l.m3u'));
      final source = (await repository.sources()).firstWhere((s) => s.id == id);
      const playlist = '#EXTM3U\n#EXTINF:-1 tvg-id="tf1.fr",FR| TF1 FHD\nhttp://s/live/u/p/1.ts\n'
          '#EXTINF:-1,Arte HD\nhttp://s/live/u/p/2.ts\n#EXTINF:-1,Sans guide\nhttp://s/live/u/p/3.ts\n';
      await runImport(ImportRequest(dbPath: path, tempDir: dir.path, source: source), MockClient((_) async => http.Response(playlist, 200)), (_) {});
      epgId = await repository.addEpgSource('Guide', 'http://e.example/g.xml');
    });

    tearDown(() async {
      await repository.close();
      await dir.delete(recursive: true);
    });

    Future<EpgReport> run(String body, {int status = 200}) => runEpgImport(
          path,
          dir.path,
          [EpgJob(id: epgId, name: 'Guide', url: 'http://e.example/g.xml')],
          MockClient((_) async => http.Response.bytes(utf8.encode(body), status)),
          (_) {},
        );

    Future<Item> item(String text) async => (await repository.page(BrowseQuery(type: ItemType.live, text: text), 0, 1)).first;

    test('associe par tvg-id puis par nom, et garde seulement la fenêtre utile', () async {
      final report = await run(guide(now));
      expect(report.linked, 2);
      expect(report.programs, 3, reason: 'le programme d\'il y a 30 jours est écarté');
      final tf1 = await item('tf1');
      final programs = await repository.programs(tf1.id, now.subtract(const Duration(hours: 3)), now.add(const Duration(hours: 3)));
      expect(programs.map((p) => p.title), ['Journal & météo', 'Suivant']);
      expect((await repository.programs((await item('arte')).id, now, now.add(const Duration(hours: 1)))).single.title, 'Soirée <Arte>');
      expect(await repository.programs((await item('guide')).id, now, now.add(const Duration(hours: 1))), isEmpty);
    });

    test('programme en cours dans les listes', () async {
      await run(guide(now));
      final tf1 = await item('tf1');
      expect(tf1.nowTitle, 'Journal & météo');
      expect(tf1.nowProgress, closeTo(0.5, 0.05));
      expect((await item('guide')).nowTitle, isNull, reason: 'l\'EPG reste facultatif');
    });

    test('guide illisible : l\'ancien est conservé', () async {
      await run(guide(now));
      final report = await run('<html>erreur</html>');
      expect(report.failed, ['Guide']);
      expect(await repository.programs((await item('tf1')).id, now, now.add(const Duration(minutes: 1))), hasLength(1));
    });

    test('serveur en erreur : l\'ancien est conservé', () async {
      await run(guide(now));
      expect((await run('', status: 500)).failed, ['Guide']);
      expect(await repository.programs((await item('tf1')).id, now, now.add(const Duration(minutes: 1))), hasLength(1));
    });

    test('date d\'actualisation du guide : celle du jour, pas 1970', () async {
      await run(guide(now));
      final refreshed = (await repository.epgSources()).single.refreshedAt!;
      expect(refreshed.difference(DateTime.now()).inMinutes.abs(), lessThan(2));
    });

    test('une actualisation remplace le guide de cette source', () async {
      await run(guide(now));
      await run(guide(now, title: 'Nouveau'));
      expect((await repository.programs((await item('tf1')).id, now, now.add(const Duration(minutes: 1)))).single.title, 'Nouveau');
    });

    test('association manuelle : elle survit aux actualisations', () async {
      await run(guide(now));
      final other = await item('guide');
      await repository.linkToGuide(other.id, 'arte.fr');
      await run(guide(now));
      expect((await repository.programs(other.id, now, now.add(const Duration(hours: 1)))).single.title, 'Soirée <Arte>');
    });

    test('chercher une chaîne du guide pour l\'associer', () async {
      await run(guide(now));
      expect(await repository.searchGuideChannels('art'), ['arte.fr']);
    });

    test('filtrer les chaînes qui ont un guide', () async {
      await run(guide(now));
      expect(await repository.count(const BrowseQuery(type: ItemType.live, onlyGuide: true)), 2);
    });

    test('supprimer une source de guide retire ses programmes', () async {
      await run(guide(now));
      await repository.deleteEpgSource(epgId);
      expect(await repository.programs((await item('tf1')).id, now, now.add(const Duration(minutes: 1))), isEmpty);
    });
  });

  test('migration vers le guide : les données restent', () {
    final dir = Directory.systemTemp.createTempSync('chud_v2');
    final file = '${dir.path}/v2.db';
    final db = sqlite3.open(file);
    db.execute(migrations[0]);
    db.execute('PRAGMA user_version = 1');
    db.execute("INSERT INTO sources(name, kind) VALUES('Ancienne', 'xtream')");
    db.close();
    final again = openDatabase(file);
    expect(again.select('PRAGMA user_version').first.values.first, migrations.length);
    expect(again.select('SELECT server_offset FROM sources').single['server_offset'], 0);
    again.close();
    dir.deleteSync(recursive: true);
  });
}
