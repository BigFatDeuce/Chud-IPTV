import '../models/catalog.dart';
import '../models/source.dart';
import 'text.dart';

/// Échec d'une actualisation. Les données déjà en base ne sont pas touchées.
class ImportFailure implements Exception {
  const ImportFailure(this.kind, [this.detail = '']);

  final ImportError kind;

  /// Jamais d'adresse complète ici : elle peut contenir les identifiants.
  final String detail;

  @override
  String toString() => 'ImportFailure(${kind.name}, $detail)';
}

/// Élément lu dans une source, avant son rapprochement avec la base.
class ImportEntry {
  ImportEntry({
    required this.type,
    required this.key,
    required this.name,
    required this.categoryRemote,
    this.categoryName,
    this.logo = '',
    this.country = '',
    this.tvgId = '',
    this.tvgName = '',
    this.url = '',
    this.extension = '',
    this.catchup = '',
    this.catchupDays = 0,
    this.catchupSource = '',
    this.httpHeaders = '',
    this.rating,
    this.addedAt,
  }) : nameNorm = normalizeText(name);

  final ItemType type;
  final String key;
  final String name;
  final String nameNorm;
  final String categoryRemote;

  /// Nom à donner à la catégorie si elle est nouvelle (playlists, où elle n'est pas déclarée à part).
  final String? categoryName;
  final String logo;
  final String country;
  final String tvgId;
  final String tvgName;
  final String url;
  final String extension;
  final String catchup;
  final int catchupDays;
  final String catchupSource;
  final String httpHeaders;
  final double? rating;
  final int? addedAt;

  int get fingerprintValue => fingerprint([
        name, categoryRemote, logo, country, tvgId, tvgName, url, extension,
        catchup, catchupDays, catchupSource, httpHeaders, rating, addedAt,
      ]);
}
