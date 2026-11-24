import 'dart:async';

import 'package:flutter/services.dart';

/// Ce qu'un téléphone sait faire de plus pendant la lecture. Absent sur TV, tablette et ordinateur.
abstract class PhonePlayback {
  bool get supportsPip;

  /// L'app passe dans la petite fenêtre, ou en revient.
  Stream<bool> get pipChanges;

  /// L'utilisateur a touché « Arrêter » dans la notification.
  Stream<void> get radioStopped;

  /// Prêt : quitter l'app ouvre la petite fenêtre.
  Future<void> setPipReady(bool ready);

  /// Android refuse de lancer ce service depuis l'arrière-plan : il démarre pendant que le lecteur
  /// est à l'écran. Vrai s'il tourne.
  Future<bool> startRadio(String title, String text, String stopLabel);
  Future<void> stopRadio();

  /// Sans cette autorisation, Android 13 et plus masquent la notification de lecture.
  Future<void> askNotifications();
}

class AndroidPhonePlayback implements PhonePlayback {
  AndroidPhonePlayback._(this.supportsPip) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pipChanged') _pip.add(call.arguments as bool);
      if (call.method == 'radioStopped') _stopped.add(null);
    });
  }

  static const _channel = MethodChannel('chud_iptv/device');

  /// Null si l'appareil n'est pas un téléphone : la largeur vient d'Android, seule source sûre au démarrage.
  static Future<AndroidPhonePlayback?> create() async {
    final features = await _channel.invokeMapMethod<String, bool>('phoneFeatures');
    if (features?['phone'] != true) return null;
    return AndroidPhonePlayback._(features?['pip'] == true);
  }

  @override
  final bool supportsPip;

  final _pip = StreamController<bool>.broadcast();
  final _stopped = StreamController<void>.broadcast();

  @override
  Stream<bool> get pipChanges => _pip.stream;

  @override
  Stream<void> get radioStopped => _stopped.stream;

  @override
  Future<void> setPipReady(bool ready) => _channel.invokeMethod('setPipReady', ready);

  @override
  Future<bool> startRadio(String title, String text, String stopLabel) async =>
      await _channel.invokeMethod<bool>('startRadio', {'title': title, 'text': text, 'stop': stopLabel}) ?? false;

  @override
  Future<void> stopRadio() => _channel.invokeMethod('stopRadio');

  @override
  Future<void> askNotifications() => _channel.invokeMethod('askNotifications');
}
