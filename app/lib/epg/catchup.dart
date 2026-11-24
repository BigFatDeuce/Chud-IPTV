import '../data/repository.dart';
import '../import/xtream.dart';
import '../models/source.dart';
import '../player/playback.dart';
import '../player/streams.dart';

/// Un programme du guide. Les heures sont en secondes UTC.
class Program {
  const Program({required this.channel, required this.start, required this.stop, required this.title, this.description = ''});

  final String channel;
  final int start;
  final int stop;
  final String title;
  final String description;

  DateTime get startTime => DateTime.fromMillisecondsSinceEpoch(start * 1000);
  DateTime get stopTime => DateTime.fromMillisecondsSinceEpoch(stop * 1000);
  int get minutes => ((stop - start) / 60).ceil();
}

/// Vrai si ce programme se revoit : terminé, et encore dans la durée de conservation annoncée.
/// On ne suppose jamais qu'une chaîne a du replay : seule sa fiche le dit.
bool canReplay(StreamInfo info, Program program, DateTime now) {
  if (info.catchup.isEmpty || info.catchupDays <= 0) return false;
  final seconds = now.millisecondsSinceEpoch ~/ 1000;
  return program.stop <= seconds && program.start >= seconds - info.catchupDays * 86400;
}

String _two(int n) => n.toString().padLeft(2, '0');

/// `2026-10-31:18-30`, à l'heure du serveur.
String _xtreamStart(int seconds, int offsetMinutes) {
  final t = DateTime.fromMillisecondsSinceEpoch((seconds + offsetMinutes * 60) * 1000, isUtc: true);
  return '${t.year}-${_two(t.month)}-${_two(t.day)}:${_two(t.hour)}-${_two(t.minute)}';
}

String _fill(String template, Program p, int now) {
  final t = DateTime.fromMillisecondsSinceEpoch(p.start * 1000, isUtc: true);
  return template
      .replaceAll('{utc}', '${p.start}')
      .replaceAll(r'${start}', '${p.start}')
      .replaceAll('{start}', '${p.start}')
      .replaceAll('{lutc}', '$now')
      .replaceAll(r'${now}', '$now')
      .replaceAll('{end}', '${p.stop}')
      .replaceAll(r'${end}', '${p.stop}')
      .replaceAll('{duration}', '${p.stop - p.start}')
      .replaceAll('{Y}', '${t.year}')
      .replaceAll('{m}', _two(t.month))
      .replaceAll('{d}', _two(t.day))
      .replaceAll('{H}', _two(t.hour))
      .replaceAll('{M}', _two(t.minute))
      .replaceAll('{S}', _two(t.second));
}

/// Adresse de lecture d'un programme passé. Null si le format de replay n'est pas connu.
PlayRequest? catchupRequest(Source source, StreamInfo info, Program program, {DateTime? now}) {
  final current = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
  if (info.catchup == 'xtream') {
    final server = normalizeServer(source.url);
    final user = Uri.encodeComponent(source.username);
    final password = Uri.encodeComponent(source.password);
    final start = _xtreamStart(program.start, source.serverOffset);
    return PlayRequest(url: '$server/timeshift/$user/$password/${program.minutes}/$start/${xtreamId(info.stableKey)}.ts', live: false);
  }
  final base = playRequest(source, info);
  final template = info.catchupSource;
  String? url;
  switch (info.catchup) {
    case 'append' when template.isNotEmpty:
      url = base.url + _fill(template, program, current);
    case 'default' when template.isNotEmpty:
      url = _fill(template, program, current);
    case 'flussonic' || 'fs':
      url = base.url.replaceFirst(RegExp(r'/[^/]*\.m3u8(\?.*)?$'), '/index-${program.start}-${program.stop - program.start}.m3u8');
    case 'shift' || 'default':
      url = '${base.url}${base.url.contains('?') ? '&' : '?'}utc=${program.start}&lutc=$current';
  }
  return url == null ? null : PlayRequest(url: url, live: false, headers: base.headers);
}

/// Mots de qualité retirés d'un nom pour le rapprocher d'une chaîne du guide.
final _quality = RegExp(r'\b(uhd|fhd|hd|sd|4k|8k|hevc|h265|hq|lq|1080p?|720p?|50fps|60fps|backup|vip)\b');

/// Forme d'un nom utilisée pour associer une chaîne à son guide : « FR| TF1 FHD » et « TF1 » se rejoignent.
String guideNameKey(String sortName) => sortName.replaceAll(_quality, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
