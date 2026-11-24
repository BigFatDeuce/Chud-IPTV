import 'dart:convert';
import 'dart:io';

/// Chaîne déclarée par un guide.
class XmltvChannel {
  const XmltvChannel(this.id, this.names);

  final String id;
  final List<String> names;
}

/// Programme d'un guide. Les heures sont en secondes UTC.
class XmltvProgram {
  const XmltvProgram({required this.channel, required this.start, required this.stop, required this.title, required this.description});

  final String channel;
  final int start;
  final int stop;
  final String title;
  final String description;
}

final _time = RegExp(r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})?\s*([+-])?(\d{2})?(\d{2})?');

/// Lit une heure XMLTV : `20261031183000 +0100`. Sans décalage, elle est en UTC. Null si illisible.
int? parseXmltvTime(String text) {
  final m = _time.firstMatch(text.trim());
  if (m == null) return null;
  int part(int i) => int.parse(m.group(i) ?? '0');
  final utc = DateTime.utc(part(1), part(2), part(3), part(4), part(5), part(6));
  var offset = 0;
  if (m.group(7) != null) {
    offset = part(8) * 3600 + part(9) * 60;
    if (m.group(7) == '-') offset = -offset;
  }
  return utc.millisecondsSinceEpoch ~/ 1000 - offset;
}

final _entity = RegExp(r'&(#\d+|#x[0-9a-fA-F]+|amp|lt|gt|quot|apos);');
final _cdata = RegExp(r'<!\[CDATA\[(.*?)\]\]>', dotAll: true);

String _text(String raw) {
  final plain = raw.replaceAllMapped(_cdata, (m) => m[1]!).trim();
  return plain.replaceAllMapped(_entity, (m) {
    final e = m[1]!;
    return switch (e) {
      'amp' => '&',
      'lt' => '<',
      'gt' => '>',
      'quot' => '"',
      'apos' => "'",
      _ => String.fromCharCode(e.startsWith('#x') ? int.parse(e.substring(2), radix: 16) : int.parse(e.substring(1))),
    };
  });
}

String? _attribute(String tag, String name) {
  final m = RegExp('$name\\s*=\\s*(?:"([^"]*)"|\'([^\']*)\')').firstMatch(tag);
  final value = m?.group(1) ?? m?.group(2);
  return value == null ? null : _text(value);
}

final _displayName = RegExp(r'<display-name[^>]*>(.*?)</display-name>', dotAll: true);
final _title = RegExp(r'<title[^>]*>(.*?)</title>', dotAll: true);
final _description = RegExp(r'<desc[^>]*>(.*?)</desc>', dotAll: true);

/// Longueur gardée d'une description : un guide en contient des centaines de milliers.
const maxDescription = 400;

/// Lit un guide au fil de l'eau, sans le charger en mémoire : un fichier XMLTV pèse souvent
/// bien plus que les playlists. Renvoie des [XmltvChannel] et des [XmltvProgram].
Stream<Object> parseXmltv(Stream<List<int>> bytes) async* {
  var buffer = '';
  await for (final chunk in bytes.transform(const Utf8Decoder(allowMalformed: true))) {
    buffer += chunk;
    var position = 0;
    int? incomplete;
    while (true) {
      final channel = buffer.indexOf('<channel', position);
      final program = buffer.indexOf('<programme', position);
      final isChannel = channel >= 0 && (program < 0 || channel < program);
      final start = isChannel ? channel : program;
      if (start < 0) break;
      final closing = isChannel ? '</channel>' : '</programme>';
      final end = buffer.indexOf(closing, start);
      if (end < 0) {
        incomplete = start;
        break;
      }
      final block = buffer.substring(start, end);
      position = end + closing.length;
      final tag = block.substring(0, block.indexOf('>') + 1);
      if (isChannel) {
        final id = _attribute(tag, 'id');
        if (id != null) yield XmltvChannel(id, [for (final m in _displayName.allMatches(block)) _text(m[1]!)]);
        continue;
      }
      final id = _attribute(tag, 'channel');
      final from = parseXmltvTime(_attribute(tag, 'start') ?? '');
      final to = parseXmltvTime(_attribute(tag, 'stop') ?? '');
      final title = _title.firstMatch(block)?[1];
      if (id == null || from == null || to == null || title == null) continue;
      final description = _text(_description.firstMatch(block)?[1] ?? '');
      yield XmltvProgram(
        channel: id,
        start: from,
        stop: to,
        title: _text(title),
        description: description.length > maxDescription ? description.substring(0, maxDescription) : description,
      );
    }
    // On garde l'élément incomplet, ou la fin qui pourrait être le début d'une balise coupée.
    final tail = buffer.lastIndexOf('<');
    buffer = buffer.substring(incomplete ?? (tail >= position ? tail : buffer.length));
  }
}

/// Ouvre un fichier de guide, compressé ou non.
Stream<List<int>> openXmltv(File file) async* {
  final head = await file.openRead(0, 2).expand((b) => b).toList();
  final compressed = head.length == 2 && head[0] == 0x1F && head[1] == 0x8B;
  yield* compressed ? file.openRead().transform(gzip.decoder) : file.openRead();
}
