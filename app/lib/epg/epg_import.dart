import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:sqlite3/sqlite3.dart';

import '../data/database.dart';
import '../import/text.dart';
import 'catchup.dart';
import 'xmltv.dart';

/// Une source de guide à importer.
class EpgJob {
  const EpgJob({required this.id, required this.name, this.url = '', this.path = ''});

  final int id;
  final String name;

  /// Adresse, ou [path] pour un fichier local.
  final String url;
  final String path;
}

class EpgReport {
  const EpgReport({this.programs = 0, this.linked = 0, this.failed = const []});

  final int programs;
  final int linked;

  /// Noms des sources qui n'ont pas pu être lues : leur ancien guide est conservé.
  final List<String> failed;
}

/// Programmes gardés autour d'aujourd'hui : assez pour le replay et la semaine à venir.
const _daysBack = 8;
const _daysAhead = 8;

/// Lance l'import dans son propre isolat, pour ne jamais gêner l'interface.
Future<EpgReport> importEpgInIsolate(String dbPath, String tempDir, List<EpgJob> jobs, void Function(int done) onProgress) async {
  final port = ReceivePort();
  final exit = ReceivePort();
  final done = Completer<EpgReport>();
  port.listen((m) {
    if (m is int) onProgress(m);
    if (m is EpgReport && !done.isCompleted) done.complete(m);
  });
  exit.listen((_) {
    if (!done.isCompleted) done.complete(EpgReport(failed: [for (final j in jobs) j.name]));
  });
  await Isolate.spawn(_main, (dbPath, tempDir, jobs, port.sendPort), debugName: 'epg', onExit: exit.sendPort, errorsAreFatal: true);
  try {
    return await done.future;
  } finally {
    port.close();
    exit.close();
  }
}

Future<void> _main((String, String, List<EpgJob>, SendPort) args) async {
  final (dbPath, tempDir, jobs, port) = args;
  final client = IOClient(HttpClient()
    ..connectionTimeout = const Duration(seconds: 20)
    ..userAgent = 'ChudIPTV/1');
  try {
    port.send(await runEpgImport(dbPath, tempDir, jobs, client, port.send));
  } finally {
    client.close();
  }
}

/// Importe chaque source. Comme pour les catalogues : téléchargement complet d'abord, puis une
/// transaction par source. Un guide illisible laisse l'ancien en place.
Future<EpgReport> runEpgImport(String dbPath, String tempDir, List<EpgJob> jobs, http.Client client, void Function(int) onProgress) async {
  final db = openDatabase(dbPath);
  final work = await Directory(tempDir).createTemp('epg');
  var total = 0;
  final failed = <String>[];
  try {
    for (final job in jobs) {
      try {
        final file = job.path.isNotEmpty ? File(job.path) : await _download(client, job.url, work);
        total += await _write(db, job, file, (n) => onProgress(total + n));
      } catch (e) {
        failed.add(job.name);
        db.execute('UPDATE epg_sources SET error = ? WHERE id = ?', ['$e'.split(':').first, job.id]);
      }
    }
    final linked = relinkChannels(db);
    db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
    return EpgReport(programs: total, linked: linked, failed: failed);
  } finally {
    db.close();
    try {
      await work.delete(recursive: true);
    } on FileSystemException {
      // Dossier temporaire : le système finira par le nettoyer.
    }
  }
}

Future<File> _download(http.Client client, String url, Directory work) async {
  final response = await client.send(http.Request('GET', Uri.parse(url))).timeout(const Duration(seconds: 40));
  if (response.statusCode != 200) throw HttpException('HTTP ${response.statusCode}');
  final file = File('${work.path}/guide.xml');
  final sink = file.openWrite();
  try {
    await response.stream.timeout(const Duration(seconds: 60)).pipe(sink);
  } finally {
    await sink.close();
  }
  return file;
}

Future<int> _write(Database db, EpgJob job, File file, void Function(int) onProgress) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final earliest = now - _daysBack * 86400;
  final latest = now + _daysAhead * 86400;
  var count = 0;
  db.execute('BEGIN IMMEDIATE');
  final insert = db.prepare('INSERT INTO epg_programs(epg_id, channel, start, stop, title, description) VALUES(?,?,?,?,?,?)');
  final channel = db.prepare('INSERT OR REPLACE INTO epg_channels(channel, name_key) VALUES(?, ?)');
  try {
    db.execute('DELETE FROM epg_programs WHERE epg_id = ?', [job.id]);
    await for (final entry in parseXmltv(openXmltv(file))) {
      if (entry is XmltvChannel) {
        for (final name in entry.names) {
          channel.execute([entry.id.toLowerCase(), guideNameKey(sortKey(name))]);
        }
      } else if (entry is XmltvProgram && entry.stop >= earliest && entry.start <= latest) {
        insert.execute([job.id, entry.channel.toLowerCase(), entry.start, entry.stop, entry.title, entry.description]);
        if (++count % 5000 == 0) onProgress(count);
      }
    }
    if (count == 0) throw const FormatException('Guide vide');
    db.execute('UPDATE epg_sources SET refreshed_at = ?, error = NULL, programs = ? WHERE id = ?', [now, count, job.id]);
    db.execute('COMMIT');
    return count;
  } catch (_) {
    db.execute('ROLLBACK');
    rethrow;
  } finally {
    insert.close();
    channel.close();
  }
}

/// Chaîne du guide portant ce nom. Un même nom existe dans plusieurs pays (`cnbc.us`, `cnbc.uk`) :
/// sans certitude, on n'associe rien, car un faux programme est pire qu'une ligne vide.
String? matchByName(List<String> candidates, String country) {
  final suffix = '.${country.toLowerCase().replaceFirst('gb', 'uk')}';
  if (country.isNotEmpty) {
    final sameCountry = candidates.where((c) => c.endsWith(suffix)).firstOrNull;
    if (sameCountry != null) return sameCountry;
    return candidates.length == 1 && !RegExp(r'\.[a-z]{2}$').hasMatch(candidates.single) ? candidates.single : null;
  }
  return candidates.length == 1 ? candidates.single : null;
}

/// Associe les chaînes au guide : par identifiant tvg, puis par nom. Les choix manuels ne bougent pas.
int relinkChannels(Database db) {
  final byId = <String>{};
  final byName = <String, List<String>>{};
  // Un guide déclare souvent des chaînes sans aucun programme : les associer ne donnerait que des lignes vides.
  final filled = {for (final r in db.select('SELECT DISTINCT channel FROM epg_programs')) r.columnAt(0) as String};
  for (final r in db.select('SELECT channel, name_key FROM epg_channels')) {
    if (r.columnAt(0) == '' || !filled.contains(r.columnAt(0))) continue;
    byId.add(r.columnAt(0) as String);
    final name = r.columnAt(1) as String;
    if (name.isNotEmpty) byName.putIfAbsent(name, () => []).add(r.columnAt(0) as String);
  }
  db.execute('BEGIN IMMEDIATE');
  db.execute('DELETE FROM epg_links WHERE manual = 0 OR item_id NOT IN (SELECT id FROM items)');
  final insert = db.prepare('INSERT OR IGNORE INTO epg_links(item_id, channel, manual) VALUES(?, ?, 0)');
  var linked = 0;
  final query = db.prepare('SELECT id, tvg_id, sort_name, country FROM items WHERE type = 0');
  final rows = query.selectCursor();
  while (rows.moveNext()) {
    final r = rows.current;
    final tvg = (r.columnAt(1) as String).toLowerCase();
    final named = byName[guideNameKey(r.columnAt(2) as String)];
    final channel = byId.contains(tvg) ? tvg : (named == null ? null : matchByName(named, r.columnAt(3) as String));
    if (channel == null) continue;
    insert.execute([r.columnAt(0), channel]);
    linked++;
  }
  query.close();
  insert.close();
  db.execute('COMMIT');
  return linked;
}
