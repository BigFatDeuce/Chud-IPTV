import 'dart:convert';
import 'dart:typed_data';

import '../models/catalog.dart';
import '../models/source.dart';
import 'entry.dart';
import 'text.dart';

/// Adresse de serveur saisie par l'utilisateur, ramenée à sa racine : ajoute `http://`, retire les
/// `/`, `/player_api.php` ou `/get.php?...` collés par erreur.
String normalizeServer(String input) {
  var s = input.trim();
  if (!s.contains('://')) s = 'http://$s';
  final uri = Uri.tryParse(s);
  if (uri == null || uri.host.isEmpty) return s;
  var path = uri.path.replaceAll(RegExp(r'/+$'), '');
  path = path.replaceFirst(RegExp(r'/(player_api|get|xmltv)\.php$'), '');
  return Uri(scheme: uri.scheme, host: uri.host, port: uri.hasPort ? uri.port : null, path: path).toString();
}

Uri xtreamUri(Source source, [String? action]) => Uri.parse('${normalizeServer(source.url)}/player_api.php').replace(
      queryParameters: {'username': source.username, 'password': source.password, 'action': ?action},
    );

int? _int(Object? v) => switch (v) {
      int() => v,
      double() => v.toInt(),
      String() => int.tryParse(v.trim()),
      _ => null,
    };

double? _double(Object? v) => switch (v) {
      num() => v.toDouble(),
      String() => double.tryParse(v.trim()),
      _ => null,
    };

String _string(Object? v) => v == null ? '' : '$v'.trim();

/// État du compte renvoyé par `player_api.php`.
class XtreamAccount {
  const XtreamAccount({this.expiresAt, this.maxConnections, this.serverOffset = 0});

  final DateTime? expiresAt;
  final int? maxConnections;

  /// Décalage du serveur par rapport à UTC, en minutes.
  final int serverOffset;

  /// Refuse un compte rejeté ou expiré ; un serveur qui ne parle pas Xtream est une donnée invalide.
  factory XtreamAccount.fromJson(Object? json) {
    final info = json is Map ? json['user_info'] : null;
    if (info is! Map) throw const ImportFailure(ImportError.invalidData);
    if (_int(info['auth']) != 1) throw const ImportFailure(ImportError.credentials);
    final status = _string(info['status']).toLowerCase();
    if (status == 'expired') throw const ImportFailure(ImportError.expired);
    if (status.isNotEmpty && status != 'active') throw const ImportFailure(ImportError.credentials);
    final exp = _int(info['exp_date']);
    return XtreamAccount(
      expiresAt: exp == null || exp == 0 ? null : DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      maxConnections: _int(info['max_connections']),
      serverOffset: _serverOffset((json as Map)['server_info']),
    );
  }
}

/// Le serveur donne son heure locale et l'heure UTC : leur écart est son fuseau, arrondi au quart d'heure.
int _serverOffset(Object? info) {
  if (info is! Map) return 0;
  final local = DateTime.tryParse('${info['time_now']}Z');
  final utc = _int(info['timestamp_now']);
  if (local == null || utc == null) return 0;
  final minutes = (local.millisecondsSinceEpoch ~/ 1000 - utc) / 60;
  return (minutes / 15).round() * 15;
}

/// Adresse du guide XMLTV d'un compte.
String xtreamGuideUrl(Source source) => Uri.parse('${normalizeServer(source.url)}/xmltv.php')
    .replace(queryParameters: {'username': source.username, 'password': source.password})
    .toString();

/// Une catégorie déclarée par l'API.
class XtreamCategory {
  const XtreamCategory(this.remoteId, this.name);

  final String remoteId;
  final String name;

  static List<XtreamCategory> listFrom(Object? json) {
    if (json is! List) return const [];
    return [
      for (final c in json)
        if (c is Map && c['category_id'] != null) XtreamCategory(_string(c['category_id']), _string(c['category_name'])),
    ];
  }
}

/// Découpe un tableau JSON d'objets en objets individuels, à mesure que les octets arrivent.
///
/// Les listes de films pèsent plusieurs dizaines de Mo : les décoder d'un bloc ferait exploser la
/// mémoire d'un téléphone. Lève [ImportFailure] si le document n'est pas un tableau ou s'il est tronqué.
Stream<Map<String, dynamic>> splitJsonArray(Stream<List<int>> bytes) async* {
  const openBrace = 0x7B, closeBrace = 0x7D, openBracket = 0x5B, closeBracket = 0x5D;
  const quote = 0x22, backslash = 0x5C;
  var started = false;
  var finished = false;
  var depth = 0;
  var inString = false;
  var escaped = false;
  final current = BytesBuilder(copy: false);

  await for (final chunk in bytes) {
    final data = chunk is Uint8List ? chunk : Uint8List.fromList(chunk);
    var start = 0; // Début, dans ce morceau, de l'objet en cours.
    for (var i = 0; i < data.length; i++) {
      final b = data[i];
      if (!started) {
        if (b == openBracket) {
          started = true;
        } else if (b > 0x20 && b != 0xEF && b != 0xBB && b != 0xBF) {
          throw const ImportFailure(ImportError.invalidData);
        }
        continue;
      }
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (b == backslash) {
          escaped = true;
        } else if (b == quote) {
          inString = false;
        }
        continue;
      }
      if (depth == 0) {
        if (b == openBrace) {
          depth = 1;
          start = i;
        } else if (b == closeBracket) {
          finished = true;
        }
        continue;
      }
      if (b == quote) {
        inString = true;
      } else if (b == openBrace) {
        depth++;
      } else if (b == closeBrace && --depth == 0) {
        current.add(Uint8List.sublistView(data, start, i + 1));
        yield _decodeObject(current.takeBytes());
      }
    }
    if (depth > 0) current.add(Uint8List.sublistView(data, start));
  }
  if (!finished) throw const ImportFailure(ImportError.invalidData);
}

Map<String, dynamic> _decodeObject(Uint8List bytes) {
  try {
    return jsonDecode(utf8.decode(bytes, allowMalformed: true)) as Map<String, dynamic>;
  } on FormatException {
    throw const ImportFailure(ImportError.invalidData);
  }
}

/// Convertit les objets de l'API. Les fournisseurs varient : un même champ peut être un nombre,
/// une chaîne ou `null`, et un élément sans identifiant ni nom est ignoré.
ImportEntry? xtreamEntry(ItemType type, Map<String, dynamic> j) {
  final id = _string(type == ItemType.series ? j['series_id'] : j['stream_id']);
  final name = _string(j['name']);
  if (id.isEmpty || name.isEmpty) return null;
  final category = _string(j['category_id']);
  final logo = _string(type == ItemType.series ? j['cover'] : j['stream_icon']);
  final archived = type == ItemType.live && _int(j['tv_archive']) == 1;
  return ImportEntry(
    type: type,
    key: 'id:$id',
    name: name,
    categoryRemote: category,
    logo: logo,
    country: detectCountry(name, ''),
    tvgId: _string(j['epg_channel_id']),
    extension: _string(j['container_extension']),
    catchup: archived ? 'xtream' : '',
    catchupDays: archived ? (_int(j['tv_archive_duration']) ?? 0) : 0,
    rating: _double(j['rating']),
    addedAt: _int(j['added'] ?? j['last_modified']),
  );
}
