/// Nature d'un élément du catalogue. La valeur numérique est celle gardée en base : ne pas réordonner.
enum ItemType { live, movie, series }

/// Catégorie telle que la source la décrit. Les groupes personnels viendront s'ajouter à côté,
/// sans jamais modifier celle-ci.
class Category {
  const Category({
    required this.id,
    required this.sourceId,
    required this.type,
    required this.remoteId,
    required this.name,
    required this.itemCount,
  });

  final int id;
  final int sourceId;
  final ItemType type;

  /// Identifiant du groupe chez la source : stable d'une actualisation à l'autre.
  final String remoteId;
  final String name;
  final int itemCount;

  /// Clé d'un groupe pour le classement FILTERED.
  String get key => '$sourceId:$remoteId';
}

/// Ligne d'une liste : seulement ce qu'il faut pour l'afficher.
class Item {
  const Item({
    required this.id,
    required this.sourceId,
    required this.type,
    required this.name,
    required this.logo,
    required this.categoryName,
    required this.country,
    required this.rating,
    required this.extension,
    this.nowTitle,
    this.nowProgress = 0,
  });

  final int id;
  final int sourceId;
  final ItemType type;
  final String name;
  final String logo;
  final String categoryName;
  final String country;
  final double? rating;
  final String extension;

  /// Programme en cours et sa progression, de 0 à 1, si le guide les connaît.
  final String? nowTitle;
  final double nowProgress;
}

/// Ordre d'une liste. [source] : l'ordre du fournisseur, ou la pertinence pendant une recherche.
enum ItemSort { source, nameAscending, nameDescending, recent, rating }

/// Ce qu'une liste affiche : un type, puis autant de filtres que voulu.
class BrowseQuery {
  const BrowseQuery({
    required this.type,
    this.sourceId,
    this.categoryId,
    this.categoryIds,
    this.text = '',
    this.country = '',
    this.sort = ItemSort.source,
    this.onlyGuide = false,
    this.favoriteList,
  });

  final ItemType type;
  final int? sourceId;
  final int? categoryId;

  /// Plusieurs groupes à la fois : une catégorie FILTERED.
  final List<int>? categoryIds;
  final String text;
  final String country;
  final ItemSort sort;

  /// Seulement les chaînes associées au guide.
  final bool onlyGuide;

  /// Seulement les chaînes de cette liste de favoris.
  final int? favoriteList;

  BrowseQuery copyWith({String? text, String? country, ItemSort? sort}) => BrowseQuery(
        type: type,
        sourceId: sourceId,
        categoryId: categoryId,
        categoryIds: categoryIds,
        text: text ?? this.text,
        country: country ?? this.country,
        sort: sort ?? this.sort,
        onlyGuide: onlyGuide,
        favoriteList: favoriteList,
      );
}

/// Liste de favoris créée par l'utilisateur.
class FavoriteList {
  const FavoriteList({required this.id, required this.name, required this.icon, required this.itemCount});

  final int id;
  final String name;
  final String icon;
  final int itemCount;
}
