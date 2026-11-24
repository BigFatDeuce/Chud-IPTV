import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/database.dart';
import '../models/catalog.dart';
import '../models/source.dart';
import 'catalog_writer.dart';
import 'entry.dart';
import 'm3u_parser.dart';
import 'xtream.dart';

const _userAgent = 'ChudIPTV/1';
const _connectTimeout = Duration(seconds: 20);
const _idleTimeout = Duration(seconds: 60);

enum ImportStage { connecting, downloadingLive, downloadingMovies, downloadingSeries, downloadingPlaylist, writing }

/// Avancement envoyé à l'interface. [bytes] : octets reçus à l'étape en cours, [items] : éléments écrits.
class ImportProgress {
  const ImportProgress(this.stage, {this.bytes = 0, this.items = 0});

  final ImportStage stage;
  final int bytes;
  final int items;
}

/// Bilan complet d'une actualisation réussie.
class ImportReport {
  const ImportReport({this.live = const TypeReport(), this.movies = const TypeReport(), this.series = const TypeReport()});

  final TypeReport live;
  final TypeReport movies;
  final TypeReport series;

  int get total => live.total + movies.total + series.total;
}

class ImportRequest {
  const ImportRequest({required this.dbPath, required this.tempDir, required this.source, this.playlistCopy, this.force = false});

  final String dbPath;
  final String tempDir;
  final Source source;

  /// Copie gardée d'un fichier local, utilisée si l'original a disparu.
  final String? playlistCopy;

  /// Applique une liste jugée suspecte (très réduite) à la demande de l'utilisateur.
  final bool force;
}

/// Lance l'import dans son propre isolat : téléchargement, analyse et écriture ne touchent pas à
/// l'interface. [onProgress] reçoit l'avancement ; le futur échoue avec une [ImportFailure].
Future<ImportReport> importInIsolate(ImportRequest request, void Function(ImportProgress) onProgress) async {
  final port = ReceivePort();
  final exit = ReceivePort();
  final errors = ReceivePort();
  final done = Completer<ImportReport>();
  port.listen((m) {
    if (m is ImportProgress) {
      onProgress(m);
    } else if (m is ImportReport) {
      done.complete(m);
    } else if (m is ImportFailure) {
      done.completeError(m);
    }
  });
  errors.listen((_) {
    if (!done.isCompleted) done.completeError(const ImportFailure(ImportError.unknown));
  });
  exit.listen((_) {
    if (!done.isCompleted) done.completeError(const ImportFailure(ImportError.unknown));
  });
  await Isolate.spawn(_isolateMain, (request, port.sendPort), debugName: 'import', onExit: exit.sendPort, onError: errors.sendPort);
  try {
    return await done.future;
  } finally {
    port.close();
    exit.close();
    errors.close();
  }
}

Future<void> _isolateMain((ImportRequest, SendPort) args) async {
  final (request, port) = args;
  final client = IOClient(HttpClient()
    ..connectionTimeout = _connectTimeout
    ..userAgent = _userAgent);
  try {
    final report = await runImport(request, client, port.send);
    port.send(report);
  } on ImportFailure catch (e) {
    port.send(e);
  } finally {
    client.close();
  }
}

/// Déroulé complet d'une actualisation, avec une règle : rien n'est écrit tant que tout n'est pas
/// téléchargé, et l'écriture tient dans une seule transaction. Une panne, à n'importe quelle étape,
/// laisse donc la base dans son état précédent.
Future<ImportReport> runImport(ImportRequest request, http.Client client, void Function(ImportProgress) onProgress) async {
  final source = request.source;
  final work = await Directory(request.tempDir).createTemp('import');
  final db = openDatabase(request.dbPath);
  try {
    final job = source.kind == SourceKind.xtream ? _XtreamJob(request, client, work, onProgress) : _PlaylistJob(request, client, work, onProgress);
    try {
      await job.fetch();
      final report = await _write(db, source, request.force, job, onProgress);
      db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
      return report;
    } catch (e) {
      final failure = _classify(e);
      _recordFailure(db, source.id, failure);
      throw failure;
    }
  } finally {
    db.close();
    try {
      await work.delete(recursive: true);
    } on FileSystemException {
      // Dossier temporaire : le système finira par le nettoyer.
    }
  }
}

ImportFailure _classify(Object error) => switch (error) {
      ImportFailure() => error,
      TimeoutException() => const ImportFailure(ImportError.timeout),
      SocketException() || HandshakeException() || http.ClientException() => const ImportFailure(ImportError.network),
      FileSystemException() => const ImportFailure(ImportError.fileMissing),
      _ => const ImportFailure(ImportError.unknown),
    };

void _recordFailure(Database db, int sourceId, ImportFailure failure) {
  db.execute(
    'UPDATE sources SET error = ?, error_detail = ?, error_at = ? WHERE id = ?',
    [failure.kind.name, failure.detail, DateTime.now().millisecondsSinceEpoch, sourceId],
  );
}

Future<ImportReport> _write(Database db, Source source, bool force, _Job job, void Function(ImportProgress) onProgress) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  db.execute('BEGIN IMMEDIATE');
  try {
    var written = 0;
    void tick() {
      if (++written % 2000 == 0) onProgress(ImportProgress(ImportStage.writing, items: written));
    }

    onProgress(const ImportProgress(ImportStage.writing));
    final reports = await job.write(db, now, force, tick);
    final live = reports[ItemType.live] ?? const TypeReport();
    final movies = reports[ItemType.movie] ?? const TypeReport();
    final series = reports[ItemType.series] ?? const TypeReport();
    final report = ImportReport(live: live, movies: movies, series: series);
    if (report.total == 0 && !force) throw const ImportFailure(ImportError.empty);
    db.execute(
      'UPDATE sources SET refreshed_at=?, error=NULL, error_detail=\'\', error_at=NULL, live_count=?, movie_count=?, series_count=?, '
      'epg_url=?, expires_at=?, max_connections=?, server_offset=? WHERE id=?',
      [
        now, live.total, movies.total, series.total, job.epgUrl,
        job.expiresAt?.millisecondsSinceEpoch, job.maxConnections, job.serverOffset, source.id,
      ],
    );
    db.execute('COMMIT');
    return report;
  } catch (_) {
    db.execute('ROLLBACK');
    rethrow;
  }
}

abstract class _Job {
  _Job(this.request, this.client, this.work, this.onProgress);

  final ImportRequest request;
  final http.Client client;
  final Directory work;
  final void Function(ImportProgress) onProgress;

  String epgUrl = '';
  DateTime? expiresAt;
  int? maxConnections;
  int serverOffset = 0;

  Source get source => request.source;

  Future<void> fetch();
  Future<Map<ItemType, TypeReport>> write(Database db, int now, bool force, void Function() tick);

  /// Télécharge [uri] dans [out] ; une réponse tronquée échoue au lieu de passer pour complète.
  Future<void> download(Uri uri, File out, ImportStage stage) async {
    final response = await client.send(http.Request('GET', uri)..headers['User-Agent'] = _userAgent).timeout(_connectTimeout * 2);
    _checkStatus(response.statusCode);
    final sink = out.openWrite();
    var received = 0;
    var lastReport = 0;
    try {
      await for (final chunk in response.stream.timeout(_idleTimeout)) {
        sink.add(chunk);
        received += chunk.length;
        if (received - lastReport > 1 << 20) {
          lastReport = received;
          onProgress(ImportProgress(stage, bytes: received));
        }
      }
    } finally {
      await sink.close();
    }
    final expected = response.contentLength;
    if (expected != null && !response.isRedirect && response.headers['content-encoding'] == null && received < expected) {
      throw const ImportFailure(ImportError.network, 'tronqué');
    }
  }

  void _checkStatus(int status) {
    if (status == 401 || status == 403) throw const ImportFailure(ImportError.credentials);
    if (status == 404) throw const ImportFailure(ImportError.notFound);
    if (status >= 400) throw ImportFailure(ImportError.network, 'HTTP $status');
  }

  Future<Object?> getJson(Uri uri) async {
    final response = await client.get(uri, headers: {'User-Agent': _userAgent}).timeout(_connectTimeout * 2);
    _checkStatus(response.statusCode);
    try {
      return jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    } on FormatException {
      throw const ImportFailure(ImportError.invalidData);
    }
  }
}

class _XtreamJob extends _Job {
  _XtreamJob(super.request, super.client, super.work, super.onProgress);

  final _categories = <ItemType, List<XtreamCategory>>{};
  final _files = <ItemType, File>{};

  @override
  Future<void> fetch() async {
    onProgress(const ImportProgress(ImportStage.connecting));
    final account = XtreamAccount.fromJson(await getJson(xtreamUri(source)));
    expiresAt = account.expiresAt;
    maxConnections = account.maxConnections;
    serverOffset = account.serverOffset;

    final wanted = <(ItemType, String, String, ImportStage)>[
      (ItemType.live, 'get_live_categories', 'get_live_streams', ImportStage.downloadingLive),
      if (source.withMovies) (ItemType.movie, 'get_vod_categories', 'get_vod_streams', ImportStage.downloadingMovies),
      if (source.withSeries) (ItemType.series, 'get_series_categories', 'get_series', ImportStage.downloadingSeries),
    ];
    for (final (type, categoryAction, listAction, stage) in wanted) {
      onProgress(ImportProgress(stage));
      _categories[type] = XtreamCategory.listFrom(await getJson(xtreamUri(source, categoryAction)));
      final file = File('${work.path}/${type.name}.json');
      await download(xtreamUri(source, listAction), file, stage);
      _files[type] = file;
    }
  }

  @override
  Future<Map<ItemType, TypeReport>> write(Database db, int now, bool force, void Function() tick) async {
    final reports = <ItemType, TypeReport>{};
    for (final MapEntry(key: type, value: file) in _files.entries) {
      final sync = TypeSync(db, source.id, type, now);
      try {
        for (final c in _categories[type]!) {
          sync.declareCategory(c.remoteId, c.name);
        }
        await for (final object in splitJsonArray(file.openRead())) {
          final entry = xtreamEntry(type, object);
          if (entry == null) continue;
          sync.add(entry);
          tick();
        }
        reports[type] = sync.finish(force: force);
      } finally {
        sync.close();
      }
    }
    return reports;
  }
}

class _PlaylistJob extends _Job {
  _PlaylistJob(super.request, super.client, super.work, super.onProgress);

  late File _file;

  @override
  Future<void> fetch() async {
    if (source.kind == SourceKind.m3uUrl) {
      _file = File('${work.path}/playlist.m3u');
      onProgress(const ImportProgress(ImportStage.downloadingPlaylist));
      await download(Uri.parse(source.url), _file, ImportStage.downloadingPlaylist);
      return;
    }
    final original = File(source.url);
    final copy = request.playlistCopy == null ? null : File(request.playlistCopy!);
    if (original.existsSync()) {
      _file = original;
    } else if (copy != null && copy.existsSync()) {
      _file = copy;
    } else {
      throw const ImportFailure(ImportError.fileMissing);
    }
  }

  @override
  Future<Map<ItemType, TypeReport>> write(Database db, int now, bool force, void Function() tick) async {
    final parser = M3uParser();
    final syncs = <ItemType, TypeSync>{
      ItemType.live: TypeSync(db, source.id, ItemType.live, now),
      if (source.withMovies) ItemType.movie: TypeSync(db, source.id, ItemType.movie, now),
      if (source.withSeries) ItemType.series: TypeSync(db, source.id, ItemType.series, now),
    };
    try {
      await for (final entry in parser.parse(_file.openRead())) {
        final sync = syncs[entry.type];
        if (sync == null) continue;
        sync.add(entry);
        tick();
      }
      epgUrl = parser.epgUrl;
      return {for (final MapEntry(key: type, value: sync) in syncs.entries) type: sync.finish(force: force)};
    } finally {
      for (final sync in syncs.values) {
        sync.close();
      }
    }
  }
}
