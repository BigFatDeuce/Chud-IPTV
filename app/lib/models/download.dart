import 'catalog.dart';

/// État d'un téléchargement. Le nom est gardé en base. Seul `DownloadManager._move` le change.
enum DownloadState {
  queued,
  active,
  paused,
  done,
  failed;

  /// Les seuls passages permis. Un nouvel état s'ajoute ici, et dans `test/download_test.dart`.
  bool canBecome(DownloadState next) => switch (this) {
        // Démarre, est mis en pause avant son tour, ou sa source n'existe plus.
        queued => next == active || next == paused || next == failed,
        // Se termine, échoue, est mis en pause, ou rend la connexion à une lecture.
        active => next != active,
        // « Reprendre » et « Réessayer » remettent dans la file.
        paused || failed => next == queued,
        // Le fichier a disparu du disque.
        done => next == failed,
      };
}

/// Pourquoi un téléchargement a échoué. L'ordre sert à passer d'un isolat à l'autre.
enum DownloadError { network, server, format, disk, source, missing }

/// Un film ou un épisode téléchargé, ou en passe de l'être.
class Download {
  Download({
    this.id = 0,
    required this.sourceId,
    required this.type,
    required this.streamKey,
    required this.title,
    required this.path,
    this.subtitle = '',
    this.logo = '',
    this.extension = '',
    this.url = '',
    this.headers = '',
    this.state = DownloadState.queued,
    this.received = 0,
    this.total,
    this.error,
  });

  int id;
  final int sourceId;
  final ItemType type;

  /// Clé stable du film ou de l'épisode : un même contenu n'est téléchargé qu'une fois.
  final String streamKey;
  final String title;
  final String subtitle;
  final String logo;
  final String extension;

  /// Destination finale ; le fichier porte `.part` tant qu'il n'est pas complet. Sur Android, une
  /// adresse `content://` une fois copié dans le dossier choisi par l'utilisateur.
  String path;

  /// Adresse d'une playlist. Vide pour un compte Xtream, dont l'adresse contient le mot de passe.
  final String url;
  final String headers;

  DownloadState state;
  int received;
  int? total;
  DownloadError? error;

  String get part => '$path.part';
  double? get progress => total == null || total == 0 ? null : (received / total!).clamp(0.0, 1.0);
}

/// Nom de fichier sûr sur Windows, Linux et Android, sans perdre les accents.
String safeFileName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim().replaceAll(RegExp(r'[. ]+$'), '');
  final short = cleaned.length > 120 ? cleaned.substring(0, 120).trim() : cleaned;
  if (short.isEmpty) return 'video';
  // CON, NUL, COM1… sont interdits comme noms de fichiers sous Windows.
  return RegExp(r'^(con|prn|aux|nul|com\d|lpt\d)$', caseSensitive: false).hasMatch(short) ? '_$short' : short;
}

/// Extension déclarée, sinon celle de l'adresse. Jamais rien d'autre de l'adresse, qui peut
/// contenir des identifiants.
String videoExtension(String declared, String url) {
  final clean = declared.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  if (clean.isNotEmpty) return clean;
  final path = Uri.tryParse(url)?.path ?? '';
  final match = RegExp(r'\.([a-zA-Z0-9]{2,5})$').firstMatch(path);
  return match?.group(1)?.toLowerCase() ?? 'mp4';
}

/// Vrai pour une liste HLS : des centaines de morceaux, pas un fichier à enregistrer.
bool isSegmented(String extension) => extension == 'm3u8' || extension == 'm3u';
