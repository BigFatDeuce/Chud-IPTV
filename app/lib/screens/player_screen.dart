import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart' show defaultEnterNativeFullscreen, defaultExitNativeFullscreen;

import '../app_controller.dart';
import '../app_scope.dart';
import '../models/format.dart';
import '../player/playback.dart';
import '../theme/tokens.dart';
import '../widgets/favorites_ui.dart';
import '../widgets/logo.dart';
import '../widgets/panel.dart';

/// Ouvre le lecteur sur l'élément [index] de [queue].
Future<void> openPlayer(BuildContext context, PlayQueue queue, int index) => Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => PlayerScreen(queue: queue, index: index),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

/// Bascule du plein écran, remplaçable dans les tests.
typedef FullscreenSwitch = Future<void> Function(bool fullscreen);

Future<void> nativeFullscreen(bool fullscreen) => fullscreen ? defaultEnterNativeFullscreen() : defaultExitNativeFullscreen();

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required this.queue, required this.index});

  final PlayQueue queue;
  final int index;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  late final AppController _controller = AppScope.of(context);
  late final PlaybackSession _session = PlaybackSession(_controller.engineFactory)..addListener(_onSession);
  late final bool _television = _controller.isTelevision;

  late int _index = widget.index;
  PlayItem? _item;
  bool _fullscreen = false;
  bool _overlay = true;
  bool _started = false;
  Timer? _hideTimer;
  PlaybackState? _lastState;
  bool _stallShown = false;
  bool _holdingDownloads = false;
  bool _inPip = false;
  bool _radioRunning = false;
  bool _videoOff = false;
  String? _notice;
  Timer? _noticeTimer;
  final _phoneEvents = <StreamSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _setFullscreen(_television || _controller.settings.fullscreen, remember: false);
    final phone = _controller.phone;
    if (phone != null) {
      _phoneEvents.add(phone.pipChanges.listen((inPip) {
        if (mounted) setState(() => _inPip = inPip);
      }));
      _phoneEvents.add(phone.radioStopped.listen((_) => _onRadioStopped()));
    }
    unawaited(_openAt(_index));
  }

  bool get _pipOffered {
    final phone = _controller.phone;
    return phone != null && phone.supportsPip && _controller.settings.pipOption;
  }

  bool get _radioOffered => _controller.phone != null && _controller.settings.radioOption;
  bool get _pipOn => _pipOffered && _controller.settings.pipActive;
  bool get _radioOn => _radioOffered && _controller.settings.radioActive;

  /// Aligne Android sur les boutons. Les demandes passent une par une, dans l'ordre : Android répond
  /// avec un temps de retard, et deux demandes croisées laisseraient un service radio lancé alors
  /// que le bouton est coupé (ou l'inverse), sans que [_radioRunning] le sache.
  Future<void> _syncPhone() {
    final done = _phoneSync.then((_) => _applyPhone());
    // Une demande qui échoue ne retient pas les suivantes.
    _phoneSync = done.catchError((Object _) {});
    return done;
  }

  Future<void> _phoneSync = Future<void>.value();

  /// Le service radio démarre ici, lecteur à l'écran : Android le refuserait une fois l'app en
  /// arrière-plan.
  Future<void> _applyPhone() async {
    final phone = _controller.phone;
    final item = _item;
    // Lecteur fermé entre-temps : dispose a déjà tout rendu à Android.
    if (phone == null || item == null || !mounted) return;
    await phone.setPipReady(_pipOn);
    if (_radioOn) {
      if (!mounted) return;
      final stop = context.l10n.radioNotificationStop;
      _radioRunning = await phone.startRadio(item.title, item.subtitle, stop);
      // Fermé pendant le démarrage : dispose n'a rien vu tourner, le service est arrêté ici.
      if (_radioRunning && !mounted) {
        _radioRunning = false;
        await phone.stopRadio();
      }
    } else if (_radioRunning) {
      _radioRunning = false;
      await phone.stopRadio();
    }
  }

  void _togglePip() {
    _controller.updateSettings(_controller.settings.copyWith(pipActive: !_controller.settings.pipActive));
    unawaited(_syncPhone());
    _showOverlay();
    _tell(_controller.settings.pipActive ? context.l10n.playerPipOn : context.l10n.playerPipOff);
  }

  void _toggleRadio() {
    _controller.updateSettings(_controller.settings.copyWith(radioActive: !_controller.settings.radioActive));
    unawaited(_syncPhone());
    _showOverlay();
    _tell(_controller.settings.radioActive ? context.l10n.playerRadioOn : context.l10n.playerRadioOff);
  }

  /// Message bref au-dessus des boutons : une barre du bas les recouvrirait.
  void _tell(String text) {
    _noticeTimer?.cancel();
    setState(() => _notice = text);
    _noticeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  /// « Arrêter » dans la notification, souvent téléphone verrouillé.
  void _onRadioStopped() {
    _radioRunning = false;
    _controller.updateSettings(_controller.settings.copyWith(radioActive: false));
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) unawaited(_session.suspend());
    if (mounted) setState(() {});
  }

  void _restoreVideo() {
    if (!_videoOff) return;
    _videoOff = false;
    unawaited(_session.setVideoEnabled(true));
  }

  Future<void> _openAt(int index) async {
    final item = await widget.queue.at(index);
    if (!mounted || item == null) return;
    setState(() {
      _index = index;
      _item = item;
    });
    _showOverlay();
    unawaited(_syncPhone());
    // Un fichier téléchargé n'utilise pas la connexion de l'abonnement.
    if (!_holdingDownloads && item.request.url.startsWith('http')) {
      _holdingDownloads = true;
      await _controller.downloads.hold();
      if (!mounted) return;
    }
    await _session.open(item.request);
  }

  void _onSession() {
    if (!mounted) return;
    final state = _session.state;
    // Après une reprise, le plein écran est réappliqué : Android peut l'avoir retiré entre-temps.
    if (state == PlaybackState.playing && _lastState != state) {
      if (_fullscreen) unawaited(_controller.fullscreenSwitch(true));
      if (_overlay) _scheduleHide();
    }
    if (_session.interrupted && (state != _lastState || !_stallShown)) _showOverlay(hide: false);
    _stallShown = _session.stalling;
    _lastState = state;
    setState(() {});
  }

  void _setFullscreen(bool fullscreen, {bool remember = true}) {
    setState(() => _fullscreen = fullscreen);
    unawaited(_controller.fullscreenSwitch(fullscreen));
    if (remember) _controller.updateSettings(_controller.settings.copyWith(fullscreen: fullscreen));
  }

  void _showOverlay({bool hide = true}) {
    _hideTimer?.cancel();
    if (!_overlay && mounted) setState(() => _overlay = true);
    if (hide) _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _session.state == PlaybackState.playing) setState(() => _overlay = false);
    });
  }

  void _toggleOverlay() {
    if (_overlay && _session.state == PlaybackState.playing) {
      _hideTimer?.cancel();
      setState(() => _overlay = false);
    } else {
      _showOverlay();
    }
  }

  void _step(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.queue.length) return;
    unawaited(_openAt(next));
  }

  void _seekBy(int seconds) {
    final target = _session.positionNow + Duration(seconds: seconds);
    unawaited(_session.seek(target < Duration.zero ? Duration.zero : target));
    _showOverlay();
  }

  void _close() => Navigator.of(context).maybePop();

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final live = _session.live;
    final failed = _session.state == PlaybackState.failed;
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      if (failed) {
        unawaited(_session.retry());
      } else if (live) {
        _toggleOverlay();
      } else {
        unawaited(_session.togglePause());
        _showOverlay();
      }
    } else if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.mediaPlayPause) {
      if (!live) unawaited(_session.togglePause());
      _showOverlay();
    } else if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.channelUp) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.channelDown) {
      _step(1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      live ? _changeVolume(-5) : _seekBy(-10);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      live ? _changeVolume(5) : _seekBy(10);
    } else if ((key == LogicalKeyboardKey.keyF || key == LogicalKeyboardKey.f11) && !_television && !HardwareKeyboard.instance.isControlPressed) {
      _setFullscreen(!_fullscreen);
    } else if (key == LogicalKeyboardKey.keyR && !HardwareKeyboard.instance.isControlPressed) {
      _refresh();
    } else if (key == LogicalKeyboardKey.keyM) {
      unawaited(_session.setVolume(_session.volume > 0 ? 0 : 100));
      _showOverlay();
    } else if (key == LogicalKeyboardKey.escape) {
      if (_fullscreen && !_television) {
        _setFullscreen(false);
      } else {
        _close();
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _refresh() {
    unawaited(_session.refresh());
    _showOverlay();
  }

  void _changeVolume(int delta) {
    unawaited(_session.setVolume(_session.volume + delta));
    _showOverlay();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sur ordinateur, la lecture continue quand la fenêtre passe derrière une autre.
    if (!Platform.isAndroid && _controller.phone == null) return;
    // Mode radio : plus de surface où dessiner, mais le son et le flux continuent.
    if ((state == AppLifecycleState.hidden || state == AppLifecycleState.paused) && _radioRunning && !_videoOff) {
      _videoOff = true;
      unawaited(_session.setVideoEnabled(false));
    }
    if (state == AppLifecycleState.paused && !_radioRunning) unawaited(_session.suspend());
    // La petite fenêtre reste « inactive » : elle ne repasse jamais par « resumed » à l'écran.
    if (state == AppLifecycleState.inactive && _inPip) {
      _restoreVideo();
      unawaited(_session.resume());
    }
    if (state == AppLifecycleState.resumed) {
      _restoreVideo();
      if (_fullscreen) unawaited(_controller.fullscreenSwitch(true));
      unawaited(_session.resume());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final event in _phoneEvents) {
      unawaited(event.cancel());
    }
    final phone = _controller.phone;
    if (phone != null) {
      unawaited(phone.setPipReady(false));
      if (_radioRunning) unawaited(phone.stopRadio());
    }
    _hideTimer?.cancel();
    _noticeTimer?.cancel();
    _session.removeListener(_onSession);
    _session.dispose();
    if (_holdingDownloads) _controller.downloads.release();
    if (_fullscreen) unawaited(_controller.fullscreenSwitch(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = _session.engine;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: MouseRegion(
          onHover: (_) => _showOverlay(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleOverlay,
            // Sur Android, un double toucher retarderait chaque toucher de 300 ms.
            onDoubleTap: Platform.isAndroid ? null : () => _setFullscreen(!_fullscreen),
            child: Stack(fit: StackFit.expand, children: [
              if (engine != null) KeyedSubtree(key: ObjectKey(engine), child: engine.buildVideo()),
              if (!_inPip && _session.interrupted)
                _StatusLayer(session: _session, onRetry: _session.retry, onClose: _close),
              if (_overlay && !_inPip) ...[
                Align(
                  alignment: Alignment.topCenter,
                  child: _TopBar(
                    item: _item,
                    fullscreen: _fullscreen,
                    onClose: _close,
                    onFullscreen: _television ? null : () => _setFullscreen(!_fullscreen),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _BottomBar(
                    session: _session,
                    onPrevious: _index > 0 ? () => _step(-1) : null,
                    onNext: _index < widget.queue.length - 1 ? () => _step(1) : null,
                    onRefresh: _refresh,
                    pipActive: _pipOffered ? _controller.settings.pipActive : null,
                    radioActive: _radioOffered ? _controller.settings.radioActive : null,
                    onPip: _togglePip,
                    onRadio: _toggleRadio,
                  ),
                ),
              ],
              if (_notice != null && !_inPip)
                Align(
                  alignment: const Alignment(0, 0.6),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Color(0xCC000000), borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
                        child: Text(_notice!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Bandeau supérieur. Jamais ciblable : la télécommande agit directement sur la lecture.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.item, required this.fullscreen, required this.onClose, required this.onFullscreen});

  final PlayItem? item;
  final bool fullscreen;
  final VoidCallback onClose;
  final VoidCallback? onFullscreen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final item = this.item;
    return ExcludeFocus(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xCC000000), Color(0x00000000)]),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.s, AppSpace.s, AppSpace.s, AppSpace.xl),
            child: Row(children: [
              IconButton(tooltip: l.commonClose, onPressed: onClose, icon: const Icon(Icons.arrow_back, color: Colors.white)),
              if (item != null) ...[
                const SizedBox(width: AppSpace.s),
                Logo(url: item.logo, name: item.title, width: 56, height: 40),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleLarge?.copyWith(color: Colors.white)),
                    if (item.subtitle.isNotEmpty)
                      Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodySmall?.copyWith(color: Colors.white70)),
                  ]),
                ),
              ] else
                const Spacer(),
              if (item?.itemId != null) FavoriteStar(itemId: item!.itemId!, size: 24),
              if (item != null && AppScope.of(context).hasExternalPlayer)
                IconButton(
                  tooltip: l.externalOpen,
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  onPressed: () async {
                    // L'abonnement n'autorise souvent qu'une lecture : on libère le flux d'abord.
                    await playExternally(context, item);
                    if (context.mounted) onClose();
                  },
                ),
              if (onFullscreen != null)
                IconButton(
                  tooltip: fullscreen ? l.playerExitFullscreen : l.playerFullscreen,
                  onPressed: onFullscreen,
                  icon: Icon(fullscreen ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

String _clock(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = d.inHours;
  final minutes = two(d.inMinutes.remainder(60));
  final seconds = two(d.inSeconds.remainder(60));
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}

/// Sans hauteur imposée, un Slider prend toute la place : la barre couvrirait l'écran entier.
const _sliderHeight = 32.0;

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.session,
    required this.onPrevious,
    required this.onNext,
    required this.onRefresh,
    required this.pipActive,
    required this.radioActive,
    required this.onPip,
    required this.onRadio,
  });

  final PlaybackSession session;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onRefresh;

  /// Null : l'option n'est pas activée dans les réglages, le bouton n'apparaît pas.
  final bool? pipActive;
  final bool? radioActive;
  final VoidCallback onPip;
  final VoidCallback onRadio;

  /// En dessous, la barre de temps passe sur sa propre ligne.
  static const _narrow = 560.0;

  Widget _toggle(BuildContext context, {required bool active, required IconData icon, required String tooltip, required VoidCallback onPressed}) => IconButton(
        tooltip: tooltip,
        isSelected: active,
        onPressed: onPressed,
        icon: Icon(icon, color: active ? Palette.of(context).accent : Colors.white54),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final total = session.durationNow;
    final seekable = !session.live && total > Duration.zero;
    final desktop = Platform.isWindows || Platform.isLinux;
    return ExcludeFocus(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xCC000000), Color(0x00000000)]),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.m, AppSpace.xl, AppSpace.m, AppSpace.s),
            child: LayoutBuilder(builder: (context, constraints) {
              final buttons = <Widget>[
                IconButton(
                  tooltip: l.playerPrevious,
                  onPressed: onPrevious,
                  icon: Icon(Icons.skip_previous, color: onPrevious == null ? Colors.white30 : Colors.white),
                ),
                if (!session.live)
                  IconButton(
                    tooltip: session.paused ? l.playerPlay : l.playerPause,
                    onPressed: session.togglePause,
                    icon: Icon(session.paused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                  ),
                IconButton(
                  tooltip: l.playerNext,
                  onPressed: onNext,
                  icon: Icon(Icons.skip_next, color: onNext == null ? Colors.white30 : Colors.white),
                ),
                IconButton(tooltip: l.playerRefresh, onPressed: onRefresh, icon: const Icon(Icons.refresh, color: Colors.white)),
                if (pipActive != null)
                  _toggle(
                    context,
                    active: pipActive!,
                    icon: Icons.picture_in_picture_alt,
                    tooltip: pipActive! ? l.playerPipOn : l.playerPipOff,
                    onPressed: onPip,
                  ),
                if (radioActive != null)
                  _toggle(
                    context,
                    active: radioActive!,
                    icon: Icons.headphones,
                    tooltip: radioActive! ? l.playerRadioOn : l.playerRadioOff,
                    onPressed: onRadio,
                  ),
              ];
              final timeline = <Widget>[
                Text(_clock(session.positionNow), style: theme.labelMedium?.copyWith(color: Colors.white)),
                Expanded(
                  child: SizedBox(
                    height: _sliderHeight,
                    child: Slider(
                      min: 0,
                      max: total.inSeconds.toDouble(),
                      value: session.positionNow.inSeconds.clamp(0, total.inSeconds).toDouble(),
                      onChanged: (v) => session.seek(Duration(seconds: v.round())),
                    ),
                  ),
                ),
                Text(_clock(total), style: theme.labelMedium?.copyWith(color: Colors.white)),
              ];
              final volume = <Widget>[
                if (desktop && constraints.maxWidth >= _narrow) ...[
                  const SizedBox(width: AppSpace.s),
                  IconButton(
                    tooltip: session.volume > 0 ? l.playerMute : l.playerUnmute,
                    onPressed: () => session.setVolume(session.volume > 0 ? 0 : 100),
                    icon: Icon(session.volume > 0 ? Icons.volume_up : Icons.volume_off, color: Colors.white),
                  ),
                  SizedBox(width: 110, height: _sliderHeight, child: Slider(min: 0, max: 100, value: session.volume, onChanged: session.setVolume)),
                ],
              ];
              final narrow = constraints.maxWidth < _narrow;
              // Sur un petit téléphone, six boutons de 48 px ne tiennent pas : ils passent à 40.
              Widget compact(Widget child) => narrow
                  ? IconButtonTheme(data: IconButtonThemeData(style: IconButton.styleFrom(visualDensity: VisualDensity.compact)), child: child)
                  : child;
              if (seekable && narrow) {
                return compact(Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: timeline),
                  Row(children: [...buttons, const Spacer(), ...volume]),
                ]));
              }
              return compact(Row(children: [
                ...buttons,
                const SizedBox(width: AppSpace.s),
                if (seekable)
                  ...timeline
                else ...[
                  if (session.live) const _LiveBadge(),
                  const Spacer(),
                ],
                ...volume,
              ]));
            }),
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.live, shape: BoxShape.circle)),
        const SizedBox(width: AppSpace.s),
        Text(context.l10n.playerLive, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
      ]);
}

/// Ce qui se passe quand la vidéo ne tourne pas : chargement, reconnexion, échec, fin.
class _StatusLayer extends StatelessWidget {
  const _StatusLayer({required this.session, required this.onRetry, required this.onClose});

  final PlaybackSession session;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final state = session.state;
    if (state == PlaybackState.failed || state == PlaybackState.ended) {
      final failed = state == PlaybackState.failed;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Panel(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(failed ? l.playerFailedTitle : l.playerEndedTitle, style: theme.titleLarge),
              if (failed) ...[
                const SizedBox(height: AppSpace.s),
                Text(l.playerFailedBody, style: theme.bodyMedium),
              ],
              const SizedBox(height: AppSpace.l),
              Wrap(spacing: AppSpace.s, children: [
                if (failed) FilledButton(onPressed: onRetry, child: Text(l.commonRetry)),
                TextButton(onPressed: onClose, child: Text(l.playerBackToList)),
              ]),
            ]),
          ),
        ),
      );
    }
    final message = switch (state) {
      PlaybackState.reconnecting => l.playerReconnecting(session.attempt, PlaybackSession.retryDelays.length),
      PlaybackState.playing => l.playerSignalLost,
      _ => null,
    };
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.white)),
        if (message != null) ...[
          const SizedBox(height: AppSpace.m),
          DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xB3000000), borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
              child: Text(message, style: theme.bodyMedium?.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ]),
    );
  }
}
