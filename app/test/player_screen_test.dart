import 'dart:async';
import 'dart:io';

import 'package:chud_iptv/app_controller.dart';
import 'package:chud_iptv/app_scope.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/l10n/app_localizations.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/download.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:chud_iptv/player/phone_playback.dart';
import 'package:chud_iptv/player/playback.dart';
import 'package:chud_iptv/screens/player_screen.dart';
import 'package:chud_iptv/theme/app_theme.dart';
import 'package:chud_iptv/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_engine.dart';

class _Repository implements Repository {
  @override
  Future<List<EpgSource>> epgSources() async => const [];

  @override
  Future<List<Download>> downloads() async => const [];

  @override
  Future<List<Source>> sources() async => const [];
  @override
  Future<Map<String, String>> settings() async => const {};
  @override
  Future<void> saveSetting(String key, String value) async {}
  @override
  Future<List<FavoriteList>> favoriteLists() async => const [];
  @override
  Future<Map<int, Set<int>>> favoriteMemberships() async => const {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Queue implements PlayQueue {
  _Queue(this.length, {this.live = true});

  @override
  final int length;
  final bool live;

  @override
  Future<PlayItem?> at(int index) async =>
      PlayItem(title: 'Chaîne $index', subtitle: 'France', request: PlayRequest(url: 'http://x/$index.ts', live: live));
}

class _Phone implements PhonePlayback {
  _Phone({this.supportsPip = true});

  @override
  final bool supportsPip;
  final pip = StreamController<bool>.broadcast(sync: true);
  final stopped = StreamController<void>.broadcast(sync: true);
  bool? ready;
  int radioStarts = 0;
  int radioStops = 0;

  @override
  Stream<bool> get pipChanges => pip.stream;
  @override
  Stream<void> get radioStopped => stopped.stream;
  @override
  Future<void> setPipReady(bool value) async => ready = value;
  /// Android met un instant à lancer le service : le test décide quand il répond.
  Completer<void>? radioGate;

  @override
  Future<bool> startRadio(String title, String text, String stopLabel) async {
    radioStarts++;
    await radioGate?.future;
    return true;
  }

  @override
  Future<void> stopRadio() async => radioStops++;
  @override
  Future<void> askNotifications() async {}
}

void main() {
  late List<FakeEngine> engines;
  late List<bool> fullscreenCalls;

  Future<AppController> pump(WidgetTester tester, {int length = 5, bool live = true, bool television = false, PhonePlayback? phone, Size size = const Size(1280, 720), bool pip = false, bool radio = false, bool fullscreen = false, int index = 2}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    engines = [];
    fullscreenCalls = [];
    final controller = AppController(
      repository: _Repository(),
      dbPath: '',
      tempDir: Directory.systemTemp.path,
      playlistsDir: Directory.systemTemp.path,
      isTelevision: television,
      phone: phone,
      engineFactory: ({required software}) async {
        final e = FakeEngine(software: software);
        engines.add(e);
        return e;
      },
      fullscreenSwitch: (value) async => fullscreenCalls.add(value),
    );
    await controller.start();
    controller.settings = controller.settings.copyWith(fullscreen: fullscreen, pipOption: pip, radioOption: radio);
    await tester.pumpWidget(AppScope(
      controller: controller,
      child: MaterialApp(
        theme: buildAppTheme(Palette.night),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Builder(builder: (context) {
          return Scaffold(
            body: Center(child: TextButton(onPressed: () => openPlayer(context, _Queue(length, live: live), index), child: const Text('ouvrir'))),
          );
        }),
      ),
    ));
    await tester.tap(find.text('ouvrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    return controller;
  }

  Future<void> play(WidgetTester tester, int seconds, {int from = 0}) async {
    for (var i = 1; i <= seconds; i++) {
      engines.last.advance(Duration(seconds: from + i));
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('lancer une chaîne ouvre le flux et affiche la vidéo', (tester) async {
    await pump(tester);
    expect(engines.last.opens.single.$1.url, 'http://x/2.ts');
    expect(find.byKey(const Key('video')), findsOneWidget);
    expect(find.text('Chaîne 2'), findsOneWidget);
    await close(tester);
  });

  testWidgets('micro-coupure en plein écran : reconnexion, et le plein écran reste', (tester) async {
    await pump(tester, fullscreen: true);
    expect(fullscreenCalls, [true]);
    await play(tester, 5);

    await tester.pump(const Duration(seconds: PlaybackSession.liveStallLimit));
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.textContaining('Reconnexion'), findsOneWidget);
    expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget, reason: 'toujours en plein écran pendant la coupure');
    expect(engines.last.opens, hasLength(2));

    await play(tester, 3, from: 10);
    expect(find.textContaining('Reconnexion'), findsNothing);
    expect(fullscreenCalls, isNot(contains(false)), reason: 'le plein écran n\'a jamais été quitté');
    expect(fullscreenCalls.last, isTrue, reason: 'et il est réappliqué à la reprise');
    expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
    await close(tester);
  });

  testWidgets('image figée : message dès 2 secondes, et il disparaît si le flux repart', (tester) async {
    await pump(tester, fullscreen: true);
    await play(tester, 3);
    await tester.pump(const Duration(seconds: PlaybackSession.stallNotice + 1));
    await tester.pump();
    expect(find.text('Signal perdu…'), findsOneWidget);
    await play(tester, 2, from: 10);
    expect(find.text('Signal perdu…'), findsNothing);
    await close(tester);
  });

  testWidgets('Rafraîchir rouvre la même chaîne, comme changer puis revenir', (tester) async {
    await pump(tester);
    await play(tester, 3);
    await tester.tap(find.byTooltip('Rafraîchir le flux'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(engines.last.stops, 1, reason: "la connexion est fermée avant d'être rouverte");
    expect(engines.last.opens, hasLength(2));
    expect(engines.last.opens.last.$1.url, 'http://x/2.ts');
    expect(find.text('Chaîne 2'), findsOneWidget);
    await close(tester);
  });

  testWidgets('échec définitif : message clair, sans adresse, et Réessayer', (tester) async {
    await pump(tester);
    for (var i = 0; i < 200; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text('Lecture impossible'), findsOneWidget);
    expect(find.textContaining('http://'), findsNothing);
    final opens = engines.last.opens.length;
    await tester.tap(find.text('Réessayer'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(engines.last.opens.length, opens + 1);
    await close(tester);
  });

  testWidgets('le plein écran se retrouve à la lecture suivante', (tester) async {
    final c = await pump(tester);
    expect(fullscreenCalls, [false]);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.pump();
    expect(fullscreenCalls.last, isTrue);
    expect(c.settings.fullscreen, isTrue);
    await close(tester);
  });

  testWidgets('quitter le lecteur quitte le plein écran', (tester) async {
    await pump(tester, fullscreen: true);
    await close(tester);
    expect(fullscreenCalls.last, isFalse);
    expect(engines.last.disposed, isTrue);
  });

  testWidgets('Échap quitte d\'abord le plein écran', (tester) async {
    await pump(tester, fullscreen: true);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(fullscreenCalls.last, isFalse);
    expect(find.text('Chaîne 2'), findsOneWidget);
    await close(tester);
  });

  group('télécommande', () {
    testWidgets('haut et bas changent de chaîne, sans sortir de la liste', (tester) async {
      await pump(tester, television: true, length: 3, index: 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump(const Duration(milliseconds: 10));
      expect(engines.last.opens, hasLength(1), reason: 'déjà sur la dernière chaîne');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      expect(engines.last.opens.last.$1.url, 'http://x/1.ts');
      expect(find.text('Chaîne 1'), findsOneWidget);
      await close(tester);
    });

    testWidgets('sur TV, toujours en plein écran', (tester) async {
      await pump(tester, television: true);
      expect(fullscreenCalls, [true]);
      expect(find.byIcon(Icons.fullscreen_exit), findsNothing, reason: 'pas de bouton inutile');
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.pump();
      expect(fullscreenCalls, [true]);
      await close(tester);
    });

    testWidgets('film : bouton central pour la pause, gauche et droite pour avancer', (tester) async {
      await pump(tester, television: true, live: false);
      engines.last.setDuration(const Duration(minutes: 90));
      await play(tester, 30);
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump();
      expect(engines.last.pausedNow, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(engines.last.seekedTo, const Duration(seconds: 40));
      await close(tester);
    });

    testWidgets('échec : le bouton central réessaie', (tester) async {
      await pump(tester, television: true);
      for (var i = 0; i < 200; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      final opens = engines.last.opens.length;
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(milliseconds: 10));
      expect(engines.last.opens.length, opens + 1);
      await close(tester);
    });
  });

  testWidgets('le bandeau se cache pendant la lecture, reste affiché pendant une coupure', (tester) async {
    await pump(tester);
    await play(tester, 6);
    expect(find.text('Chaîne 2'), findsNothing);
    await tester.pump(const Duration(seconds: PlaybackSession.liveStallLimit));
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('Chaîne 2'), findsOneWidget);
    await close(tester);
  });

  group('téléphone', () {
    Future<void> lifecycle(WidgetTester tester, AppLifecycleState state) async {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump(const Duration(milliseconds: 10));
    }

    testWidgets('sans téléphone : aucun bouton, même options activées', (tester) async {
      await pump(tester, pip: true, radio: true);
      expect(find.byIcon(Icons.picture_in_picture_alt), findsNothing);
      expect(find.byIcon(Icons.headphones), findsNothing);
      await close(tester);
    });

    testWidgets('options coupées dans les réglages : aucun bouton, pas de service', (tester) async {
      final phone = _Phone();
      await pump(tester, phone: phone);
      expect(find.byIcon(Icons.picture_in_picture_alt), findsNothing);
      expect(find.byIcon(Icons.headphones), findsNothing);
      expect(phone.ready, isFalse);
      expect(phone.radioStarts, 0);
      await close(tester);
    });

    testWidgets('options activées : boutons près de précédent et suivant, Android prévenu', (tester) async {
      final phone = _Phone();
      await pump(tester, phone: phone, pip: true, radio: true);
      expect(find.byIcon(Icons.picture_in_picture_alt), findsOneWidget);
      expect(find.byIcon(Icons.headphones), findsOneWidget);
      expect(phone.ready, isTrue);
      expect(phone.radioStarts, 1, reason: 'lancé lecteur à l\'écran : Android le refuserait plus tard');
      await close(tester);
    });

    testWidgets('téléphone sans image dans l\'image : pas de bouton', (tester) async {
      final phone = _Phone(supportsPip: false);
      await pump(tester, phone: phone, pip: true);
      expect(find.byIcon(Icons.picture_in_picture_alt), findsNothing);
      await close(tester);
    });

    testWidgets('les boutons coupent et remettent la fonction', (tester) async {
      final phone = _Phone();
      final controller = await pump(tester, phone: phone, pip: true, radio: true);
      await tester.tap(find.byIcon(Icons.headphones));
      // Sous Windows, le double-clic du plein écran retarde chaque toucher de 300 ms.
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.settings.radioActive, isFalse);
      expect(phone.radioStops, 1);
      await tester.tap(find.byIcon(Icons.picture_in_picture_alt));
      // Sous Windows, le double-clic du plein écran retarde chaque toucher de 300 ms.
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.settings.pipActive, isFalse);
      expect(phone.ready, isFalse);
      await tester.tap(find.byIcon(Icons.headphones));
      // Sous Windows, le double-clic du plein écran retarde chaque toucher de 300 ms.
      await tester.pump(const Duration(milliseconds: 400));
      expect(phone.radioStarts, 2);
      await tester.pump(const Duration(seconds: 3));
      await close(tester);
    });

    testWidgets('radio coupée pendant que le service démarre : il est bien arrêté, le flux libéré', (tester) async {
      final phone = _Phone()..radioGate = Completer<void>();
      addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      final controller = await pump(tester, phone: phone, radio: true);
      expect(phone.radioStarts, 1);
      await tester.tap(find.byIcon(Icons.headphones));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.settings.radioActive, isFalse);
      phone.radioGate!.complete();
      await tester.pump(const Duration(milliseconds: 10));
      expect(phone.radioStops, 1, reason: 'le service lancé juste avant ne doit pas survivre au bouton');
      await play(tester, 2);
      await lifecycle(tester, AppLifecycleState.paused);
      expect(engines.last.stops, 1, reason: 'radio coupée : le flux est libéré en arrière-plan');
      await lifecycle(tester, AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 3));
      await close(tester);
    });

    testWidgets('lecteur fermé pendant que le service démarre : aucun service ne reste', (tester) async {
      final phone = _Phone()..radioGate = Completer<void>();
      await pump(tester, phone: phone, radio: true);
      await close(tester);
      expect(phone.radioStops, 0);
      phone.radioGate!.complete();
      await tester.pump(const Duration(milliseconds: 10));
      expect(phone.radioStops, 1);
      expect(phone.ready, isFalse, reason: 'quitter l\'app n\'ouvre plus de petite fenêtre');
    });

    testWidgets('radio : téléphone verrouillé, le flux reste ouvert sans image', (tester) async {
      final phone = _Phone();
      addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      await pump(tester, phone: phone, radio: true, live: false);
      await play(tester, 2);
      await lifecycle(tester, AppLifecycleState.paused);
      expect(engines.last.stops, 0);
      expect(engines.last.videoEnabled, isFalse);
      await lifecycle(tester, AppLifecycleState.resumed);
      expect(engines.last.videoEnabled, isTrue);
      expect(engines.last.opens, hasLength(1), reason: 'pas de réouverture : la lecture n\'a jamais cessé');
      await close(tester);
    });

    testWidgets('sans radio : le flux est libéré comme avant', (tester) async {
      final phone = _Phone();
      addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      await pump(tester, phone: phone);
      await play(tester, 2);
      await lifecycle(tester, AppLifecycleState.paused);
      expect(engines.last.stops, 1);
      await lifecycle(tester, AppLifecycleState.resumed);
      expect(engines.last.opens, hasLength(2));
      await close(tester);
    });

    testWidgets('« Arrêter » dans la notification libère le flux', (tester) async {
      final phone = _Phone();
      addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      final controller = await pump(tester, phone: phone, radio: true);
      await play(tester, 2);
      await lifecycle(tester, AppLifecycleState.paused);
      phone.stopped.add(null);
      await tester.pump(const Duration(milliseconds: 10));
      expect(engines.last.stops, 1);
      expect(controller.settings.radioActive, isFalse);
      await lifecycle(tester, AppLifecycleState.resumed);
      await close(tester);
    });

    testWidgets('petite fenêtre : la vidéo seule, sans bandeaux', (tester) async {
      final phone = _Phone();
      await pump(tester, phone: phone, pip: true);
      expect(find.text('Chaîne 2'), findsOneWidget);
      phone.pip.add(true);
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.text('Chaîne 2'), findsNothing);
      expect(find.byIcon(Icons.skip_next), findsNothing);
      expect(find.byKey(const Key('video')), findsOneWidget);
      await close(tester);
    });

    testWidgets('film sur petit téléphone : tout tient, sans débordement', (tester) async {
      final phone = _Phone();
      await pump(tester, phone: phone, pip: true, radio: true, live: false, size: const Size(320, 640));
      engines.last.setDuration(const Duration(minutes: 90));
      await tester.pump(const Duration(milliseconds: 10));
      expect(tester.takeException(), isNull);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byIcon(Icons.headphones), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await close(tester);
    });

    testWidgets('direct sur petit téléphone : tous les boutons tiennent', (tester) async {
      await pump(tester, phone: _Phone(), pip: true, radio: true, size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await close(tester);
    });
  });
}
