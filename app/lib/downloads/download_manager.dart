import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/repository.dart';
import '../models/catalog.dart';
import '../models/download.dart';
import '../models/source.dart';
import '../player/streams.dart';
import 'device_folder.dart';
import 'downloader.dart';

/// File des téléchargements. Un seul à la fois : les abonnements limitent les connexions, et
/// les films sont lourds. Tout passe par l'état gardé en base, pour reprendre après un arrêt.
class DownloadManager extends ChangeNotifier {
  DownloadManager({required this.repository, required this.sourceOf, required this.folder, this.exportFolder, this.documents, DownloadRunner? runner})
      : _runner = runner ?? downloadInIsolate;

  final Repository repository;
  final Source? Function(int id) sourceOf;

  /// Dossier des nouveaux téléchargements.
  final String Function() folder;

  /// Android : dossier choisi par l'utilisateur, où le fichier terminé est copié. Le téléchargement
  /// lui-même reste dans [folder], seul endroit où une reprise est possible.
  final String? Function()? exportFolder;
  final DocumentStore? documents;
  final DownloadRunner _runner;

  List<Download> entries = const [];
  Download? _current;
  DownloadHandle? _handle;

  /// État donné au téléchargement en cours quand on l'arrête : pause, ou retour dans la file.
  DownloadState _stopAs = DownloadState.paused;

  /// Se termine quand le téléchargement en cours a rendu la main, quoi qu'il lui soit arrivé.
  Completer<void>? _released;
  int _holds = 0;

  /// Suppressions en cours : la file attend la dernière, pour ne pas démarrer ce qu'on efface.
  int _removing = 0;

  /// Une lecture en ligne utilise la connexion de l'abonnement : la file attend.
  bool get held => _holds > 0;

  /// Reprend ce qu'un arrêt de l'app a interrompu.
  Future<void> start() async {
    entries = await repository.downloads();
    for (final d in entries) {
      if (d.state == DownloadState.active) _move(d, DownloadState.queued);
      if (d.state == DownloadState.done && !await _exists(d.path)) {
        _move(d, DownloadState.failed, error: DownloadError.missing);
        await repository.saveDownload(d);
      }
    }
    notifyListeners();
    unawaited(_pump());
  }

  Future<bool> _exists(String path) async {
    if (isDocument(path)) return await documents?.exists(path) ?? false;
    return File(path).existsSync();
  }

  Download? find(int sourceId, ItemType type, String streamKey) =>
      entries.where((d) => d.sourceId == sourceId && d.type == type && d.streamKey == streamKey).firstOrNull;

  String _uniquePath(String base, String extension) {
    final name = safeFileName(base);
    bool taken(String path) => File(path).existsSync() || File('$path.part').existsSync() || entries.any((d) => d.path == path);
    var path = '${folder()}${Platform.pathSeparator}$name.$extension';
    for (var i = 2; taken(path); i++) {
      path = '${folder()}${Platform.pathSeparator}$name ($i).$extension';
    }
    return path;
  }

  /// Ajoute un contenu à la file. Null si c'est une liste HLS, qui ne s'enregistre pas en un fichier.
  Future<Download?> enqueue({
    required int sourceId,
    required ItemType type,
    required String streamKey,
    required String title,
    required String fileName,
    String subtitle = '',
    String logo = '',
    String extension = '',
    String url = '',
    String headers = '',
  }) async {
    final known = find(sourceId, type, streamKey);
    if (known != null) return known;
    final ext = videoExtension(extension, url);
    if (isSegmented(ext)) return null;
    final download = Download(
      sourceId: sourceId,
      type: type,
      streamKey: streamKey,
      title: title,
      subtitle: subtitle,
      logo: logo,
      extension: ext,
      url: url,
      headers: headers,
      path: _uniquePath(fileName, ext),
    );
    download.id = await repository.addDownload(download);
    entries = [...entries, download];
    notifyListeners();
    unawaited(_pump());
    return download;
  }

  /// Le film d'une fiche du catalogue, ou la vidéo d'une playlist.
  Future<Download?> enqueueItem(Item item) async {
    final info = await repository.streamInfo(item.id);
    if (info == null) return null;
    return enqueue(
      sourceId: item.sourceId,
      type: item.type,
      streamKey: info.stableKey,
      title: item.name,
      subtitle: item.categoryName,
      logo: item.logo,
      fileName: item.name,
      extension: info.extension,
      url: info.url,
      headers: info.httpHeaders,
    );
  }

  Future<Download?> enqueueEpisode(Source source, String series, String logo, int season, Episode episode) {
    String two(int n) => n.toString().padLeft(2, '0');
    final code = 'S${two(season)}E${two(episode.number)}';
    return enqueue(
      sourceId: source.id,
      type: ItemType.series,
      streamKey: 'id:${episode.id}',
      title: episode.title.isEmpty || episode.title == code ? code : '$code · ${episode.title}',
      subtitle: series,
      logo: episode.image.isEmpty ? logo : episode.image,
      fileName: '$series $code',
      extension: episode.extension,
    );
  }

  Future<void> _stopCurrent(DownloadState state) async {
    final handle = _handle;
    if (handle == null) return;
    _stopAs = state;
    handle.stop();
    // La fin du téléchargement passe par _pump : on attend qu'il ait rendu la main.
    await _released?.future;
  }

  /// Seul endroit où l'état d'un téléchargement change. Une erreur n'existe qu'avec un échec.
  void _move(Download d, DownloadState next, {DownloadError? error}) {
    assert(d.state.canBecome(next), 'Passage imprévu : ${d.state} → $next');
    if (!d.state.canBecome(next)) return;
    d.state = next;
    d.error = next == DownloadState.failed ? error : null;
  }

  Future<void> pause(Download d) async {
    if (d == _current) {
      await _stopCurrent(DownloadState.paused);
    } else if (d.state == DownloadState.queued) {
      _move(d, DownloadState.paused);
      await _saved(d);
    }
  }

  /// Reprend un téléchargement en pause ou en échec, depuis ce qui est déjà sur le disque.
  Future<void> resume(Download d) async {
    if (d.state != DownloadState.paused && d.state != DownloadState.failed) return;
    _move(d, DownloadState.queued);
    await _saved(d);
    unawaited(_pump());
  }

  /// Retire un téléchargement, son fichier compris. Un fichier impossible à effacer (ouvert dans un
  /// autre lecteur) laisse la ligne en place et l'erreur remonte ; la file, elle, repart toujours.
  Future<void> remove(Download d) async {
    _removing++;
    try {
      if (d == _current) await _stopCurrent(DownloadState.paused);
      await _deleteFiles(d);
      await repository.deleteDownload(d.id);
      entries = entries.where((e) => e != d).toList();
    } finally {
      _removing--;
      notifyListeners();
      unawaited(_pump());
    }
  }

  Future<void> _deleteFiles(Download d) async {
    if (isDocument(d.path)) return documents?.delete(d.path);
    for (final path in [d.path, d.part]) {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    }
  }

  /// Pour « tout effacer » : plus rien ne tourne, plus aucun fichier ne reste.
  Future<void> clear() async {
    _removing++;
    try {
      await _stopCurrent(DownloadState.paused);
      for (final d in entries) {
        try {
          await _deleteFiles(d);
        } on Exception {
          // Fichier ouvert par un autre programme : il reste, le reste de l'effacement continue.
        }
      }
      entries = const [];
    } finally {
      _removing--;
      notifyListeners();
    }
  }

  /// Une lecture en ligne commence. Si l'abonnement n'a qu'une connexion, le téléchargement lui
  /// laisse la place et reprendra tout seul.
  Future<void> hold() async {
    _holds++;
    final current = _current;
    if (current == null) return;
    final connections = sourceOf(current.sourceId)?.maxConnections ?? 1;
    if (connections < 2) await _stopCurrent(DownloadState.queued);
    notifyListeners();
  }

  void release() {
    if (_holds > 0) _holds--;
    notifyListeners();
    unawaited(_pump());
  }

  Future<void> _saved(Download d) async {
    notifyListeners();
    await repository.saveDownload(d);
  }

  Map<String, String> _headers(String json) {
    if (json.isEmpty) return const {};
    try {
      return (jsonDecode(json) as Map<String, dynamic>).map((k, v) => MapEntry(k, '$v'));
    } on FormatException {
      return const {};
    }
  }

  DownloadJob? _job(Download d) {
    if (d.url.isNotEmpty) return DownloadJob(url: d.url, part: d.part, headers: _headers(d.headers));
    final source = sourceOf(d.sourceId);
    if (source == null) return null;
    final info = StreamInfo(type: d.type, stableKey: d.streamKey, extension: d.extension);
    return DownloadJob(url: playRequest(source, info).url, part: d.part);
  }

  Future<void> _pump() async {
    if (_handle != null || held || _removing > 0) return;
    final next = entries.where((d) => d.state == DownloadState.queued).firstOrNull;
    if (next == null) return;
    final job = _job(next);
    if (job == null) {
      _move(next, DownloadState.failed, error: DownloadError.source);
      await _saved(next);
      return _pump();
    }
    _move(next, DownloadState.active);
    _stopAs = DownloadState.paused;
    _current = next;
    final handle = _runner(job, (received, total) {
      next.received = received;
      next.total = total ?? next.total;
      notifyListeners();
    });
    _handle = handle;
    final released = _released = Completer<void>();
    notifyListeners();
    try {
      await _finish(next, await handle.end);
    } catch (_) {
      // Rien ne doit retenir la place : une lecture attend qu'elle soit rendue (voir hold).
      if (next.state == DownloadState.active) _move(next, DownloadState.failed, error: DownloadError.network);
    } finally {
      _current = null;
      _handle = null;
      released.complete();
    }
    notifyListeners();
    unawaited(_pump());
  }

  Future<void> _finish(Download d, DownloadEnd end) async {
    if (end.stopped) {
      _move(d, _stopAs);
    } else if (end.error != null) {
      _move(d, DownloadState.failed, error: end.error);
    } else {
      try {
        await File(d.part).rename(d.path);
        _move(d, DownloadState.done);
        d.total = d.received = File(d.path).lengthSync();
        await _export(d);
      } on FileSystemException {
        _move(d, DownloadState.failed, error: DownloadError.disk);
      }
    }
    await repository.saveDownload(d);
  }

  /// Un échec de copie ne perd rien : le fichier reste lisible dans le dossier de l'app.
  Future<void> _export(Download d) async {
    final target = exportFolder?.call();
    final store = documents;
    if (target == null || store == null) return;
    final local = File(d.path);
    final String? uri;
    try {
      uri = await store.save(target, d.path, d.path.split(Platform.pathSeparator).last);
    } on Exception {
      // Le système a répondu par une erreur plutôt que par un refus : même issue, le fichier reste.
      return;
    }
    if (uri == null) return;
    d.path = uri;
    await local.delete();
  }

  @override
  void dispose() {
    _handle?.stop();
    super.dispose();
  }
}
