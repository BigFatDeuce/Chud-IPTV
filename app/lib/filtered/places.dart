/// Grandes régions du classement FILTERED, dans leur ordre d'affichage.
const regionLabels = <String, String>{
  'EU': 'EU',
  'NA': 'NA',
  'LATAM': 'LATAM',
  'ARABIC': 'ARABIC',
  'AF': 'AFRICA',
  'AS': 'ASIA',
  'OC': 'OCEANIA',
};

/// Un pays, ou une zone traitée comme un pays (ex-Yougoslavie, Caraïbes).
class Place {
  const Place(this.code, this.label, this.region, this.aliases, [this.tags = const []]);

  final String code;
  final String label;
  final String region;

  /// Formes normalisées, reconnues comme mots entiers n'importe où dans le nom du groupe.
  /// Jamais de code à deux lettres ici, sauf `uk` : « it », « de » ou « es » sont des mots courants.
  final List<String> aliases;

  /// Codes reconnus seulement en majuscules et en préfixe délimité (« DE | », « [FR] »).
  final List<String> tags;
}

const places = <Place>[
  // Europe.
  Place('FR', 'FRANCE', 'EU', ['france', 'french', 'francais', 'francaise', 'dom tom'], ['FR', 'FRA']),
  Place('GB', 'UNITED KINGDOM', 'EU', ['uk', 'united kingdom', 'great britain', 'britain', 'british', 'england', 'english', 'cymru', 'scottish'], ['UK', 'GB', 'ENG']),
  Place('IE', 'IRELAND', 'EU', ['ireland', 'irish'], ['IE']),
  Place('DE', 'GERMANY', 'EU', ['germany', 'german', 'deutschland', 'deutsch', 'allemagne'], ['DE', 'GER', 'DEU']),
  Place('IT', 'ITALY', 'EU', ['italy', 'italia', 'italian', 'italie'], ['IT', 'ITA']),
  Place('ES', 'SPAIN', 'EU', ['spain', 'espana', 'spanish', 'espagne', 'espanol'], ['ES', 'ESP']),
  Place('PT', 'PORTUGAL', 'EU', ['portugal', 'portuguese', 'portugues'], ['PT', 'POR']),
  Place('NL', 'NETHERLANDS', 'EU', ['netherlands', 'nederland', 'holland', 'dutch', 'pays bas'], ['NL', 'NLD']),
  Place('BE', 'BELGIUM', 'EU', ['belgium', 'belgique', 'belgie', 'belgian'], ['BE', 'BEL']),
  Place('CH', 'SWITZERLAND', 'EU', ['switzerland', 'suisse', 'schweiz', 'swiss'], ['CH', 'SUI']),
  Place('AT', 'AUSTRIA', 'EU', ['austria', 'osterreich', 'autriche'], ['AT', 'AUT']),
  Place('SE', 'SWEDEN', 'EU', ['sweden', 'sverige', 'swedish', 'suede'], ['SE', 'SWE']),
  Place('DK', 'DENMARK', 'EU', ['denmark', 'danmark', 'danish'], ['DK', 'DNK']),
  Place('FI', 'FINLAND', 'EU', ['finland', 'suomi', 'finnish'], ['FI', 'FIN']),
  Place('NO', 'NORWAY', 'EU', ['norway', 'norge', 'norwegian'], ['NO', 'NOR']),
  Place('IS', 'ICELAND', 'EU', ['iceland', 'islande'], ['IS']),
  Place('PL', 'POLAND', 'EU', ['poland', 'polska', 'polish', 'pologne'], ['PL', 'POL']),
  Place('RO', 'ROMANIA', 'EU', ['romania', 'romanian', 'roumanie'], ['RO', 'ROM']),
  Place('HU', 'HUNGARY', 'EU', ['hungary', 'magyar', 'hongrie'], ['HU']),
  Place('BG', 'BULGARIA', 'EU', ['bulgaria', 'bulgarie'], ['BG']),
  Place('GR', 'GREECE', 'EU', ['greece', 'greek', 'grece'], ['GR']),
  Place('CY', 'CYPRUS', 'EU', ['cyprus', 'chypre'], ['CY']),
  Place('MT', 'MALTA', 'EU', ['malta', 'malte'], ['MT']),
  Place('RU', 'RUSSIA', 'EU', ['russia', 'russian', 'russie'], ['RU', 'RUS']),
  Place('CZ', 'CZECHIA', 'EU', ['czech', 'czechia', 'tchequie'], ['CZ']),
  Place('SK', 'SLOVAKIA', 'EU', ['slovakia', 'slovaquie'], ['SK']),
  Place('UA', 'UKRAINE', 'EU', ['ukraine', 'ukrainian'], ['UA']),
  Place('LT', 'LITHUANIA', 'EU', ['lithuania', 'lituanie'], ['LT']),
  Place('LV', 'LATVIA', 'EU', ['latvia', 'lettonie'], ['LV']),
  Place('EE', 'ESTONIA', 'EU', ['estonia', 'estonie'], ['EE']),
  Place('GE', 'GEORGIA', 'EU', ['georgia', 'georgie'], ['GE']),
  Place('ALB', 'ALBANIA', 'EU', ['albania', 'albanian', 'albanie', 'shqip'], ['AL']),
  Place('RS', 'SERBIA', 'EU', ['serbia', 'srbija', 'serbie'], ['RS']),
  Place('HR', 'CROATIA', 'EU', ['croatia', 'hrvatska', 'croatie'], ['HR']),
  Place('BA', 'BOSNIA', 'EU', ['bosnia', 'bosnie'], ['BA']),
  Place('MK', 'MACEDONIA', 'EU', ['macedonia', 'macedoine'], ['MK']),
  Place('SI', 'SLOVENIA', 'EU', ['slovenia', 'slovenie'], ['SI']),
  Place('XY', 'EX-YU', 'EU', ['exyu', 'ex yu', 'yugoslavia'], ['YU']),
  Place('TR', 'TURKEY', 'EU', ['turkey', 'turkiye', 'turk', 'turkish', 'turquie'], ['TR', 'TUR']),
  Place('ARM', 'ARMENIA', 'EU', ['armenia', 'armenie'], []),
  Place('AZ', 'AZERBAIJAN', 'EU', ['azerbaijan', 'azerbaidjan'], ['AZ']),
  // Amérique du Nord.
  Place('US', 'USA', 'NA', ['usa', 'united states', 'etats unis'], ['US', 'USA']),
  Place('CA', 'CANADA', 'NA', ['canada', 'canadian', 'quebec'], ['CA', 'CAN']),
  // Amérique latine.
  Place('MX', 'MEXICO', 'LATAM', ['mexico', 'mexique'], ['MX', 'MEX']),
  Place('ARG', 'ARGENTINA', 'LATAM', ['argentina', 'argentine'], ['ARG']),
  Place('BR', 'BRAZIL', 'LATAM', ['brazil', 'brasil', 'bresil'], ['BR', 'BRA']),
  Place('CL', 'CHILE', 'LATAM', ['chile', 'chili'], ['CL']),
  Place('CO', 'COLOMBIA', 'LATAM', ['colombia', 'colombie'], ['CO']),
  Place('EC', 'ECUADOR', 'LATAM', ['ecuador', 'equateur'], ['EC']),
  Place('SV', 'EL SALVADOR', 'LATAM', ['el salvador', 'salvador'], ['SV']),
  Place('CR', 'COSTA RICA', 'LATAM', ['costa rica'], ['CR']),
  Place('HN', 'HONDURAS', 'LATAM', ['honduras'], ['HN']),
  Place('PY', 'PARAGUAY', 'LATAM', ['paraguay'], ['PY']),
  Place('PE', 'PERU', 'LATAM', ['peru', 'perou'], ['PE']),
  Place('UY', 'URUGUAY', 'LATAM', ['uruguay'], ['UY']),
  Place('VE', 'VENEZUELA', 'LATAM', ['venezuela'], ['VE']),
  Place('BO', 'BOLIVIA', 'LATAM', ['bolivia', 'bolivie'], ['BO']),
  Place('PA', 'PANAMA', 'LATAM', ['panama'], ['PA']),
  Place('HT', 'HAITI', 'LATAM', ['haiti'], ['HT']),
  Place('DO', 'DOMINICAN REPUBLIC', 'LATAM', ['dominican', 'dominicana'], ['DO']),
  Place('SR', 'SURINAME', 'LATAM', ['suriname'], ['SR']),
  Place('XC', 'CARIBBEAN', 'LATAM', ['caribbean', 'caraibes'], []),
  // Monde arabe.
  Place('MA', 'MOROCCO', 'ARABIC', ['morocco', 'maroc'], ['MA']),
  Place('DZ', 'ALGERIA', 'ARABIC', ['algeria', 'algerie'], ['DZ']),
  Place('TN', 'TUNISIA', 'ARABIC', ['tunisia', 'tunisie'], ['TN']),
  Place('MR', 'MAURITANIA', 'ARABIC', ['mauritania', 'mauritanie'], ['MR']),
  Place('LY', 'LIBYA', 'ARABIC', ['libya', 'libye'], ['LY']),
  Place('EG', 'EGYPT', 'ARABIC', ['egypt', 'egypte'], ['EG']),
  Place('SD', 'SUDAN', 'ARABIC', ['sudan', 'soudan'], ['SD']),
  Place('PS', 'PALESTINE', 'ARABIC', ['palestine'], ['PS']),
  Place('LB', 'LEBANON', 'ARABIC', ['lebanon', 'liban'], ['LB']),
  Place('SY', 'SYRIA', 'ARABIC', ['syria', 'syrie'], ['SY']),
  Place('JO', 'JORDAN', 'ARABIC', ['jordan', 'jordanie'], ['JO']),
  Place('IQ', 'IRAQ', 'ARABIC', ['iraq', 'irak'], ['IQ']),
  Place('SA', 'SAUDI ARABIA', 'ARABIC', ['saudi', 'saudi arabia', 'ksa'], ['KSA']),
  Place('KW', 'KUWAIT', 'ARABIC', ['kuwait', 'koweit'], ['KW']),
  Place('BH', 'BAHRAIN', 'ARABIC', ['bahrain', 'bahrein'], ['BH']),
  Place('OM', 'OMAN', 'ARABIC', ['oman'], ['OM']),
  Place('AE', 'EMIRATES', 'ARABIC', ['emirates', 'uae', 'emirats'], ['AE', 'UAE']),
  Place('QA', 'QATAR', 'ARABIC', ['qatar'], ['QA']),
  Place('YE', 'YEMEN', 'ARABIC', ['yemen'], ['YE']),
  // Afrique.
  Place('SN', 'SENEGAL', 'AF', ['senegal'], ['SN']),
  Place('SO', 'SOMALIA', 'AF', ['somalia', 'somalie'], ['SO']),
  Place('CM', 'CAMEROON', 'AF', ['cameroon', 'cameroun'], ['CM']),
  Place('GH', 'GHANA', 'AF', ['ghana'], ['GH']),
  Place('ET', 'ETHIOPIA', 'AF', ['ethiopia', 'ethiopie'], ['ET']),
  Place('KE', 'KENYA', 'AF', ['kenya'], ['KE']),
  Place('CD', 'CONGO', 'AF', ['congo'], ['CD', 'CG']),
  Place('NG', 'NIGERIA', 'AF', ['nigeria'], ['NG']),
  Place('UG', 'UGANDA', 'AF', ['uganda', 'ouganda'], ['UG']),
  Place('ZA', 'SOUTH AFRICA', 'AF', ['south africa', 'afrique du sud'], ['ZA']),
  Place('CI', 'IVORY COAST', 'AF', ['ivory coast', 'cote d ivoire'], ['CI']),
  // Asie.
  Place('IN', 'INDIA', 'AS', ['india', 'inde', 'hindi', 'tamil', 'telugu', 'malayalam', 'punjabi', 'marathi', 'gujarati', 'bhojpuri', 'kannada'], ['IN', 'IND']),
  Place('PK', 'PAKISTAN', 'AS', ['pakistan'], ['PK', 'PAK']),
  Place('IR', 'IRAN', 'AS', ['iran', 'persian', 'farsi'], ['IR']),
  Place('IL', 'ISRAEL', 'AS', ['israel'], ['IL']),
  Place('AFG', 'AFGHANISTAN', 'AS', ['afghanistan'], []),
  Place('KZ', 'KAZAKHSTAN', 'AS', ['kazakhstan'], ['KZ']),
  Place('JP', 'JAPAN', 'AS', ['japan', 'japon', 'japanese'], ['JP']),
  Place('ID', 'INDONESIA', 'AS', ['indonesia', 'indonesie'], ['ID']),
  Place('MY', 'MALAYSIA', 'AS', ['malaysia', 'malasia', 'malaisie'], ['MY']),
  Place('BD', 'BANGLADESH', 'AS', ['bangladesh', 'bangla'], ['BD']),
  Place('PH', 'PHILIPPINES', 'AS', ['philippine', 'philippines'], ['PH']),
  Place('LK', 'SRI LANKA', 'AS', ['sri lanka'], ['LK']),
  Place('VN', 'VIETNAM', 'AS', ['vietnam'], ['VN']),
  Place('SG', 'SINGAPORE', 'AS', ['singapore', 'singapour'], ['SG']),
  Place('KR', 'KOREA', 'AS', ['korea', 'coree'], ['KR']),
  Place('TH', 'THAILAND', 'AS', ['thailand', 'thailande', 'thailland'], ['TH']),
  Place('CN', 'CHINA', 'AS', ['china', 'chine', 'chinese'], ['CN']),
  Place('TW', 'TAIWAN', 'AS', ['taiwan'], ['TW']),
  Place('KH', 'CAMBODIA', 'AS', ['cambodia', 'cambodge'], ['KH']),
  Place('KUR', 'KURDISH', 'AS', ['kurdish', 'kurdistan', 'ezidxan'], []),
  // Océanie.
  Place('AU', 'AUSTRALIA', 'OC', ['australia', 'australie'], ['AU', 'AUS']),
  Place('NZ', 'NEW ZEALAND', 'OC', ['new zealand', 'nouvelle zelande'], ['NZ']),
];

/// Alias qui désignent une langue plutôt qu'un pays : ils s'effacent si un pays est nommé.
const languageAliases = {
  'french', 'francais', 'francaise', 'english', 'german', 'deutsch', 'spanish', 'espanol', 'portuguese', 'portugues', 'italian', 'dutch',
  'russian', 'turkish', 'polish', 'swedish', 'danish', 'finnish', 'norwegian', 'chinese', 'japanese', 'hindi', 'tamil', 'telugu',
  'malayalam', 'punjabi', 'marathi', 'gujarati', 'bhojpuri', 'kannada', 'bangla', 'persian', 'farsi', 'albanian', 'romanian', 'greek',
};

/// Codes de région annoncés en préfixe par les fournisseurs (`EU | …`). `AM` couvre les deux
/// Amériques : seul le pays permet de trancher.
const regionTags = <String, String>{
  'EU': 'EU', 'EUR': 'EU', 'EUROPE': 'EU',
  'NA': 'NA',
  'LAT': 'LATAM', 'LATAM': 'LATAM', 'LATINO': 'LATAM',
  'AR': 'ARABIC', 'ARB': 'ARABIC', 'ARA': 'ARABIC', 'ARAB': 'ARABIC', 'ARABIC': 'ARABIC', 'MENA': 'ARABIC',
  'AF': 'AF', 'AFR': 'AF', 'AFRICA': 'AF',
  'AS': 'AS', 'ASIA': 'AS',
  'OC': 'OC',
};

/// Mots qui désignent une région sans désigner de pays.
const regionWords = <String, String>{
  'europe': 'EU',
  'european': 'EU',
  'scandinave': 'EU',
  'scandinavia': 'EU',
  'nordic': 'EU',
  'latino': 'LATAM',
  'latin': 'LATAM',
  'latam': 'LATAM',
  'arab': 'ARABIC',
  'arabe': 'ARABIC',
  'arabic': 'ARABIC',
  'africa': 'AF',
  'afrique': 'AF',
  'african': 'AF',
  'asia': 'AS',
  'asian': 'AS',
  'asie': 'AS',
};

/// Thèmes du classement, dans leur ordre d'affichage. Les orthographes approximatives relevées
/// chez les fournisseurs (« entertaiment », « documentries ») sont volontairement incluses.
const themes = <String, List<String>>{
  'SPORTS': [
    'sport', 'sports', 'spor', 'desporto', 'deportes', 'football', 'foot', 'soccer', 'rugby', 'tennis', 'golf', 'cricket', 'hockey',
    'handboll', 'innebandy', 'basketball', 'boxing', 'ufc', 'wwe', 'nfl', 'nba', 'mlb', 'nhl', 'mls', 'ncaa', 'milb', 'whl', 'ohl',
    'qmjhl', 'f1', 'formula', 'motogp', 'laliga', 'lcampeones', 'euroleague', 'olympics', 'fifa', 'efl', 'epl', 'dart', 'darts',
    'espn', 'dazn', 'mysports', 'sporttotal', 'αθλητικα',
  ],
  'NEWS': ['news', 'info', 'infos', 'information', 'informations', 'actualites', 'noticias', 'nachrichten', 'haber', 'lajme'],
  'ENTERTAINMENT': [
    'entertainment', 'entertaiment', 'entertanment', 'entertenment', 'entartenmant', 'entrtenment', 'divertissement', 'entretenimento',
    'entretenimiento', 'unterhaltung', 'variety', 'ψυχαγωγια',
  ],
  'MOVIES': ['cinema', 'cine', 'movie', 'movies', 'film', 'films', 'filma', 'sinema', 'peliculas', 'κινηματογραφος'],
  'DOCUMENTARIES': [
    'documentary', 'documentaries', 'documentries', 'documentaire', 'documentaires', 'documental', 'documentarios', 'docum', 'doc', 'docs',
    'dokumentare', 'belgesel', 'nature', 'discovery', 'history', 'science',
  ],
  'KIDS': ['kids', 'kidz', 'kid', 'enfants', 'enfant', 'jeunesse', 'infantil', 'cartoon', 'cartoons', 'femijet', 'cocuk', 'kinder', 'ninos', 'junior', 'παιδικα'],
  'MUSIC': ['music', 'musique', 'musica', 'muzike', 'muzik', 'ραδιοφωνο'],
  'GENERAL': ['general', 'generale', 'generales', 'generalistes', 'geral', 'gjenerale', 'ulusal', 'γενικα'],
  'RELIGION': ['islamic', 'islame', 'islam', 'dini', 'christian', 'quran', 'coran', 'religion', 'religious'],
  'EVENTS': ['ppv', 'events', 'event', 'evento'],
  '24/7': ['24 7'],
  'ADULT': ['adult', 'adults', 'adulte', 'adultes', 'xxx'],
};
