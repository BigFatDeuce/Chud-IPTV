import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/downloads/device_folder.dart';
import 'package:chud_iptv/downloads/download_manager.dart';
import 'package:chud_iptv/downloads/downloader.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/download.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late Directory dir;
  final payload = Uint8List.fromList(List.generate(100000, (i) => i % 251));

  setUp(() async => dir = await Directory.systemTemp.createTemp('chud_dl'));
  tearDown(() => dir.delete(recursive: true));

  /// Serveur qui comprend `Range`, comme ceux des fournisseurs.
  http.Client ranged({List<int>? body, Map<String, String> headers = const {'content-type': 'video/mp4'}, int? cutAfter}) {
    final data = body ?? payload;
    var calls = 0;
    return MockClient.streaming((request, _) async {
      calls++;
      final range = request.headers['Range'];
      final start = range == null ? 0 : int.parse(RegExp(r'\d+').firstMatch(range)![0]!);
      final slice = data.sublist(start, cutAfter != null && calls == 1 ? cutAfter : data.length);
      return http.StreamedResponse(
        Stream.value(slice),
        range == null ? 200 : 206,
        contentLength: data.length - start,
        headers: {...headers, if (range != null) 'content-range': 'bytes $start-${data.length - 1}/${data.length}'},
      );
    });
  }

  DownloadJob job() => DownloadJob(url: 'http://s/m.mp4', part: '${dir.path}/m.mp4.part');
  Future<DownloadEnd> run(http.Client client, {bool Function()? stop}) =>
      runDownload(client, job(), stop ?? () => false, (_, _) {}, retryDelay: Duration.zero);

  group('téléchargement', () {
    test('complet', () async {
      final end = await run(ranged());
      expect(end.error, isNull);
      expect(File(job().part).readAsBytesSync(), payload);
    });

    test('reprend après une coupure, sans doublon ni trou', () async {
      expect((await run(ranged(cutAfter: 30000))).error, isNull);
      expect(File(job().part).readAsBytesSync(), payload);
    });

    test('reprend ce qu\'un arrêt a laissé sur le disque', () async {
      File(job().part).writeAsBytesSync(payload.sublist(0, 40000));
      expect((await run(ranged())).error, isNull);
      expect(File(job().part).readAsBytesSync(), payload);
    });

    test('serveur sans reprise : repart de zéro', () async {
      File(job().part).writeAsBytesSync(List.filled(500, 9));
      final client = MockClient.streaming((_, _) async => http.StreamedResponse(Stream.value(payload), 200, contentLength: payload.length, headers: {'content-type': 'video/mp4'}));
      expect((await run(client)).error, isNull);
      expect(File(job().part).readAsBytesSync(), payload);
    });

    test('reprise au mauvais endroit : refusée plutôt que corrompre le fichier', () async {
      File(job().part).writeAsBytesSync(List.filled(500, 9));
      final client = MockClient.streaming((_, _) async => http.StreamedResponse(Stream.value(payload), 206, headers: {'content-range': 'bytes 0-99999/100000'}));
      expect((await run(client)).error, DownloadError.server);
      expect(File(job().part).lengthSync(), 500);
    });

    test('fichier déjà complet', () async {
      File(job().part).writeAsBytesSync(payload);
      final client = MockClient.streaming((_, _) async => http.StreamedResponse(const Stream.empty(), 416, headers: {'content-range': 'bytes */100000'}));
      expect((await run(client)).error, isNull);
    });

    test('liste HLS refusée, même annoncée comme vidéo', () async {
      expect((await run(ranged(body: utf8.encode('#EXTM3U\n#EXT-X-VERSION:3\n')))).error, DownloadError.format);
      expect((await run(ranged(body: payload, headers: const {'content-type': 'application/vnd.apple.mpegurl'}))).error, DownloadError.format);
    });

    test('page d\'erreur refusée', () async {
      expect((await run(ranged(body: utf8.encode('<html>abonnement expiré</html>'), headers: const {'content-type': 'text/html'}))).error, DownloadError.format);
    });

    test('refus du serveur : pas d\'essais sans fin', () async {
      var calls = 0;
      final client = MockClient.streaming((_, _) async {
        calls++;
        return http.StreamedResponse(const Stream.empty(), 403);
      });
      expect((await run(client)).error, DownloadError.server);
      expect(calls, 1);
    });

    test('panne qui dure : abandon après plusieurs essais, fichier gardé', () async {
      File(job().part).writeAsBytesSync(payload.sublist(0, 500));
      final client = MockClient.streaming((_, _) async => throw const SocketException('coupé'));
      expect((await run(client)).error, DownloadError.network);
      expect(File(job().part).lengthSync(), 500);
    });

    test('arrêt demandé : le début reste pour reprendre', () async {
      final chunks = StreamController<List<int>>();
      var stop = false;
      final client = MockClient.streaming((_, _) async => http.StreamedResponse(chunks.stream, 200, contentLength: payload.length, headers: {'content-type': 'video/mp4'}));
      final running = run(client, stop: () => stop);
      chunks.add(payload.sublist(0, 1000));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      stop = true;
      chunks.add(payload.sublist(1000, 2000));
      expect((await running).stopped, isTrue);
      await chunks.close();
      expect(File(job().part).lengthSync(), 1000);
    });
  });

  test('nom lisible d\'un dossier Android', () {
    expect(folderLabel('content://com.android.externalstorage.documents/tree/primary%3AMovies%2FFilms'), 'Movies/Films');
    expect(folderLabel('content://com.android.externalstorage.documents/tree/1234-5678%3A'), '1234-5678:');
  });

  group('noms de fichiers', () {
    test('caractères interdits retirés, accents gardés', () {
      expect(safeFileName('Amélie: le "film" / 2001?'), 'Amélie le film 2001');
      expect(safeFileName('Fin.  '), 'Fin');
      expect(safeFileName('CON'), '_CON');
      expect(safeFileName('???'), 'video');
      expect(safeFileName('x' * 300).length, 120);
    });

    test('extension : jamais de morceau d\'adresse', () {
      expect(videoExtension('MKV', 'http://s/a'), 'mkv');
      expect(videoExtension('', 'http://s/a.ts?password=secret'), 'ts');
      expect(videoExtension('', 'http://s/get?id=1'), 'mp4');
    });

    test('liste HLS reconnue', () {
      expect(isSegmented('m3u8'), isTrue);
      expect(isSegmented('mkv'), isFalse);
    });
  });

  group('file', () {
    late Repository repository;
    late List<_FakeRun> runs;
    late DownloadManager manager;
    const xtream = Source(id: 1, name: 'X', kind: SourceKind.xtream, url: 'http://s', username: 'u', password: 'motdepasse');
    var known = <int, Source>{};

    DownloadHandle fake(DownloadJob job, void Function(int, int?) progress) {
      final run = _FakeRun(job, progress);
      runs.add(run);
      return DownloadHandle(run.done.future, run.stop);
    }

    DownloadManager make() => DownloadManager(repository: repository, sourceOf: (id) => known[id], folder: () => dir.path, runner: fake);

    Future<Download> add(String key) async =>
        (await manager.enqueue(sourceId: 1, type: ItemType.movie, streamKey: key, title: key, fileName: key, extension: 'mkv'))!;

    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }

    setUp(() async {
      repository = await Repository.open('${dir.path}/t.db');
      runs = [];
      known = {1: xtream};
      manager = make();
      await manager.start();
    });

    tearDown(() async {
      await settle();
      await repository.close();
    });

    test('un à la fois, dans l\'ordre', () async {
      await add('id:1');
      await add('id:2');
      await settle();
      expect(runs, hasLength(1));
      File(runs.first.job.part).writeAsBytesSync([1, 2, 3]);
      runs.first.done.complete(const DownloadEnd());
      await settle();
      expect(manager.entries.first.state, DownloadState.done);
      expect(File(manager.entries.first.path).existsSync(), isTrue);
      expect(runs, hasLength(2));
      expect(runs.last.job.url, contains('/movie/'));
    });

    test('même contenu : pas de doublon, même nom : fichiers distincts', () async {
      final a = await add('id:1');
      expect(await add('id:1'), same(a));
      final b = (await manager.enqueue(sourceId: 1, type: ItemType.movie, streamKey: 'id:2', title: 'id:1', fileName: 'id:1', extension: 'mkv'))!;
      expect(b.path, isNot(a.path));
    });

    test('le mot de passe n\'entre pas en base', () async {
      await add('id:1');
      expect((await repository.downloads()).single.url, isEmpty);
      expect(runs.single.job.url, contains('motdepasse'), reason: 'mais l\'adresse se reconstruit');
    });

    test('une lecture suspend le téléchargement, qui repart après', () async {
      await add('id:1');
      await settle();
      final pausing = manager.hold();
      await settle();
      expect(runs.single.stopped, isTrue);
      await pausing;
      expect(manager.entries.single.state, DownloadState.queued);
      await settle();
      expect(runs, hasLength(1), reason: 'pas de reprise pendant la lecture');
      manager.release();
      await settle();
      expect(runs, hasLength(2));
    });

    test('abonnement à plusieurs connexions : le téléchargement continue', () async {
      known = {1: const Source(id: 1, name: 'X', kind: SourceKind.xtream, url: 'http://s', maxConnections: 2)};
      await add('id:1');
      await settle();
      await manager.hold();
      expect(runs.single.stopped, isFalse);
      manager.release();
      runs.single.done.complete(const DownloadEnd(stopped: true));
    });

    test('pause, reprise', () async {
      final d = await add('id:1');
      await settle();
      await manager.pause(d);
      expect(d.state, DownloadState.paused);
      await manager.resume(d);
      await settle();
      expect(runs, hasLength(2));
      runs.last.done.complete(const DownloadEnd(stopped: true));
    });

    test('échec noté, et conservé après redémarrage', () async {
      await add('id:1');
      await settle();
      runs.single.done.complete(const DownloadEnd(error: DownloadError.server));
      await settle();
      final again = make();
      await again.start();
      expect(again.entries.single.state, DownloadState.failed);
      expect(again.entries.single.error, DownloadError.server);
    });

    test('après un arrêt de l\'app, ce qui tournait repart', () async {
      await add('id:1');
      await settle();
      final count = runs.length;
      runs.single.done.complete(const DownloadEnd(stopped: true));
      await settle();
      final saved = (await repository.downloads()).single..state = DownloadState.active;
      await repository.saveDownload(saved);
      final again = make();
      await again.start();
      await settle();
      expect(runs.length, count + 1);
      runs.last.done.complete(const DownloadEnd(stopped: true));
    });

    test('source supprimée : message clair, pas de plantage', () async {
      known = {};
      final d = await add('id:1');
      await settle();
      expect(d.state, DownloadState.failed);
      expect(d.error, DownloadError.source);
    });

    test('supprimer retire les fichiers', () async {
      final d = await add('id:1');
      await settle();
      File(d.part).writeAsBytesSync([1]);
      await manager.remove(d);
      expect(File(d.part).existsSync(), isFalse);
      expect(await repository.downloads(), isEmpty);
    });

    test('fichier disparu : signalé', () async {
      await add('id:1');
      await settle();
      File(runs.single.job.part).writeAsBytesSync([1]);
      runs.single.done.complete(const DownloadEnd());
      await settle();
      File(manager.entries.single.path).deleteSync();
      final again = make();
      await again.start();
      expect(again.entries.single.error, DownloadError.missing);
    });

    test('dossier Android : copié à la fin, retiré avec le téléchargement', () async {
      final store = _FakeStore();
      manager = DownloadManager(repository: repository, sourceOf: (id) => known[id], folder: () => dir.path, exportFolder: () => 'content://tree', documents: store, runner: fake);
      final d = await add('id:1');
      await settle();
      File(runs.single.job.part).writeAsBytesSync([1, 2, 3]);
      final local = d.path;
      runs.single.done.complete(const DownloadEnd());
      await settle();
      expect(d.state, DownloadState.done);
      expect(d.path, 'content://doc/1');
      expect(File(local).existsSync(), isFalse);
      expect((await repository.downloads()).single.path, 'content://doc/1', reason: 'gardé en base');
      await manager.remove(d);
      expect(store.deleted, ['content://doc/1']);
    });

    test('copie refusée : le fichier reste lisible dans le dossier de l\'app', () async {
      manager = DownloadManager(repository: repository, sourceOf: (id) => known[id], folder: () => dir.path, exportFolder: () => 'content://tree', documents: _FakeStore(fails: true), runner: fake);
      final d = await add('id:1');
      await settle();
      File(runs.single.job.part).writeAsBytesSync([1]);
      runs.single.done.complete(const DownloadEnd());
      await settle();
      expect(d.state, DownloadState.done);
      expect(File(d.path).existsSync(), isTrue);
    });

    test('copie Android qui plante : le fichier reste, la file continue, la lecture n\'attend pas', () async {
      manager = DownloadManager(repository: repository, sourceOf: (id) => known[id], folder: () => dir.path, exportFolder: () => 'content://tree', documents: _FakeStore(crashes: true), runner: fake);
      final d = await add('id:1');
      await add('id:2');
      await settle();
      File(runs.single.job.part).writeAsBytesSync([1]);
      runs.single.done.complete(const DownloadEnd());
      await settle();
      expect(d.state, DownloadState.done);
      expect(File(d.path).existsSync(), isTrue);
      expect((await repository.downloads()).first.state, DownloadState.done, reason: 'gardé en base');
      expect(runs, hasLength(2), reason: 'le suivant démarre');
      await manager.hold().timeout(const Duration(seconds: 2));
      manager.release();
      await settle();
      runs.last.done.complete(const DownloadEnd(stopped: true));
    });

    test('suppression impossible : la ligne reste, la file n\'est pas bloquée', () async {
      manager = DownloadManager(repository: repository, sourceOf: (id) => known[id], folder: () => dir.path, documents: _FakeStore(crashes: true), runner: fake);
      final d = await add('id:1');
      await settle();
      runs.single.done.complete(const DownloadEnd(stopped: true));
      await settle();
      d.path = 'content://doc/1';
      await expectLater(manager.remove(d), throwsA(anything));
      expect(manager.entries, contains(d));
      await add('id:2');
      await settle();
      expect(runs, hasLength(2), reason: 'le suivant démarre quand même');
      runs.last.done.complete(const DownloadEnd(stopped: true));
    });

    test('mettre en pause rend la main même si le suivant démarre', () async {
      final d = await add('id:1');
      await add('id:2');
      await settle();
      await manager.pause(d).timeout(const Duration(seconds: 2));
      expect(d.state, DownloadState.paused);
      expect(runs, hasLength(2));
      runs.last.done.complete(const DownloadEnd(stopped: true));
    });

    test('reprendre ne vaut que pour une pause ou un échec', () async {
      final d = await add('id:1');
      await settle();
      File(runs.single.job.part).writeAsBytesSync([1]);
      runs.single.done.complete(const DownloadEnd());
      await settle();
      expect(d.state, DownloadState.done);
      await manager.resume(d);
      await settle();
      expect(d.state, DownloadState.done, reason: 'un fichier complet ne se retélécharge pas');
      expect(runs, hasLength(1));
    });

    test('seuls les passages prévus existent', () {
      const allowed = {
        DownloadState.queued: {DownloadState.active, DownloadState.paused, DownloadState.failed},
        DownloadState.active: {DownloadState.queued, DownloadState.paused, DownloadState.done, DownloadState.failed},
        DownloadState.paused: {DownloadState.queued},
        DownloadState.failed: {DownloadState.queued},
        DownloadState.done: {DownloadState.failed},
      };
      for (final from in DownloadState.values) {
        for (final to in DownloadState.values) {
          expect(from.canBecome(to), allowed[from]!.contains(to), reason: '$from → $to');
        }
      }
    });

    test('liste HLS : refusée dès l\'ajout', () async {
      expect(await manager.enqueue(sourceId: 1, type: ItemType.movie, streamKey: 'k', title: 't', fileName: 't', url: 'http://s/a.m3u8'), isNull);
      expect(manager.entries, isEmpty);
    });
  });
}

class _FakeStore implements DocumentStore {
  _FakeStore({this.fails = false, this.crashes = false});

  final bool fails;

  /// Le système répond par une erreur au lieu d'un refus poli.
  final bool crashes;
  final deleted = <String>[];

  @override
  Future<String?> save(String folder, String path, String name) async {
    if (crashes) throw PlatformException(code: 'io');
    return fails ? null : 'content://doc/1';
  }

  @override
  Future<void> delete(String uri) async {
    if (crashes) throw PlatformException(code: 'io');
    deleted.add(uri);
  }

  @override
  Future<bool> exists(String uri) async => true;
}

class _FakeRun {
  _FakeRun(this.job, this.progress);

  final DownloadJob job;
  final void Function(int, int?) progress;
  final done = Completer<DownloadEnd>();
  bool stopped = false;

  void stop() {
    stopped = true;
    if (!done.isCompleted) done.complete(const DownloadEnd(stopped: true));
  }
}
