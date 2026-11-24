import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'playback.dart';

/// Compilation de diagnostic (`--dart-define=CHUD_MPV_LOG=true`) : le journal du moteur part dans
/// les logs. Jamais dans une version publiée : il contient les adresses, donc les identifiants.
const _mpvLog = bool.fromEnvironment('CHUD_MPV_LOG');

/// Lecture par libmpv, à travers media_kit.
class MediaKitEngine implements PlaybackEngine {
  MediaKitEngine._(this._player, this._video);

  final Player _player;
  final VideoController _video;

  static Future<PlaybackEngine> create({required bool software}) async {
    final player = Player(
      configuration: const PlayerConfiguration(
        title: 'Chud IPTV',
        bufferSize: 32 * 1024 * 1024,
        logLevel: _mpvLog ? MPVLogLevel.v : MPVLogLevel.error,
      ),
    );
    if (_mpvLog) player.stream.log.listen((l) => debugPrint('mpv ${l.prefix} ${l.level} ${l.text.trim()}'));
    final native = player.platform as NativePlayer;
    await native.setProperty('user-agent', 'ChudIPTV/1');
    await native.setProperty('network-timeout', '8');
    // Une micro-coupure se rattrape au niveau du flux, avant même que l'image ne se fige.
    await native.setProperty('stream-lavf-o', 'reconnect=1,reconnect_streamed=1,reconnect_delay_max=2');
    await native.setProperty('cache', 'yes');
    await native.setProperty('cache-secs', '12');
    await native.setProperty('deinterlace', Platform.isAndroid ? 'no' : 'auto');
    // Sur Android, le décodeur écrit directement dans la surface : c'est ce qui tient sur un
    // téléviseur peu puissant. Il ne connaît pas tous les formats, d'où le repli logiciel.
    final configuration = !Platform.isAndroid
        ? const VideoControllerConfiguration()
        : software
            ? const VideoControllerConfiguration(vo: 'gpu', hwdec: 'no')
            : const VideoControllerConfiguration(vo: 'mediacodec_embed', hwdec: 'mediacodec');
    final video = VideoController(player, configuration: configuration);
    if (Platform.isAndroid && !software) await _prepareSurface(player, video);
    return MediaKitEngine._(player, video);
  }

  /// media_kit ne crée la surface Android qu'une fois la taille de la vidéo connue : le flux
  /// s'ouvre donc dans le vide, puis se rouvre, soit plusieurs secondes de noir sur un film.
  /// On la crée d'avance. En cas d'échec, la lecture part quand même, simplement plus lentement.
  static Future<void> _prepareSurface(Player player, VideoController video) async {
    try {
      await video.platform.future;
      await const MethodChannel('com.alexmercerind/media_kit_video').invokeMethod('VideoOutputManager.SetSurfaceSize', {
        'handle': '${await player.handle}',
        'width': '1920',
        'height': '1080',
      });
      final native = player.platform as NativePlayer;
      for (var i = 0; i < 30; i++) {
        if (await native.getProperty('wid') != '0') return;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    } catch (_) {
      // Voir ci-dessus : ce n'est qu'une optimisation.
    }
  }

  @override
  bool get canFallBack => Platform.isAndroid;

  @override
  Stream<Duration> get position => _player.stream.position;

  @override
  Stream<Duration> get duration => _player.stream.duration;

  @override
  Stream<bool> get playing => _player.stream.playing;

  @override
  Stream<String> get errors => _player.stream.error;

  @override
  Stream<void> get ended => _player.stream.completed.where((done) => done);

  @override
  Future<void> open(PlayRequest request, {Duration? start}) =>
      _player.open(Media(request.url, httpHeaders: request.headers, start: start));

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setPaused(bool paused) => paused ? _player.pause() : _player.play();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setVolume(double percent) => _player.setVolume(percent);

  @override
  Future<void> setVideoEnabled(bool enabled) => (_player.platform as NativePlayer).setProperty('vid', enabled ? 'auto' : 'no');

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Widget buildVideo() => Video(
        controller: _video,
        controls: NoVideoControls,
        fill: Colors.black,
        pauseUponEnteringBackgroundMode: false,
        resumeUponEnteringForegroundMode: false,
      );
}
