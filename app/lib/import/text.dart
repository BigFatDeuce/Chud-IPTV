const _folds = <String, String>{
  'a': 'àáâãäåāăą',
  'c': 'çćĉċč',
  'd': 'ďđ',
  'e': 'èéêëēĕėęě',
  'g': 'ĝğġģ',
  'h': 'ĥħ',
  'i': 'ìíîïĩīĭįı',
  'j': 'ĵ',
  'k': 'ķ',
  'l': 'ĺļľŀł',
  'n': 'ñńņňŉ',
  'o': 'òóôõöøōŏő',
  'r': 'ŕŗř',
  's': 'śŝşš',
  't': 'ţťŧ',
  'u': 'ùúûüũūŭůűų',
  'w': 'ŵ',
  'y': 'ýÿŷ',
  'z': 'źżž',
  'ae': 'æ',
  'oe': 'œ',
  'ss': 'ß',
};

final Map<int, List<int>> _foldTable = {
  for (final e in _folds.entries)
    for (final unit in e.value.codeUnits) unit: e.key.codeUnits,
};

/// Espaces insécables, ponctuation typographique et symboles décoratifs (« ✦●✦ »).
bool _isSeparator(int unit) =>
    unit == 0xA0 || unit == 0xAD || unit == 0x3000 || unit == 0xFEFF || (unit >= 0x2000 && unit <= 0x206F) || (unit >= 0x2190 && unit <= 0x2BFF);

/// Forme de comparaison d'un nom : minuscules, sans accents, ponctuation réduite à des espaces.
/// Les alphabets non latins sont gardés tels quels.
String normalizeText(String input) {
  const space = 0x20;
  final out = <int>[];
  var pendingSpace = false;
  void put(int unit) {
    if (pendingSpace) out.add(space);
    pendingSpace = false;
    out.add(unit);
  }

  for (final unit in input.toLowerCase().codeUnits) {
    if ((unit >= 0x30 && unit <= 0x39) || (unit >= 0x61 && unit <= 0x7A)) {
      put(unit);
    } else if (unit < 0x80 || _isSeparator(unit)) {
      pendingSpace = out.isNotEmpty;
    } else if (unit < 0x0300 || unit > 0x036F) {
      (_foldTable[unit] ?? [unit]).forEach(put);
    }
  }
  return String.fromCharCodes(out);
}

final _leadingTag = RegExp(r'^\s*[\[(]?\s*[A-Z0-9+-]{2,8}\s*[\])|:]+\s*');

/// Clé de tri d'un nom : sans son préfixe de pays (« FR| TF1 » se range à T, pas à F).
String sortKey(String name) => normalizeText(name.replaceFirst(_leadingTag, ''));

/// Codes pays et langues qu'on reconnaît en tête d'un nom (« FR| », « [EN] », « DE: »).
const _countryTags = {
  'AD', 'AE', 'AF', 'AL', 'AM', 'AO', 'AR', 'AT', 'AU', 'AZ', 'BA', 'BD', 'BE', 'BF', 'BG', 'BH', 'BJ', 'BO', 'BR',
  'BY', 'CA', 'CD', 'CF', 'CG', 'CH', 'CI', 'CL', 'CM', 'CN', 'CO', 'CR', 'CU', 'CY', 'CZ', 'DE', 'DK', 'DO', 'DZ',
  'EC', 'EE', 'EG', 'EN', 'ES', 'ET', 'EU', 'FI', 'FR', 'GA', 'GB', 'GE', 'GH', 'GN', 'GR', 'GT', 'HK', 'HN', 'HR',
  'HT', 'HU', 'ID', 'IE', 'IL', 'IN', 'IQ', 'IR', 'IS', 'IT', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KR', 'KW', 'KZ',
  'LA', 'LB', 'LK', 'LT', 'LU', 'LV', 'LY', 'MA', 'MD', 'ME', 'MG', 'MK', 'ML', 'MM', 'MR', 'MT', 'MU', 'MX', 'MY',
  'MZ', 'NE', 'NG', 'NI', 'NL', 'NO', 'NP', 'NZ', 'OM', 'PA', 'PE', 'PH', 'PK', 'PL', 'PR', 'PS', 'PT', 'PY', 'QA',
  'RO', 'RS', 'RU', 'RW', 'SA', 'SD', 'SE', 'SG', 'SI', 'SK', 'SN', 'SO', 'SV', 'SY', 'TD', 'TG', 'TH', 'TJ', 'TN',
  'TR', 'TW', 'TZ', 'UA', 'UG', 'UK', 'US', 'UY', 'UZ', 'VE', 'VN', 'YE', 'ZA', 'ZM', 'ZW',
};

final _tagPattern = RegExp(r'^\s*[\[(|]?\s*([A-Z]{2})(?:-[A-Z]{2,4})?\s*[\])|:\-]');

/// Pays ou langue annoncé par le préfixe d'un nom ou d'un groupe ; vide si rien de sûr.
String detectCountry(String name, String group) {
  for (final text in [name, group]) {
    final tag = _tagPattern.firstMatch(text)?.group(1);
    if (tag != null && _countryTags.contains(tag)) return tag == 'UK' ? 'GB' : tag;
  }
  return '';
}

/// Empreinte FNV-1a 64 bits : stable d'un lancement à l'autre, contrairement à `hashCode`.
int fingerprint(Iterable<Object?> parts) {
  var h = 0xcbf29ce484222325;
  for (final part in parts) {
    for (final unit in '$part'.codeUnits) {
      h = (h ^ unit) * 0x100000001b3;
    }
    h = (h ^ 0xFFFF) * 0x100000001b3;
  }
  return h;
}

const _volatileParams = {
  'token', 'auth', 'sign', 'signature', 'sig', 'hash', 'md5', 'expires', 'exp', 'e', 'st', 'wmsauthsign', 'nimblesessionid',
  'u', 'p', 'user', 'pass', 'username', 'password', 'uid', 'session',
};

/// Clé d'un flux qui survit au changement de domaine ou de jeton.
///
/// Les adresses de type Xtream (`/live/<user>/<pass>/12345.ts`) se réduisent au type et au numéro,
/// ce qui en retire aussi les identifiants. Sinon on garde le chemin et les paramètres stables.
String streamKey(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return 'raw:$url';
  final parts = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (parts.isNotEmpty) {
    final last = parts.last.split('.').first;
    if (int.tryParse(last) != null && parts.length >= 3) {
      const kinds = {'live', 'movie', 'series'};
      final kind = parts.length >= 4 && kinds.contains(parts.first) ? parts.first : 'live';
      return 'id:$kind:$last';
    }
  }
  final params = uri.queryParametersAll.keys.where((k) => !_volatileParams.contains(k.toLowerCase())).toList()..sort();
  final query = params.map((k) => '$k=${uri.queryParametersAll[k]!.join(',')}').join('&');
  return 'path:${uri.path}${query.isEmpty ? '' : '?$query'}';
}
