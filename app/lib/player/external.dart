import 'dart:io';

import 'package:flutter/services.dart';

import 'playback.dart';

const _device = MethodChannel('chud_iptv/device');

/// Arguments donnés à un lecteur externe. VLC comprend le titre et les en-têtes ; un autre lecteur
/// reçoit simplement l'adresse.
List<String> externalArguments(String player, PlayItem item) {
  final isVlc = player.toLowerCase().contains('vlc');
  final headers = item.request.headers;
  return [
    if (isVlc) '--meta-title=${item.title}',
    if (isVlc && headers['User-Agent'] != null) '--http-user-agent=${headers['User-Agent']}',
    if (isVlc && headers['Referer'] != null) '--http-referrer=${headers['Referer']}',
    item.request.url,
  ];
}

/// Cherche VLC là où il s'installe d'habitude. Null s'il n'y est pas : aucun lecteur externe n'est
/// obligatoire.
Future<String?> detectVlc() async {
  if (Platform.isWindows) {
    final bases = [Platform.environment['ProgramFiles'], Platform.environment['ProgramFiles(x86)']];
    for (final base in bases) {
      if (base == null) continue;
      final path = '$base\\VideoLAN\\VLC\\vlc.exe';
      if (File(path).existsSync()) return path;
    }
    return null;
  }
  if (Platform.isLinux) {
    final result = await Process.run('which', ['vlc']);
    final path = '${result.stdout}'.trim();
    return result.exitCode == 0 && path.isNotEmpty ? path : null;
  }
  return null;
}

/// Vrai si cette plateforme propose un lecteur externe sans réglage : le choix d'Android.
bool get systemChoosesPlayer => Platform.isAndroid;

/// Ouvre [item] dans [player] (chemin d'un programme), ou le sélecteur d'Android.
/// Renvoie faux si rien n'a pu être lancé.
Future<bool> openExternally(String player, PlayItem item) async {
  try {
    if (Platform.isAndroid) {
      return await _device.invokeMethod<bool>('openExternal', {'url': item.request.url, 'title': item.title}) ?? false;
    }
    if (player.isEmpty) return false;
    await Process.start(player, externalArguments(player, item), mode: ProcessStartMode.detached);
    return true;
  } on ProcessException {
    return false;
  } on PlatformException {
    return false;
  }
}
