// Maquette jetable : prouve la compatibilité du moteur vidéo et de SQLite FTS5, rien de plus.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

const urlsDefine = String.fromEnvironment('URLS');
const voDefine = String.fromEnvironment('VO');
const hwdecDefine = String.fromEnvironment('HWDEC');
const noStop = bool.fromEnvironment('NOSTOP');

late File logFile;
void log(Map<String, Object?> e) {
  final line = jsonEncode(e);
  debugPrint('SPIKE $line');
  logFile.writeAsStringSync('$line\n', mode: FileMode.append);
}

Future<void> sqliteTest(String dir) async {
  final db = sqlite3.open('$dir/spike.db');
  final version = db.select('select sqlite_version() v').first['v'];
  log({'t': 'sqlite', 'version': version});
  db.execute('drop table if exists ch; drop table if exists ch_fts;');
  db.execute('create table ch(id integer primary key, name text, grp text)');
  db.execute("create virtual table ch_fts using fts5(name, grp, content='ch', content_rowid='id', tokenize=\"trigram remove_diacritics 1\")");
  final sw = Stopwatch()..start();
  final names = ['TF1', 'France 2', 'Canal+ Sport', 'beIN SPORTS', 'RTL Télévision', 'Eurosport', 'Arte', 'M6', 'Téléfoot', 'Sky Atlantic'];
  db.execute('begin');
  final ins = db.prepare('insert into ch(id,name,grp) values(?,?,?)');
  for (var i = 0; i < 100000; i++) {
    ins.execute([i + 1, '${names[i % names.length]} ${i % 7 == 0 ? "HD" : "FHD"} $i', 'FR| Groupe ${i % 300}']);
  }
  ins.close();
  db.execute("insert into ch_fts(ch_fts) values('rebuild')");
  db.execute('commit');
  log({'t': 'sqlite_index_100k_ms', 'ms': sw.elapsedMilliseconds});
  for (final q in ['telefoot', 'téléf', 'eurosp', 'sky atl']) {
    sw.reset();
    final r = db.select('select count(*) c from (select rowid from ch_fts where ch_fts match ? limit 200)', ['"$q"']);
    log({'t': 'fts_query', 'q': q, 'ms': sw.elapsedMicroseconds / 1000, 'hits': r.first['c']});
  }
  db.close();
}

Future<void> probe(Player p, String url) async {
  final sw = Stopwatch()..start();
  String? error;
  final sub = p.stream.error.listen((e) => error ??= e);
  await p.open(Media(url));
  var firstFrameMs = -1;
  var duration = Duration.zero;
  while (sw.elapsed < const Duration(seconds: 25)) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (firstFrameMs < 0 && (p.state.width ?? 0) > 0 && p.state.position > Duration.zero) firstFrameMs = sw.elapsedMilliseconds;
    if (firstFrameMs >= 0 && sw.elapsedMilliseconds > firstFrameMs + 8000) break;
    if (error != null && !error!.contains("audio") && !error!.contains("codec")) break;
  }
  duration = p.state.position;
  final np = p.platform as NativePlayer;
  Future<String> prop(String n) async {
    try {
      return await np.getProperty(n);
    } catch (e) {
      return 'ERR';
    }
  }

  log({
    't': 'play',
    'url': url,
    'firstFrameMs': firstFrameMs,
    'position': duration.inMilliseconds,
    'w': p.state.width,
    'h': p.state.height,
    'error': error,
    'elapsedMs': sw.elapsedMilliseconds,
    'hwdec': await prop('hwdec-current'),
    'vcodec': await prop('video-codec'),
    'demuxer': await prop('current-demuxer'),
    'dropped': await prop('frame-drop-count'),
    'mpv': await prop('mpv-version'),
    'ffmpeg': await prop('ffmpeg-version'),
  });
  await sub.cancel();
  if (!noStop) await p.stop();
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final dir = (await getApplicationSupportDirectory()).path;
  logFile = File('$dir/spike_log.jsonl');
  if (logFile.existsSync()) logFile.deleteSync();
  log({'t': 'start', 'os': Platform.operatingSystem, 'version': Platform.version, 'dir': dir});
  runApp(const SpikeApp());
}

class SpikeApp extends StatefulWidget {
  const SpikeApp({super.key});
  @override
  State<SpikeApp> createState() => _SpikeAppState();
}

class _SpikeAppState extends State<SpikeApp> {
  final player = Player(configuration: const PlayerConfiguration(logLevel: MPVLogLevel.warn));
  late final controller = VideoController(
    player,
    configuration: VideoControllerConfiguration(vo: voDefine.isEmpty ? null : voDefine, hwdec: hwdecDefine.isEmpty ? null : hwdecDefine),
  );

  @override
  void initState() {
    super.initState();
    player.stream.log.listen((l) => log({'t': 'mpv', 'p': l.prefix, 'l': l.level, 'm': l.text.trim()}));
    unawaited(_run());
  }

  Future<void> _run() async {
    try {
      await sqliteTest((await getApplicationSupportDirectory()).path);
      for (final u in urlsDefine.split(',').where((s) => s.isNotEmpty)) {
        await probe(player, u);
      }
    } catch (e, st) {
      log({'t': 'fatal', 'e': '$e', 'st': '$st'});
    }
    log({'t': 'done'});
    await Future<void>.delayed(const Duration(seconds: 1));
    exit(0);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(home: Scaffold(body: Video(controller: controller)));
}
