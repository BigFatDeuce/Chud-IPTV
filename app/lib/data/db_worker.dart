import 'dart:async';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

typedef DbJob<R> = R Function(Database db);

/// SQLite est synchrone : toutes les requêtes de l'interface passent par cet isolat, pour que
/// même une liste de 200 000 lignes ne bloque jamais une image à l'écran.
///
/// Une tâche envoyée à [run] ne doit capturer que des données simples, jamais `this` ni un widget :
/// elle change d'isolat. D'où les fonctions statiques de `repository.dart`.
class DbWorker {
  DbWorker._(this._requests, this._replies, this._isolate);

  final SendPort _requests;
  final ReceivePort _replies;
  final Isolate _isolate;
  final _pending = <int, Completer<Object?>>{};
  var _nextId = 0;

  static Future<DbWorker> open(String path) async {
    final replies = ReceivePort();
    final ready = Completer<SendPort>();
    late final DbWorker worker;
    replies.listen((message) {
      if (message is SendPort) {
        ready.complete(message);
      } else if (message is _Failure && message.id < 0) {
        ready.completeError(message.error, message.stack);
      } else if (message is _Success) {
        worker._pending.remove(message.id)?.complete(message.value);
      } else if (message is _Failure) {
        worker._pending.remove(message.id)?.completeError(message.error, message.stack);
      }
    });
    final isolate = await Isolate.spawn(_main, (path, replies.sendPort), debugName: 'database');
    try {
      worker = DbWorker._(await ready.future, replies, isolate);
    } catch (_) {
      replies.close();
      rethrow;
    }
    return worker;
  }

  Future<R> run<R>(DbJob<R> job) async {
    final id = _nextId++;
    final done = Completer<Object?>();
    _pending[id] = done;
    _requests.send(_Request<R>(id, job));
    return await done.future as R;
  }

  Future<void> close() async {
    final done = Completer<void>();
    final port = ReceivePort()..listen((_) => done.complete());
    _isolate.addOnExitListener(port.sendPort);
    _requests.send(null);
    await done.future;
    port.close();
    _replies.close();
  }

  static void _main((String, SendPort) args) {
    final (path, replies) = args;
    final Database db;
    try {
      db = openDatabase(path);
    } catch (e, st) {
      replies.send(_Failure(-1, e, StackTrace.fromString('$st')));
      return;
    }
    final requests = ReceivePort();
    replies.send(requests.sendPort);
    requests.listen((message) {
      if (message == null) {
        db.close();
        requests.close();
        return;
      }
      (message as _Request).runOn(db, replies);
    });
  }
}

class _Request<R> {
  const _Request(this.id, this.job);

  final int id;
  final DbJob<R> job;

  void runOn(Database db, SendPort replies) {
    try {
      replies.send(_Success(id, job(db)));
    } catch (e, st) {
      replies.send(_Failure(id, e, StackTrace.fromString('$st')));
    }
  }
}

class _Success {
  const _Success(this.id, this.value);

  final int id;
  final Object? value;
}

class _Failure {
  const _Failure(this.id, this.error, this.stack);

  final int id;
  final Object error;
  final StackTrace stack;
}
