/// Adresse où sont publiées les versions (`latest.json`, sa signature et les installeurs) : le
/// dernier jeu de fichiers d'une version GitHub. Vide à la compilation : aucune recherche.
const releasesUrl = String.fromEnvironment('RELEASES_URL', defaultValue: 'https://github.com/BigFatDeuce/Chud-IPTV/releases/latest/download');

/// Clé publique Ed25519 qui authentifie `latest.json`. La clé privée ne quitte jamais la machine
/// de publication. Base64.
const updatePublicKey = String.fromEnvironment('UPDATE_PUBLIC_KEY', defaultValue: 'hQeNV2wkDWH7qkPcWRcm0P86ke1WZ3ss7ojqtbhjlWM=');

/// Un installeur publié pour une plateforme.
class ReleaseFile {
  const ReleaseFile({required this.name, required this.sha256, required this.size});

  factory ReleaseFile.fromJson(Map<String, dynamic> j) =>
      ReleaseFile(name: j['name'] as String, sha256: j['sha256'] as String, size: j['size'] as int);

  /// Nom du fichier, à côté de `latest.json`.
  final String name;
  final String sha256;
  final int size;

  Uri url(String base) => Uri.parse('$base/${Uri.encodeComponent(name)}');
}

/// Contenu de `latest.json` : dernière version publiée, ce qui change, et ses installeurs par
/// plateforme (`android-arm64`, `android-arm`, `windows`, `linux`).
class Release {
  const Release({required this.version, required this.files, this.notes = const {}});

  factory Release.fromJson(Map<String, dynamic> j) => Release(
        version: j['version'] as String,
        notes: (j['notes'] as Map<String, dynamic>? ?? const {}).map((k, v) => MapEntry(k, v as String)),
        files: (j['files'] as Map<String, dynamic>).map((k, v) => MapEntry(k, ReleaseFile.fromJson(v as Map<String, dynamic>))),
      );

  final String version;
  final Map<String, ReleaseFile> files;

  /// Ce qui change, par langue.
  final Map<String, String> notes;

  String notesFor(String language) => notes[language] ?? notes['en'] ?? notes['fr'] ?? '';
}

/// Compare deux versions « 1.2.3 » nombre par nombre (« 0.10.0 » est plus récente que « 0.9.1 »).
/// Ce qui suit un « + » ou un « - » est ignoré.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v.split(RegExp('[+-]')).first.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final x = parts(a), y = parts(b);
  for (var i = 0; i < 3; i++) {
    final d = (i < x.length ? x[i] : 0) - (i < y.length ? y[i] : 0);
    if (d != 0) return d.sign;
  }
  return 0;
}
