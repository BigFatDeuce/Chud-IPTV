import 'dart:async';

import 'package:chud_iptv/player/playback.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_engine.dart';

const liveStream = PlayRequest(url: 'http://x/live.ts', live: true);
const movie = PlayRequest(url: 'http://x/film.mp4', live: false);

void main() {
  late List<FakeEngine> engines;

  PlaybackSession session({bool fallBack = false}) => PlaybackSession(({required software}) async {
        final e = FakeEngine(software: software, fallBack: fallBack);
        engines.add(e);
        return e;
      });

  setUp(() => engines = []);

  /// Fait avancer le flux pendant [seconds] secondes simulées.
  void play(FakeAsync clock, int seconds, {int from = 0}) {
    for (var i = 1; i <= seconds; i++) {
      engines.last.advance(Duration(seconds: from + i));
      clock.elapse(const Duration(seconds: 1));
    }
  }

  test('la lecture démarre quand la position avance', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      expect(s.state, PlaybackState.opening);
      engines.last.advance(const Duration(seconds: 1));
      expect(s.state, PlaybackState.playing);
      s.dispose();
    });
  });

  test('image figée sans erreur : le direct se reconnecte aussitôt', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 5);
      expect(engines.last.opens, hasLength(1));

      clock.elapse(const Duration(seconds: PlaybackSession.liveStallLimit));
      expect(s.state, PlaybackState.reconnecting);
      expect(s.attempt, 1);
      clock.flushMicrotasks();
      expect(engines.last.opens, hasLength(2), reason: 'le premier essai part sans attendre');

      play(clock, 3);
      expect(s.state, PlaybackState.playing);
      expect(engines, hasLength(1), reason: 'le moteur, donc la vidéo à l\'écran, reste le même');
      s.dispose();
    });
  });

  test('l\'utilisateur est prévenu avant même la reconnexion', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 3);
      expect(s.stalling, isFalse);
      clock.elapse(const Duration(seconds: PlaybackSession.stallNotice));
      expect(s.stalling, isTrue);
      expect(s.state, PlaybackState.playing, reason: 'une micro-coupure peut encore se rattraper seule');
      engines.last.advance(const Duration(seconds: 9));
      expect(s.stalling, isFalse);
      s.dispose();
    });
  });

  test('un direct qui se termine est une coupure', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 3);
      engines.last.end();
      expect(s.state, PlaybackState.reconnecting);
      clock.elapse(const Duration(milliseconds: 1));
      expect(engines.last.opens, hasLength(2));
      s.dispose();
    });
  });

  test('flux qui ne démarre jamais : essais espacés, puis échec clair', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      clock.elapse(const Duration(minutes: 5));
      expect(s.state, PlaybackState.failed);
      expect(engines.last.opens, hasLength(1 + PlaybackSession.retryDelays.length));
      expect(engines.last.stops, 1, reason: 'la connexion est libérée');
      s.dispose();
    });
  });

  test('les essais sont espacés', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 2);
      clock.elapse(const Duration(seconds: PlaybackSession.liveStallLimit));
      clock.flushMicrotasks();
      expect(engines.last.opens, hasLength(2));
      while (s.attempt < 2) {
        clock.elapse(const Duration(seconds: 1));
      }
      expect(engines.last.opens, hasLength(2), reason: 'le deuxième essai attend une seconde');
      clock.elapse(const Duration(seconds: 1));
      expect(engines.last.opens, hasLength(3));
      s.dispose();
    });
  });

  test('après un échec, Réessayer repart de zéro', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      clock.elapse(const Duration(minutes: 5));
      expect(s.state, PlaybackState.failed);
      s.retry();
      clock.flushMicrotasks();
      expect(s.state, PlaybackState.opening);
      expect(s.attempt, 0);
      engines.last.advance(const Duration(seconds: 1));
      expect(s.state, PlaybackState.playing);
      s.dispose();
    });
  });

  test('une lecture stable remet le compteur à zéro', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 3);
      clock.elapse(const Duration(seconds: PlaybackSession.liveStallLimit));
      clock.flushMicrotasks();
      expect(s.attempt, 1);
      play(clock, PlaybackSession.steadySeconds + 2, from: 10);
      expect(s.attempt, 0);
      s.dispose();
    });
  });

  test('de nombreuses micro-coupures espacées ne mènent jamais à l\'échec', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      for (var i = 0; i < 30; i++) {
        play(clock, PlaybackSession.steadySeconds + 3, from: i * 100);
        clock.elapse(const Duration(seconds: PlaybackSession.liveStallLimit));
        clock.flushMicrotasks();
        expect(s.state, PlaybackState.reconnecting);
      }
      s.dispose();
    });
  });

  test('film figé : il reprend là où il en était', () {
    fakeAsync((clock) {
      final s = session()..open(movie);
      clock.flushMicrotasks();
      play(clock, 30);
      clock.elapse(const Duration(seconds: PlaybackSession.vodStallLimit));
      clock.flushMicrotasks();
      expect(engines.last.opens.last.$2, const Duration(seconds: 30));
      s.dispose();
    });
  });

  test('film terminé : pas de reconnexion', () {
    fakeAsync((clock) {
      final s = session()..open(movie);
      clock.flushMicrotasks();
      engines.last.setDuration(const Duration(seconds: 100));
      play(clock, 95);
      engines.last.end();
      expect(s.state, PlaybackState.ended);
      s.dispose();
    });
  });

  test('film qui s\'arrête bien avant la fin : coupure', () {
    fakeAsync((clock) {
      final s = session()..open(movie);
      clock.flushMicrotasks();
      engines.last.setDuration(const Duration(minutes: 90));
      play(clock, 60);
      engines.last.end();
      expect(s.state, PlaybackState.reconnecting);
      s.dispose();
    });
  });

  test('en pause, le flux peut rester immobile', () {
    fakeAsync((clock) {
      final s = session()..open(movie);
      clock.flushMicrotasks();
      play(clock, 3);
      s.togglePause();
      clock.elapse(const Duration(minutes: 10));
      expect(s.state, PlaybackState.playing);
      expect(engines.last.pausedNow, isTrue);
      s.dispose();
    });
  });

  test('codec refusé sur Android : bascule une fois en logiciel', () {
    fakeAsync((clock) {
      final s = session(fallBack: true)..open(liveStream);
      clock.flushMicrotasks();
      engines.last.error('Could not open codec.');
      clock.flushMicrotasks();
      expect(engines, hasLength(2));
      expect(engines.first.disposed, isTrue);
      expect(engines.last.software, isTrue);
      expect(engines.last.opens, hasLength(1));

      engines.last.error('Could not open codec.');
      clock.flushMicrotasks();
      expect(engines, hasLength(2), reason: 'une seule bascule');
      s.dispose();
    });
  });

  test('après un repli logiciel, la chaîne suivante repart en matériel', () {
    fakeAsync((clock) {
      final s = session(fallBack: true)..open(liveStream);
      clock.flushMicrotasks();
      engines.last.error('Could not open codec.');
      clock.flushMicrotasks();
      expect(engines.last.software, isTrue);
      s.open(const PlayRequest(url: 'http://x/autre.ts', live: true));
      clock.flushMicrotasks();
      expect(engines, hasLength(3));
      expect(engines[1].disposed, isTrue);
      expect(engines.last.software, isFalse);
      s.dispose();
    });
  });

  test('codec refusé ailleurs : pas de bascule', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      engines.last.error('Could not open codec.');
      clock.flushMicrotasks();
      expect(engines, hasLength(1));
      s.dispose();
    });
  });

  test('pas de sortie son : ce n\'est pas une panne', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      engines.last.error('Could not open/initialize audio device -> no sound.');
      expect(s.state, PlaybackState.opening);
      s.dispose();
    });
  });

  test('ouverture qui échoue : nouvel essai', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 2);
      engines.last.throwOnOpen = true;
      clock.elapse(const Duration(seconds: PlaybackSession.liveStallLimit));
      clock.flushMicrotasks();
      expect(s.state, PlaybackState.reconnecting);
      expect(s.attempt, greaterThan(1));
      s.dispose();
    });
  });

  test('arrière-plan : le flux est libéré, puis repris', () {
    fakeAsync((clock) {
      final s = session()..open(movie);
      clock.flushMicrotasks();
      play(clock, 40);
      s.suspend();
      clock.flushMicrotasks();
      expect(engines.last.stops, 1);
      clock.elapse(const Duration(minutes: 30));
      expect(engines.last.opens, hasLength(1), reason: 'rien ne se reconnecte en arrière-plan');

      s.resume();
      clock.flushMicrotasks();
      expect(engines.last.opens.last.$2, const Duration(seconds: 40));
      s.dispose();
    });
  });

  test('rafraîchir un direct : connexion fermée puis rouverte, compteur à zéro', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 3);
      s.refresh();
      clock.flushMicrotasks();
      expect(engines.last.stops, 1);
      expect(engines.last.opens, hasLength(2));
      expect(engines.last.opens.last, (liveStream, null));
      expect(s.state, PlaybackState.opening);
      expect(s.attempt, 0);
      s.dispose();
    });
  });

  test('rafraîchir un film : il reprend à sa place', () {
    fakeAsync((clock) {
      final s = session()..open(movie);
      clock.flushMicrotasks();
      play(clock, 30);
      s.refresh();
      clock.flushMicrotasks();
      expect(engines.last.opens.last, (movie, const Duration(seconds: 30)));
      s.dispose();
    });
  });

  test('changer de chaîne repart proprement', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      play(clock, 3);
      s.open(const PlayRequest(url: 'http://x/autre.ts', live: true));
      clock.flushMicrotasks();
      expect(s.state, PlaybackState.opening);
      expect(engines, hasLength(1), reason: 'le même moteur sert au zapping');
      expect(engines.last.opens.last.$1.url, 'http://x/autre.ts');
      s.dispose();
    });
  });

  group('moteur pas encore prêt', () {
    late Completer<void> ready;
    const other = PlayRequest(url: 'http://x/autre.ts', live: true);

    /// Le moteur met du temps à naître, comme sur un téléviseur : le test décide quand il est prêt.
    /// [ready] se crée dans `fakeAsync`, sinon l'horloge du test ne le voit pas se terminer.
    PlaybackSession slow({bool fallBack = false}) => PlaybackSession(({required software}) async {
          await ready.future;
          final e = FakeEngine(software: software, fallBack: fallBack);
          engines.add(e);
          return e;
        });

    test('zapper tout de suite : un seul moteur, une seule connexion, la dernière chaîne', () {
      fakeAsync((clock) {
        ready = Completer<void>();
        final s = slow()
          ..open(liveStream)
          ..open(other);
        clock.flushMicrotasks();
        ready.complete();
        clock.flushMicrotasks();
        expect(engines, hasLength(1), reason: 'un second moteur ouvrirait une seconde connexion, que l\'abonnement refuse');
        expect(engines.single.opens, [(other, null)]);
        s.dispose();
      });
    });

    test('fermer tout de suite : rien ne reste, ni moteur ni surveillance', () {
      fakeAsync((clock) {
        ready = Completer<void>();
        final s = slow()..open(liveStream);
        clock.flushMicrotasks();
        s.dispose();
        ready.complete();
        clock.flushMicrotasks();
        expect(engines.single.disposed, isTrue);
        expect(engines.single.opens, isEmpty);
        expect(clock.periodicTimerCount, 0);
      });
    });

    test('moteur impossible à créer : échec clair, et Réessayer retente', () {
      fakeAsync((clock) {
        var broken = true;
        final s = PlaybackSession(({required software}) async {
          if (broken) throw StateError('libmpv absente');
          final e = FakeEngine(software: software);
          engines.add(e);
          return e;
        })
          ..open(liveStream);
        clock.flushMicrotasks();
        expect(s.state, PlaybackState.failed, reason: 'pas d\'attente sans fin');
        expect(clock.periodicTimerCount, 0);
        broken = false;
        s.retry();
        clock.flushMicrotasks();
        expect(engines.single.opens, [(liveStream, null)]);
        s.dispose();
      });
    });

    test('zapper pendant le repli logiciel : le moteur logiciel ne sert pas à la chaîne suivante', () {
      fakeAsync((clock) {
        ready = Completer<void>()..complete();
        final s = slow(fallBack: true)..open(liveStream);
        clock.flushMicrotasks();
        ready = Completer<void>();
        engines.last.error('Could not open codec.');
        clock.flushMicrotasks();
        s.open(other);
        clock.flushMicrotasks();
        ready.complete();
        clock.flushMicrotasks();
        final alive = engines.where((e) => !e.disposed).toList();
        expect(alive, hasLength(1));
        expect(alive.single.software, isFalse);
        expect(alive.single.opens, [(other, null)]);
        s.dispose();
      });
    });
  });

  group('états', () {
    test('seuls les passages prévus existent', () {
      const allowed = {
        PlaybackState.opening: {PlaybackState.opening, PlaybackState.playing, PlaybackState.reconnecting, PlaybackState.failed, PlaybackState.ended},
        PlaybackState.playing: {PlaybackState.opening, PlaybackState.reconnecting, PlaybackState.failed, PlaybackState.ended},
        PlaybackState.reconnecting: {PlaybackState.opening, PlaybackState.playing, PlaybackState.reconnecting, PlaybackState.failed, PlaybackState.ended},
        PlaybackState.failed: {PlaybackState.opening},
        PlaybackState.ended: {PlaybackState.opening},
      };
      for (final from in PlaybackState.values) {
        for (final to in PlaybackState.values) {
          expect(from.canBecome(to), allowed[from]!.contains(to), reason: '$from → $to');
        }
      }
    });

    test('après un échec, une fin de flux tardive ne masque pas « Réessayer »', () {
      fakeAsync((clock) {
        final s = session()..open(movie);
        clock.flushMicrotasks();
        engines.last.setDuration(const Duration(seconds: 100));
        play(clock, 95);
        clock.elapse(const Duration(minutes: 10));
        expect(s.state, PlaybackState.failed);
        engines.last.end();
        expect(s.state, PlaybackState.failed);
        s.dispose();
      });
    });

    test('interrompue : tout sauf une lecture qui avance', () {
      fakeAsync((clock) {
        final s = session()..open(liveStream);
        clock.flushMicrotasks();
        expect(s.interrupted, isTrue);
        play(clock, 3);
        expect(s.interrupted, isFalse);
        clock.elapse(const Duration(seconds: PlaybackSession.stallNotice));
        expect(s.interrupted, isTrue, reason: 'signal perdu');
        s.dispose();
      });
    });
  });

  test('fermer le lecteur libère le moteur et arrête la surveillance', () {
    fakeAsync((clock) {
      final s = session()..open(liveStream);
      clock.flushMicrotasks();
      s.dispose();
      expect(engines.last.disposed, isTrue);
      clock.elapse(const Duration(minutes: 5));
      expect(engines.last.opens, hasLength(1));
    });
  });
}
