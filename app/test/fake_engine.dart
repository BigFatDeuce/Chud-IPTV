import 'dart:async';

import 'package:chud_iptv/player/playback.dart';
import 'package:flutter/widgets.dart';

/// Moteur factice : le test décide de ce que le flux fait.
class FakeEngine implements PlaybackEngine {
  FakeEngine({this.software = false, this.fallBack = false});

  final bool software;
  final bool fallBack;

  final _position = StreamController<Duration>.broadcast(sync: true);
  final _duration = StreamController<Duration>.broadcast(sync: true);
  final _errors = StreamController<String>.broadcast(sync: true);
  final _ended = StreamController<void>.broadcast(sync: true);

  final opens = <(PlayRequest, Duration?)>[];
  int stops = 0;
  bool disposed = false;
  bool throwOnOpen = false;
  bool? pausedNow;
  double? volumeNow;
  Duration? seekedTo;
  bool videoEnabled = true;

  void advance(Duration position) => _position.add(position);
  void error(String message) => _errors.add(message);
  void end() => _ended.add(null);
  void setDuration(Duration d) => _duration.add(d);

  @override
  Stream<Duration> get position => _position.stream;
  @override
  Stream<Duration> get duration => _duration.stream;
  @override
  Stream<bool> get playing => const Stream.empty();
  @override
  Stream<String> get errors => _errors.stream;
  @override
  Stream<void> get ended => _ended.stream;
  @override
  bool get canFallBack => fallBack;

  @override
  Future<void> open(PlayRequest request, {Duration? start}) async {
    opens.add((request, start));
    if (throwOnOpen) throw StateError('ouverture impossible');
  }

  @override
  Future<void> stop() async => stops++;
  @override
  Future<void> setPaused(bool paused) async => pausedNow = paused;
  @override
  Future<void> seek(Duration position) async => seekedTo = position;
  @override
  Future<void> setVolume(double percent) async => volumeNow = percent;
  @override
  Future<void> setVideoEnabled(bool enabled) async => videoEnabled = enabled;
  @override
  Future<void> dispose() async => disposed = true;
  @override
  Widget buildVideo() => const SizedBox.expand(key: Key('video'));
}
