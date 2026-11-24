import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as ed;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'release.dart';

/// Où en est la mise à jour. Chaque état a son message : aucun n'annonce un succès non vérifié.
/// Seul `Updater._set` le change, et il refuse un passage imprévu.
enum UpdateStage {
  idle,
  checking,
  upToDate,
  available,
  downloading,
  verifying,
  restarting,
  handedToSystem,
  cancelled,
  failed;

  /// Une recherche ou une installation tourne : rien d'autre ne démarre, rien ne la recouvre.
  bool get isWorking => this == checking || this == downloading || this == verifying || this == restarting;

  /// Les seuls passages permis. Un nouvel état s'ajoute ici, et dans `test/update_test.dart`.
  bool canBecome(UpdateStage next) => switch (this) {
        // Au repos : une recherche démarre, ou une vérification de fond conclut.
        idle || upToDate => next == checking || next == idle || next == available,
        // Au repos avec une version connue : l'installation peut aussi partir, ou repartir.
        available || handedToSystem || cancelled || failed => next == checking || next == idle || next == available || next == downloading,
        checking => next == upToDate || next == available || next == failed,
        downloading => next == verifying || next == restarting || next == handedToSystem || next == cancelled || next == failed,
        verifying => next == restarting || next == handedToSystem || next == failed,
        // L'app se ferme ; elle ne revient ici que si le redémarrage a échoué.
        restarting => next == failed,
      };
}

/// Pourquoi une mise à jour a échoué.
enum UpdateFailure { network, signature, integrity, install }

/// Ce qui se passe après l'installation.
enum _Outcome { restarting, handedToSystem }

class _Cancelled implements Exception {}

class _BadSignature implements Exception {}

/// Cherche, vérifie et installe les nouvelles versions publiées à [baseUrl].
///
/// `latest.json` est signé : une version annoncée sans signature valide n'est jamais proposée.
/// Il porte l'empreinte de chaque installeur, vérifiée avant toute installation. Android exige
/// la confirmation du système ; Windows et Linux remplacent l'app puis la relancent.
class Updater extends ChangeNotifier {
  Updater({http.Client? client, this.baseUrl = releasesUrl, this.publicKey = updatePublicKey, String? platform, this.onRestart})
      : _client = client ?? http.Client(),
        platform = platform ?? platformKey;

  final String baseUrl;
  final String publicKey;

  /// Clé de cet appareil dans `latest.json`.
  final String? platform;

  /// Appelé quand l'app doit se fermer pour laisser la place à sa nouvelle version.
  Future<void> Function(String version)? onRestart;
  final http.Client _client;

  UpdateStage stage = UpdateStage.idle;
  UpdateFailure? failure;
  Release? release;
  double progress = 0;
  bool _cancelled = false;

  bool get enabled => baseUrl.isNotEmpty && publicKey.isNotEmpty && !publicKey.startsWith('@@') && platform != null;
  bool get working => stage.isWorking;

  static String? get platformKey {
    if (Platform.isAndroid) {
      // Platform.version se termine par exemple par « on "android_arm64" ».
      if (Platform.version.contains('android_arm64')) return 'android-arm64';
      if (Platform.version.contains('android_arm')) return 'android-arm';
      return null;
    }
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return null;
  }

  void _set(UpdateStage next, {UpdateFailure? error}) {
    assert(stage.canBecome(next), 'Passage imprévu : $stage → $next');
    if (!stage.canBecome(next)) return;
    stage = next;
    failure = error;
    notifyListeners();
  }

  /// Cherche une version plus récente que [current]. [quiet] : vérification de fond, qui n'affiche
  /// aucune erreur et ne recouvre pas une mise à jour déjà en cours.
  Future<void> check(String current, {bool quiet = false}) async {
    if (!enabled || current.isEmpty || working) return;
    if (!quiet) _set(UpdateStage.checking);
    try {
      final manifest = await _fetch('latest.json');
      final signature = await _fetch('latest.json.sig');
      final genuine = await verifyManifest(manifest, signature);
      // Une recherche ou une installation a démarré pendant cette vérification de fond : elle garde
      // la main, sinon « Installer » reparaîtrait au-dessus d'un téléchargement en cours.
      if (quiet && working) return;
      if (!genuine) throw _BadSignature();
      final published = Release.fromJson(jsonDecode(utf8.decode(manifest)) as Map<String, dynamic>);
      if (compareVersions(published.version, current) > 0 && published.files.containsKey(platform)) {
        release = published;
        _set(UpdateStage.available);
      } else {
        release = null;
        _set(quiet ? UpdateStage.idle : UpdateStage.upToDate);
      }
    } on _BadSignature {
      release = null;
      _set(quiet ? UpdateStage.idle : UpdateStage.failed, error: quiet ? null : UpdateFailure.signature);
    } on Object {
      if (!quiet) _set(UpdateStage.failed, error: UpdateFailure.network);
    }
  }

  Future<Uint8List> _fetch(String name) async {
    final response = await _client.get(Uri.parse('$baseUrl/$name'), headers: const {'Cache-Control': 'no-cache'}).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw http.ClientException('HTTP ${response.statusCode}');
    return response.bodyBytes;
  }

  @visibleForTesting
  Future<bool> verifyManifest(List<int> manifest, List<int> signature) async {
    try {
      final key = ed.SimplePublicKey(base64.decode(publicKey), type: ed.KeyPairType.ed25519);
      return await ed.Ed25519().verify(manifest, signature: ed.Signature(base64.decode(utf8.decode(signature).trim()), publicKey: key));
    } on Object {
      return false;
    }
  }

  void cancel() => _cancelled = true;

  /// Télécharge, vérifie et installe la version proposée.
  Future<void> install() async {
    final target = release;
    if (target == null || working) return;
    _cancelled = false;
    progress = 0;
    _set(UpdateStage.downloading);
    try {
      final outcome = await _perform(target.files[platform]!);
      if (outcome == _Outcome.handedToSystem) {
        _set(UpdateStage.handedToSystem);
        return;
      }
      _set(UpdateStage.restarting);
      await onRestart?.call(target.version);
    } on _Cancelled {
      _set(UpdateStage.cancelled);
    } on FormatException {
      _set(UpdateStage.failed, error: UpdateFailure.integrity);
    } on http.ClientException {
      _set(UpdateStage.failed, error: UpdateFailure.network);
    } on SocketException {
      _set(UpdateStage.failed, error: UpdateFailure.network);
    } on TimeoutException {
      _set(UpdateStage.failed, error: UpdateFailure.network);
    } on Object {
      _set(UpdateStage.failed, error: UpdateFailure.install);
    }
  }

  Future<_Outcome> _perform(ReleaseFile file) async {
    final url = file.url(baseUrl);
    if (Platform.isAndroid) {
      final apk = File('${(await getTemporaryDirectory()).path}/Chud-IPTV-update.apk');
      await download(url, file, apk);
      final opened = await OpenFilex.open(apk.path, type: 'application/vnd.android.package-archive');
      if (opened.type != ResultType.done) throw StateError(opened.message);
      return _Outcome.handedToSystem;
    }
    if (Platform.isWindows) return _installWindows(url, file);
    if (Platform.environment['APPIMAGE'] != null) return _installLinux(url, file);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw StateError('Lien non ouvert');
    return _Outcome.handedToSystem;
  }

  /// Windows : l'archive est vérifiée et dépliée à côté, puis un script attend la fermeture de
  /// l'app pour remplacer ses fichiers et la relancer. Sans droits administrateur tant que l'app
  /// est dans un dossier de l'utilisateur ; sinon, on ouvre simplement le téléchargement.
  Future<_Outcome> _installWindows(Uri url, ReleaseFile file) async {
    final exe = Platform.resolvedExecutable;
    final dir = File(exe).parent.path;
    try {
      final probe = File('$dir\\.update-check')..writeAsStringSync('');
      probe.deleteSync();
    } on FileSystemException {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return _Outcome.handedToSystem;
    }
    final work = Directory('${Directory.systemTemp.path}\\chud-iptv-update');
    if (work.existsSync()) work.deleteSync(recursive: true);
    work.createSync(recursive: true);
    final zip = File('${work.path}\\update.zip');
    await download(url, file, zip);
    final script = File('${work.path}\\update.ps1')..writeAsStringSync(_windowsScript);
    final command = windowsScriptCommand(script: script.path, processId: pid, zip: zip.path, dir: dir, exe: exe);
    await Process.start(command.first, command.sublist(1), mode: ProcessStartMode.detached);
    return _Outcome.restarting;
  }

  /// Commande qui lance le script sans dépendre de l'app, qui va se fermer. PowerShell lancé
  /// directement en mode détaché n'a pas de console et s'arrête sans rien exécuter : `start` de cmd
  /// lui en donne une, masquée. Son premier argument, le titre, contient une espace pour que Dart
  /// l'entoure de guillemets, sans quoi `start` le prendrait pour la commande.
  @visibleForTesting
  static List<String> windowsScriptCommand({required String script, required int processId, required String zip, required String dir, required String exe}) => [
        'cmd.exe', '/c', 'start', 'Chud IPTV', '/min', 'powershell.exe',
        '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden',
        '-File', script, '-ProcessId', '$processId', '-Zip', zip, '-Dir', dir, '-Exe', exe,
      ];

  /// L'ancienne version est copiée avant tout remplacement, et remise en place au moindre échec.
  /// (Sans accents : Windows PowerShell lit ce fichier sans en connaître l'encodage.)
  static const _windowsScript = r'''
param([int]$ProcessId, [string]$Zip, [string]$Dir, [string]$Exe)
try { Wait-Process -Id $ProcessId -Timeout 60 -ErrorAction Stop } catch {}
Start-Sleep -Milliseconds 500
$work = Split-Path $Zip
$staging = Join-Path $work 'files'
$old = Join-Path $work 'old'
$done = $false
try {
  Expand-Archive -LiteralPath $Zip -DestinationPath $staging -Force -ErrorAction Stop
  $found = Get-ChildItem -LiteralPath $staging -Recurse -Filter (Split-Path $Exe -Leaf) | Select-Object -First 1
  if (-not $found) { throw 'executable absent' }
  New-Item -ItemType Directory -Path $old -Force | Out-Null
  Get-ChildItem -LiteralPath $Dir | Copy-Item -Destination $old -Recurse -Force -ErrorAction Stop
  Get-ChildItem -LiteralPath $found.DirectoryName | Copy-Item -Destination $Dir -Recurse -Force -ErrorAction Stop
  $done = $true
} catch {
  if (Test-Path -LiteralPath $old) {
    Get-ChildItem -LiteralPath $old | Copy-Item -Destination $Dir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
Start-Process -FilePath $Exe
if ($done) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
''';

  /// Linux (AppImage) : le nouveau fichier remplace l'ancien, puis l'app se relance.
  Future<_Outcome> _installLinux(Uri url, ReleaseFile file) async {
    final target = Platform.environment['APPIMAGE']!;
    final next = File('$target.update');
    await download(url, file, next);
    final chmod = await Process.run('chmod', ['755', next.path]);
    if (chmod.exitCode != 0) throw StateError('chmod : ${chmod.stderr}');
    await next.rename(target);
    await Process.start(target, const [], mode: ProcessStartMode.detached);
    return _Outcome.restarting;
  }

  /// Télécharge [url] dans [out] et vérifie son empreinte. Une annulation ou un fichier faux ne
  /// laissent rien derrière eux.
  @visibleForTesting
  Future<void> download(Uri url, ReleaseFile file, File out) async {
    final response = await _client.send(http.Request('GET', url)).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw http.ClientException('HTTP ${response.statusCode}');
    final total = response.contentLength ?? file.size;
    final sink = out.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream.timeout(const Duration(seconds: 30))) {
        if (_cancelled) throw _Cancelled();
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          progress = (received / total).clamp(0.0, 1.0);
          notifyListeners();
        }
      }
      await sink.close();
      stage = UpdateStage.verifying;
      notifyListeners();
      final digest = await sha256.bind(out.openRead()).first;
      if (digest.toString() != file.sha256.toLowerCase()) throw const FormatException('Empreinte incorrecte');
    } catch (_) {
      await sink.close();
      if (out.existsSync()) await out.delete();
      rethrow;
    }
  }
}
