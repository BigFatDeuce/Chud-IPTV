import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/download.dart';

/// Ce qu'il faut pour télécharger un fichier. L'adresse n'est jamais gardée en base pour un compte
/// Xtream : elle contient le mot de passe et se reconstruit à chaque reprise.
class DownloadJob {
  const DownloadJob({required this.url, required this.part, this.headers = const {}});

  final String url;

  /// Fichier en cours, à côté de sa destination finale.
  final String part;
  final Map<String, String> headers;
}

/// Comment un téléchargement s'est arrêté. [error] null et [stopped] faux : le fichier est complet.
class DownloadEnd {
  const DownloadEnd({this.stopped = false, this.error});

  final bool stopped;
  final DownloadError? error;
}

class _Failure implements Exception {
  const _Failure(this.error, {this.retry = false});

  final DownloadError error;

  /// Coupure passagère : on reprend où on en était.
  final bool retry;
}

const _maxAttempts = 5;
const _retryDelay = Duration(seconds: 3);
const _progressEvery = Duration(milliseconds: 500);

/// Une liste HLS (`#EXTM3U`) ou une page d'erreur n'est pas une vidéo : les enregistrer donnerait
/// un fichier illisible.
bool _isVideo(String? contentType, List<int> head) {
  final type = (contentType ?? '').toLowerCase();
  if (type.contains('mpegurl') || type.startsWith('text/')) return false;
  final start = ascii.decode(head.take(7).toList(), allowInvalid: true);
  return start != '#EXTM3U' && !start.trimLeft().startsWith('<');
}

/// Longueur totale annoncée par `Content-Range: bytes 100-199/200`.
int? _rangeTotal(String? header) => header == null ? null : int.tryParse(header.split('/').last);
int? _rangeStart(String? header) => header == null ? null : int.tryParse(RegExp(r'bytes (\d+)-').firstMatch(header)?.group(1) ?? '');

/// Une passe de téléchargement, depuis la fin de [file]. Renvoie vrai si le fichier est complet,
/// faux si [shouldStop] l'a interrompue.
Future<bool> _fetch(http.Client client, DownloadJob job, File file, bool Function() shouldStop, void Function(int, int?) onProgress) async {
  final offset = file.existsSync() ? file.lengthSync() : 0;
  final request = http.Request('GET', Uri.parse(job.url))..headers.addAll({'User-Agent': 'ChudIPTV/1', ...job.headers});
  if (offset > 0) request.headers['Range'] = 'bytes=$offset-';
  final http.StreamedResponse response;
  try {
    response = await client.send(request).timeout(const Duration(seconds: 30));
  } on TimeoutException {
    throw const _Failure(DownloadError.network, retry: true);
  } on http.ClientException {
    throw const _Failure(DownloadError.network, retry: true);
  } on SocketException {
    throw const _Failure(DownloadError.network, retry: true);
  }
  final status = response.statusCode;
  if (status == 416 && offset > 0) {
    final total = _rangeTotal(response.headers['content-range']);
    if (total == null || total == offset) return true;
  }
  if (status != 200 && status != 206) {
    throw _Failure(DownloadError.server, retry: status >= 500);
  }
  // Un serveur qui ignore la reprise renvoie tout : on repart de zéro. Une reprise au mauvais
  // endroit donnerait une vidéo corrompue.
  final resumed = status == 206 && _rangeStart(response.headers['content-range']) == offset;
  if (status == 206 && !resumed) throw const _Failure(DownloadError.server);
  final total = resumed ? _rangeTotal(response.headers['content-range']) : response.contentLength;
  var received = resumed ? offset : 0;
  final output = await file.open(mode: resumed ? FileMode.append : FileMode.write);
  var checked = resumed;
  var last = DateTime.now();
  onProgress(received, total);
  try {
    await for (final chunk in response.stream.timeout(const Duration(seconds: 45))) {
      if (shouldStop()) return false;
      if (!checked) {
        checked = true;
        if (!_isVideo(response.headers['content-type'], chunk)) throw const _Failure(DownloadError.format);
      }
      await output.writeFrom(chunk is Uint8List ? chunk : Uint8List.fromList(chunk));
      received += chunk.length;
      if (DateTime.now().difference(last) >= _progressEvery) {
        last = DateTime.now();
        onProgress(received, total);
      }
    }
  } on TimeoutException {
    throw const _Failure(DownloadError.network, retry: true);
  } on http.ClientException {
    throw const _Failure(DownloadError.network, retry: true);
  } on SocketException {
    throw const _Failure(DownloadError.network, retry: true);
  } on FileSystemException {
    throw const _Failure(DownloadError.disk);
  } finally {
    await output.close();
  }
  onProgress(received, total);
  if (received == 0 || (total != null && received < total)) throw const _Failure(DownloadError.network, retry: true);
  return true;
}

/// Télécharge jusqu'au bout en reprenant après chaque coupure. Le compteur d'essais repart à zéro
/// dès que des données arrivent : seule une panne qui dure fait échouer le téléchargement.
Future<DownloadEnd> runDownload(
  http.Client client,
  DownloadJob job,
  bool Function() shouldStop,
  void Function(int received, int? total) onProgress, {
  Duration retryDelay = _retryDelay,
}) async {
  final file = File(job.part);
  var attempts = 0;
  while (true) {
    final before = file.existsSync() ? file.lengthSync() : 0;
    try {
      await file.parent.create(recursive: true);
      final complete = await _fetch(client, job, file, shouldStop, onProgress);
      return DownloadEnd(stopped: !complete);
    } on _Failure catch (e) {
      if (!e.retry) return DownloadEnd(error: e.error);
      if ((file.existsSync() ? file.lengthSync() : 0) > before) attempts = 0;
      if (++attempts >= _maxAttempts) return DownloadEnd(error: e.error);
      final until = DateTime.now().add(retryDelay);
      while (DateTime.now().isBefore(until)) {
        if (shouldStop()) return const DownloadEnd(stopped: true);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } on FileSystemException {
      return const DownloadEnd(error: DownloadError.disk);
    }
  }
}

/// Téléchargement en cours : [stop] l'interrompt, [end] dit comment il s'est arrêté.
class DownloadHandle {
  DownloadHandle(this.end, this.stop);

  final Future<DownloadEnd> end;
  final void Function() stop;
}

typedef DownloadRunner = DownloadHandle Function(DownloadJob job, void Function(int received, int? total) onProgress);

/// Lance le téléchargement dans son isolat : un fichier de plusieurs Go ne doit pas ralentir l'interface.
DownloadHandle downloadInIsolate(DownloadJob job, void Function(int received, int? total) onProgress) {
  final port = ReceivePort();
  final exit = ReceivePort();
  final done = Completer<DownloadEnd>();
  SendPort? control;
  var stopping = false;
  void finish(DownloadEnd end) {
    if (done.isCompleted) return;
    done.complete(end);
    port.close();
    exit.close();
  }

  port.listen((message) {
    switch (message) {
      case SendPort sender:
        control = sender;
        if (stopping) sender.send(true);
      case (int received, int? total):
        onProgress(received, total);
      case (bool stopped, int? error):
        finish(DownloadEnd(stopped: stopped, error: error == null ? null : DownloadError.values[error]));
    }
  });
  exit.listen((_) => finish(const DownloadEnd(error: DownloadError.network)));
  unawaited(Isolate.spawn(_main, (job, port.sendPort), debugName: 'download', onExit: exit.sendPort));
  return DownloadHandle(done.future, () {
    stopping = true;
    control?.send(true);
  });
}

Future<void> _main((DownloadJob, SendPort) args) async {
  final (job, port) = args;
  final control = ReceivePort();
  var stop = false;
  control.listen((_) => stop = true);
  port.send(control.sendPort);
  final client = IOClient(HttpClient()..connectionTimeout = const Duration(seconds: 20));
  final end = await runDownload(client, job, () => stop, (received, total) => port.send((received, total)));
  client.close();
  control.close();
  port.send((end.stopped, end.error?.index));
}
