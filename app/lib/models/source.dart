/// Origine d'une source. Le nom est celui gardé en base.
enum SourceKind { xtream, m3uUrl, m3uFile }

/// Pourquoi une actualisation a échoué. Le nom est gardé en base, le texte vient des traductions.
enum ImportError {
  network,
  timeout,
  credentials,
  expired,
  notFound,
  notPlaylist,
  invalidData,
  empty,
  suspicious,
  fileMissing,
  unknown,
}

/// Une source IPTV et l'état de sa dernière actualisation.
class Source {
  const Source({
    this.id = 0,
    required this.name,
    required this.kind,
    this.url = '',
    this.username = '',
    this.password = '',
    this.enabled = true,
    this.isDefault = false,
    this.withMovies = true,
    this.withSeries = true,
    this.epgUrl = '',
    this.expiresAt,
    this.maxConnections,
    this.refreshedAt,
    this.error,
    this.errorDetail = '',
    this.errorAt,
    this.liveCount = 0,
    this.movieCount = 0,
    this.seriesCount = 0,
    this.serverOffset = 0,
  });

  final int id;
  final String name;
  final SourceKind kind;

  /// Adresse du serveur (Xtream), de la playlist, ou chemin du fichier d'origine.
  final String url;
  final String username;
  final String password;
  final bool enabled;
  final bool isDefault;

  /// Faux : films ou séries ne sont pas importés, pour alléger le chargement.
  final bool withMovies;
  final bool withSeries;

  /// Guide des programmes annoncé par la playlist (`url-tvg`).
  final String epgUrl;
  final DateTime? expiresAt;
  final int? maxConnections;
  final DateTime? refreshedAt;
  final ImportError? error;

  /// Pour une liste suspecte : « 1200 → 30 ». Ne contient jamais d'identifiant.
  final String errorDetail;
  final DateTime? errorAt;
  final int liveCount;
  final int movieCount;
  final int seriesCount;

  /// Décalage du serveur par rapport à UTC, en minutes : les adresses de replay sont à son heure.
  final int serverOffset;

  Source copyWith({
    String? name,
    String? url,
    String? username,
    String? password,
    bool? enabled,
    bool? isDefault,
    bool? withMovies,
    bool? withSeries,
  }) =>
      Source(
        id: id,
        name: name ?? this.name,
        kind: kind,
        url: url ?? this.url,
        username: username ?? this.username,
        password: password ?? this.password,
        enabled: enabled ?? this.enabled,
        isDefault: isDefault ?? this.isDefault,
        withMovies: withMovies ?? this.withMovies,
        withSeries: withSeries ?? this.withSeries,
        epgUrl: epgUrl,
        expiresAt: expiresAt,
        maxConnections: maxConnections,
        refreshedAt: refreshedAt,
        error: error,
        errorDetail: errorDetail,
        errorAt: errorAt,
        liveCount: liveCount,
        movieCount: movieCount,
        seriesCount: seriesCount,
        serverOffset: serverOffset,
      );
}
