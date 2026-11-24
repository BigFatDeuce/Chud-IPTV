import 'dart:async';

import 'package:flutter/widgets.dart';

/// Ce qu'il faut pour ouvrir un flux.
class PlayRequest {
  const PlayRequest({required this.url, required this.live, this.headers = const {}});

  final String url;
  final bool live;
  final Map<String, String> headers;
}

/// Élément à lire, avec ce qui s'affiche pendant la lecture.
class PlayItem {
  const PlayItem({required this.title, required this.request, this.subtitle = '', this.logo = '', this.itemId});

  /// Identifiant dans le catalogue, pour l'étoile des favoris. Null pour un épisode.
  final int? itemId;
  final String title;
  final String subtitle;
  final String logo;
  final PlayRequest request;
}

/// Liste parcourue pendant la lecture : chaînes d'une catégorie, épisodes d'une saison…
abstract class PlayQueue {
  int get length;

  /// L'élément [index], ou null s'il n'est plus disponible.
  Future<PlayItem?> at(int index);
}

/// Moteur vidéo, derrière cette interface pour pouvoir le remplacer et tester la session sans vidéo.
abstract class PlaybackEngine {
  Stream<Duration> get position;
  Stream<Duration> get duration;
  Stream<bool> get playing;

  /// Message d'erreur du moteur. Il peut contenir l'adresse du flux : jamais affiché tel quel.
  Stream<String> get errors;

  /// Fin du flux : normale pour un film, mais pour une chaîne c'est une coupure.
  Stream<void> get ended;

  /// Vrai si, en cas de codec refusé, un moteur logiciel peut prendre le relais.
  bool get canFallBack;

  Future<void> open(PlayRequest request, {Duration? start});
  Future<void> stop();
  Future<void> setPaused(bool paused);
  Future<void> seek(Duration position);
  Future<void> setVolume(double percent);

  /// Sans image, le flux et le son continuent : c'est le mode radio.
  Future<void> setVideoEnabled(bool enabled);
  Future<void> dispose();
  Widget buildVideo();
}

typedef EngineFactory = Future<PlaybackEngine> Function({required bool software});

/// Où en est la lecture. [failed] et [ended] attendent l'utilisateur : seule une nouvelle ouverture
/// en sort. Tout changement passe par `PlaybackSession._setState`, qui refuse un passage imprévu.
enum PlaybackState {
  opening,
  playing,
  reconnecting,
  failed,
  ended;

  /// Vrai tant que la session travaille seule, faux quand elle attend l'utilisateur.
  bool get isActive => this != failed && this != ended;

  /// Les seuls passages permis. Un nouvel état s'ajoute ici, et dans `test/playback_test.dart`.
  bool canBecome(PlaybackState next) => switch (this) {
        opening || reconnecting => true,
        playing => next != playing,
        failed || ended => next == opening,
      };
}

/// Pilote la lecture d'un flux et le maintient en vie.
///
/// Le moteur ne signale pas toujours les pannes : un flux coupé fige simplement l'image, sans
/// erreur. La session surveille donc que la position avance et rouvre le flux sinon, vite d'abord
/// (micro-coupure), puis en espaçant les essais, avant de rendre la main à l'utilisateur.
class PlaybackSession extends ChangeNotifier {
  PlaybackSession(this._factory);

  /// Attente avant chaque nouvel essai, en secondes.
  static const retryDelays = [0, 1, 2, 3, 5, 5, 8, 8];
  static const openLimit = 15;
  static const liveStallLimit = 5;

  /// Secondes sans image au bout desquelles l'utilisateur est prévenu.
  static const stallNotice = 2;
  static const vodStallLimit = 20;

  /// Secondes de lecture stable qui remettent le compteur d'essais à zéro.
  static const steadySeconds = 20;

  final EngineFactory _factory;

  PlaybackEngine? engine;
  PlayRequest? _request;
  PlaybackState state = PlaybackState.opening;

  /// Essai de reconnexion en cours, de 1 à [retryDelays].length.
  int attempt = 0;
  Duration positionNow = Duration.zero;
  Duration durationNow = Duration.zero;
  bool paused = false;
  double volume = 100;

  bool _software = false;
  bool _suspended = false;
  bool _videoEnabled = true;
  bool _disposed = false;

  /// Numéro de l'ouverture demandée en dernier : ce qui attendait pour une précédente s'arrête là.
  int _turn = 0;

  /// Change à chaque moteur abandonné : celui qui naît trop tard est libéré sans avoir servi.
  int _engineEpoch = 0;
  Future<bool>? _creating;
  int _silent = 0;
  int _steady = 0;
  Duration? _resumeAt;
  Timer? _watchdog;
  Timer? _retry;
  final _subscriptions = <StreamSubscription<Object?>>[];

  bool get live => _request?.live ?? true;

  /// L'image ne bouge plus, sans qu'on ait encore relancé le flux.
  bool stalling = false;

  /// Il y a quelque chose à dire à l'utilisateur : tout sauf une lecture qui avance.
  bool get interrupted => state != PlaybackState.playing || stalling;

  Future<void> open(PlayRequest request, {Duration? start}) async {
    final turn = ++_turn;
    _request = request;
    _retry?.cancel();
    _retry = null;
    attempt = 0;
    _steady = 0;
    _resumeAt = start;
    stalling = false;
    positionNow = Duration.zero;
    durationNow = Duration.zero;
    paused = false;
    _setState(PlaybackState.opening);
    // Le repli logiciel ne vaut que pour le flux qui l'a demandé : le suivant repart en matériel.
    if (_software) {
      _software = false;
      await _dropEngine();
    }
    final ready = await _ensureEngine();
    // Une autre chaîne a été demandée entre-temps, ou le lecteur est fermé : rien à ouvrir ici.
    if (turn != _turn || _disposed) return;
    if (ready == null) return _fail();
    _watchdog ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    await _start();
  }

  /// Nouvel essai demandé par l'utilisateur après un échec.
  Future<void> retry() async {
    final request = _request;
    if (request != null) await open(request);
  }

  /// Bouton « Rafraîchir » : un flux IPTV peut se dérégler sans que rien ne le signale. Comme changer de
  /// chaîne puis revenir, la connexion est fermée avant d'être rouverte. Un film reprend à sa place.
  Future<void> refresh() async {
    final request = _request;
    if (request == null || _suspended) return;
    final at = !request.live && positionNow > Duration.zero ? positionNow : null;
    await engine?.stop();
    await open(request, start: at);
  }

  /// L'app passe en arrière-plan : on libère le flux, souvent limité à une connexion.
  Future<void> suspend() async {
    if (_suspended) return;
    _suspended = true;
    _retry?.cancel();
    _retry = null;
    if (!live) _resumeAt = positionNow;
    await engine?.stop();
  }

  /// Retour au premier plan : la lecture reprend, à sa place pour un film.
  Future<void> resume() async {
    if (!_suspended) return;
    _suspended = false;
    attempt = 0;
    if (!state.isActive) return;
    _setState(PlaybackState.opening);
    await _start();
  }

  /// Le flux reste ouvert : l'abonnement ne voit qu'une seule connexion, sans coupure.
  Future<void> setVideoEnabled(bool enabled) async {
    _videoEnabled = enabled;
    await engine?.setVideoEnabled(enabled);
  }

  Future<void> togglePause() async {
    paused = !paused;
    _silent = 0;
    await engine?.setPaused(paused);
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    _silent = 0;
    await engine?.seek(position);
  }

  Future<void> setVolume(double percent) async {
    volume = percent.clamp(0, 100);
    await engine?.setVolume(volume);
    notifyListeners();
  }

  /// Rend le moteur, créé s'il manque. Les demandes simultanées attendent la même création : deux
  /// moteurs ouvriraient deux connexions, et l'abonnement n'en accepte souvent qu'une. Null si le
  /// lecteur a été fermé entre-temps, ou si le moteur n'a pas pu être créé.
  Future<PlaybackEngine?> _ensureEngine() async {
    while (engine == null && !_disposed) {
      final epoch = _engineEpoch;
      final born = await (_creating ??= _createEngine(epoch));
      // Raté pour de bon. Si le moteur a seulement été abandonné en route, on attend son remplaçant.
      if (!born && epoch == _engineEpoch) break;
    }
    return engine;
  }

  /// Vrai si le moteur créé est celui de la session.
  Future<bool> _createEngine(int epoch) async {
    PlaybackEngine? created;
    try {
      created = await _factory(software: _software);
    } catch (e) {
      assert(() {
        debugPrint('Moteur vidéo indisponible : $e');
        return true;
      }());
    }
    if (epoch == _engineEpoch) _creating = null;
    if (created == null) return false;
    if (_disposed || epoch != _engineEpoch) {
      await created.dispose();
      return false;
    }
    engine = created;
    _subscriptions.addAll([
      created.position.listen(_onPosition),
      created.duration.listen((d) {
        durationNow = d;
        notifyListeners();
      }),
      created.errors.listen(_onError),
      created.ended.listen((_) => _onEnded()),
    ]);
    await created.setVolume(volume);
    if (!_videoEnabled) await created.setVideoEnabled(false);
    if (!_disposed) notifyListeners();
    return true;
  }

  Future<void> _start() async {
    final request = _request;
    if (request == null || engine == null || _disposed || _suspended) return;
    _silent = 0;
    _steady = 0;
    try {
      await engine!.open(request, start: _resumeAt);
    } catch (_) {
      _scheduleRetry();
    }
  }

  void _onPosition(Duration position) {
    if (position == positionNow) return;
    positionNow = position;
    _silent = 0;
    stalling = false;
    if (state == PlaybackState.opening || state == PlaybackState.reconnecting) {
      _setState(PlaybackState.playing);
    } else {
      notifyListeners();
    }
  }

  void _onError(String message) {
    final text = message.toLowerCase();
    // Pas de sortie son : la vidéo continue, ce n'est pas une panne du flux.
    if (text.contains('audio')) return;
    final codecRefused = text.contains('could not open codec') || text.contains('video chain') || text.contains('video_out');
    if (codecRefused && engine?.canFallBack == true && !_software) {
      unawaited(_fallBack());
      return;
    }
    if (state == PlaybackState.opening || state == PlaybackState.reconnecting) _scheduleRetry();
  }

  /// Certains appareils n'ont pas de décodeur matériel pour un format (MPEG-2, souvent) :
  /// on bascule, une fois, sur le décodage logiciel.
  Future<void> _fallBack() async {
    final turn = _turn;
    _software = true;
    await _dropEngine();
    final ready = await _ensureEngine();
    if (turn != _turn || _disposed) return;
    if (ready == null) return _fail();
    await _start();
  }

  Future<void> _dropEngine() async {
    _engineEpoch++;
    _creating = null;
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _subscriptions.clear();
    final old = engine;
    engine = null;
    if (!_disposed) notifyListeners();
    await old?.dispose();
  }

  void _onEnded() {
    // Après un échec ou la fin d'un film, le moteur est arrêté : ce qu'il dit encore ne compte plus.
    if (!state.isActive) return;
    final nearEnd = durationNow > Duration.zero && positionNow >= durationNow - const Duration(seconds: 15);
    if (!live && nearEnd) {
      _setState(PlaybackState.ended);
      return;
    }
    _scheduleRetry();
  }

  void _tick() {
    if (_suspended || paused || _retry != null) return;
    if (!state.isActive) return;
    _silent++;
    if (state == PlaybackState.playing) {
      if (_silent >= stallNotice && !stalling) {
        stalling = true;
        notifyListeners();
      }
      if (_silent <= 1 && ++_steady >= steadySeconds) attempt = 0;
      if (_silent >= (live ? liveStallLimit : vodStallLimit)) _scheduleRetry();
    } else if (_silent >= openLimit) {
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retry != null || _disposed || _suspended) return;
    if (!state.isActive) return;
    if (attempt >= retryDelays.length) {
      _setState(PlaybackState.failed);
      unawaited(engine?.stop());
      return;
    }
    if (!live && positionNow > Duration.zero) _resumeAt = positionNow;
    final delay = Duration(seconds: retryDelays[attempt]);
    attempt++;
    stalling = false;
    _setState(PlaybackState.reconnecting);
    _retry = Timer(delay, () {
      _retry = null;
      unawaited(_start());
    });
  }

  /// Plus rien à tenter seul : l'utilisateur a la main, avec « Réessayer ».
  void _fail() {
    if (state.isActive) _setState(PlaybackState.failed);
  }

  /// Seul endroit où l'état change.
  void _setState(PlaybackState next) {
    assert(state.canBecome(next), 'Passage imprévu : $state → $next');
    if (!state.canBecome(next)) return;
    state = next;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watchdog?.cancel();
    _retry?.cancel();
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    unawaited(engine?.dispose());
    super.dispose();
  }
}
