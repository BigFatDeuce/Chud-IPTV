import 'dart:convert';

import '../import/text.dart';
import 'places.dart';

final _placeByCode = {for (final p in places) p.code: p};
final _placeByTag = {for (final p in places) for (final t in p.tags) t: p};
final _aliasPlaces = {for (final p in places) for (final a in p.aliases) a: p};
final _themeWords = {for (final e in themes.entries) for (final w in e.value) normalizeText(w): e.key};

/// Préfixe délimité d'un nom de groupe : `EU |`, `[FR]`, `DE:`, `24/7 |`.
final _prefix = RegExp(r'^\s*[\[(]?\s*([A-Za-z0-9/+-]{2,6})\s*[\])|:]');

/// Libellé d'un code pays ou langue, tel qu'on le voit dans les filtres.
String placeLabel(String code) => switch (code) {
      'EN' => 'ENGLISH',
      'EU' => 'EUROPE',
      'AR' => 'ARABIC',
      _ => _placeByCode[code]?.label ?? code,
    };

/// Ce qu'on a compris d'un nom de groupe.
class GroupAnalysis {
  const GroupAnalysis({this.place, this.region, this.themes = const {}, this.uncertain = false});

  final Place? place;
  final String? region;
  final Set<String> themes;

  /// Vrai si l'utilisateur devrait y jeter un œil.
  final bool uncertain;

  bool get understood => place != null || region != null || themes.isNotEmpty;
}

/// Analyse un nom de groupe. On ne regarde que les mots entiers et les préfixes délimités :
/// « EU » dans le nom d'une chaîne, ou « IT » au milieu d'un titre, ne désignent aucun pays.
///
/// [dominant] : code pays porté par la majorité des chaînes du groupe, utilisé en dernier recours.
GroupAnalysis analyzeGroup(String name, {String? dominant}) {
  final prefix = _prefix.firstMatch(name)?.group(1);
  final padded = ' ${normalizeText(name)} ';
  final words = padded.trim().split(' ').toSet();

  // Pays nommés, du plus long alias au plus court pour que « south africa » passe avant « africa ».
  final found = <Place>{};
  final named = <Place>{};
  for (final MapEntry(key: alias, value: place) in _aliasPlaces.entries) {
    if (!padded.contains(' $alias ')) continue;
    found.add(place);
    if (!languageAliases.contains(alias)) named.add(place);
  }
  // « CANADA FRANÇAIS » : une langue citée à côté d'un pays n'est pas un second pays.
  if (named.isNotEmpty) found.retainAll(named);
  // « EXYU CROATIA » : le pays précis l'emporte sur la zone.
  if (found.length > 1) found.removeWhere((p) => p.code == 'XY');
  Place? place;
  if (found.isNotEmpty) {
    // Plusieurs pays cités : on garde le premier nommé, et on le signale.
    place = found.reduce((a, b) => _firstIndex(a, padded) <= _firstIndex(b, padded) ? a : b);
  } else if (prefix != null) {
    place = _placeByTag[prefix];
  }

  var region = place?.region;
  if (region == null && prefix != null) region = regionTags[prefix.toUpperCase()];
  if (region == null) {
    for (final MapEntry(key: word, value: code) in regionWords.entries) {
      if (words.contains(word)) region = code;
    }
  }

  final detected = <String>{};
  for (final word in words) {
    final theme = _themeWords[word];
    if (theme != null) detected.add(theme);
  }
  if (padded.contains(' 24 7 ') || prefix == '24/7') detected.add('24/7');

  var uncertain = found.length > 1;
  // Dernier recours : les chaînes du groupe. Jamais contre la région annoncée par son nom.
  final hint = dominant == null ? null : _placeByCode[dominant];
  if (place == null && hint != null && (region == null || region == hint.region)) {
    place = hint;
    region = hint.region;
    uncertain = true;
  }
  if (place == null && region == null && detected.isEmpty) uncertain = true;
  return GroupAnalysis(place: place, region: region, themes: detected, uncertain: uncertain);
}

int _firstIndex(Place place, String padded) {
  var best = padded.length;
  for (final alias in place.aliases) {
    final i = padded.indexOf(' $alias ');
    if (i >= 0 && i < best) best = i;
  }
  return best;
}

/// Code pays d'un groupe, pour le filtre par pays. Vide si le groupe n'en désigne pas.
String groupCountry(String name) => analyzeGroup(name).place?.code ?? '';

/// Un groupe IPTV, tel que le classement le voit.
class GroupRef {
  const GroupRef({required this.key, required this.name, required this.itemCount, this.dominant});

  /// `<source>:<identifiant du groupe>` : stable d'une actualisation à l'autre.
  final String key;
  final String name;
  final int itemCount;
  final String? dominant;
}

/// Catégorie créée par l'utilisateur.
class CustomNode {
  const CustomNode(this.label, this.parent);

  final String label;
  final String? parent;
}

/// Corrections de l'utilisateur : elles survivent aux nouvelles analyses et aux actualisations.
class FilteredEdits {
  FilteredEdits({Set<String>? excluded, Map<String, List<String>>? assigned, Map<String, String>? renamed, Map<String, String>? merged, Map<String, CustomNode>? custom})
      : excluded = excluded ?? {},
        assigned = assigned ?? {},
        renamed = renamed ?? {},
        merged = merged ?? {},
        custom = custom ?? {};

  factory FilteredEdits.fromJson(String? text) {
    if (text == null || text.isEmpty) return FilteredEdits();
    final j = jsonDecode(text) as Map<String, dynamic>;
    return FilteredEdits(
      excluded: (j['excluded'] as List).cast<String>().toSet(),
      assigned: (j['assigned'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as List).cast<String>())),
      renamed: (j['renamed'] as Map<String, dynamic>).cast<String, String>(),
      merged: (j['merged'] as Map<String, dynamic>).cast<String, String>(),
      custom: (j['custom'] as Map<String, dynamic>).map((k, v) => MapEntry(k, CustomNode(v['label'] as String, v['parent'] as String?))),
    );
  }

  /// Groupes retirés du classement.
  final Set<String> excluded;

  /// Groupe → catégories choisies à la main, à la place du classement automatique.
  final Map<String, List<String>> assigned;

  /// Catégorie → nouveau nom.
  final Map<String, String> renamed;

  /// Catégorie → catégorie dans laquelle elle a été fusionnée.
  final Map<String, String> merged;
  final Map<String, CustomNode> custom;

  bool get isEmpty => excluded.isEmpty && assigned.isEmpty && renamed.isEmpty && merged.isEmpty && custom.isEmpty;

  String toJson() => jsonEncode({
        'excluded': excluded.toList(),
        'assigned': assigned,
        'renamed': renamed,
        'merged': merged,
        'custom': custom.map((k, v) => MapEntry(k, {'label': v.label, 'parent': v.parent})),
      });
}

/// Une catégorie du classement.
class FilteredNode {
  FilteredNode({required this.key, required this.label, this.parent, List<String>? groups}) : groups = groups ?? [];

  final String key;
  final String label;
  final String? parent;
  final List<String> groups;

  Map<String, Object?> toMap() => {'k': key, 'l': label, 'p': parent, 'g': groups};

  static FilteredNode fromMap(Map<String, dynamic> m) =>
      FilteredNode(key: m['k'] as String, label: m['l'] as String, parent: m['p'] as String?, groups: (m['g'] as List).cast<String>());
}

/// Résultat du classement. Il ne fait que pointer vers les groupes : la playlist n'est jamais modifiée.
class FilteredTree {
  FilteredTree({required this.nodes, this.uncertain = const {}, this.unclassified = const [], this.analyzed = const {}});

  factory FilteredTree.fromJson(String text) {
    final j = jsonDecode(text) as Map<String, dynamic>;
    return FilteredTree(
      nodes: [for (final n in j['nodes'] as List) FilteredNode.fromMap(n as Map<String, dynamic>)],
      analyzed: (j['analyzed'] as List).cast<String>().toSet(),
    );
  }

  final List<FilteredNode> nodes;

  /// Groupes classés sur un indice faible : à vérifier.
  final Set<String> uncertain;

  /// Groupes auxquels on n'a rien compris.
  final List<String> unclassified;

  /// Tous les groupes vus par l'analyse, pour repérer les nouveaux après une actualisation.
  final Set<String> analyzed;

  List<FilteredNode> childrenOf(String? parent) => nodes.where((n) => n.parent == parent).toList();

  /// Groupes d'une catégorie et de ses sous-catégories, sans doublon.
  Set<String> groupsUnder(String key) {
    final result = <String>{};
    void visit(String k) {
      for (final n in nodes) {
        if (n.key == k) result.addAll(n.groups);
        if (n.parent == k) visit(n.key);
      }
    }

    visit(key);
    return result;
  }

  String toJson() => jsonEncode({'nodes': nodes.map((n) => n.toMap()).toList(), 'analyzed': analyzed.toList()});
}

String _resolve(String key, Map<String, String> merged) {
  var current = key;
  final seen = <String>{};
  while (merged.containsKey(current) && seen.add(current)) {
    current = merged[current]!;
  }
  return current;
}

/// Construit le classement : analyse automatique, puis corrections de l'utilisateur.
FilteredTree buildTree(List<GroupRef> groups, FilteredEdits edits) {
  final labels = <String, String>{};
  final parents = <String, String?>{};
  final members = <String, List<String>>{};
  final uncertain = <String>{};
  final unclassified = <String>[];

  void place(String key, String group) => (members[key] ??= []).add(group);

  for (final e in edits.custom.entries) {
    labels[e.key] = e.value.label;
    parents[e.key] = e.value.parent;
  }
  void declareRegion(String code) {
    labels['region:$code'] = regionLabels[code]!;
    parents['region:$code'] = null;
  }

  void declareTheme(String theme) {
    labels['theme:$theme'] = theme;
    parents['theme:$theme'] = null;
  }

  for (final group in groups) {
    if (edits.excluded.contains(group.key)) continue;
    final analysis = analyzeGroup(group.name, dominant: group.dominant);
    final auto = <String>[];
    final p = analysis.place;
    if (p != null) {
      declareRegion(p.region);
      labels['place:${p.code}'] = p.label;
      parents['place:${p.code}'] = 'region:${p.region}';
      auto.add('place:${p.code}');
    } else if (analysis.region != null) {
      declareRegion(analysis.region!);
      auto.add('region:${analysis.region}');
    }
    for (final theme in analysis.themes) {
      declareTheme(theme);
      auto.add('theme:$theme');
    }
    final manual = edits.assigned[group.key];
    if (manual != null) {
      for (final key in manual) {
        if (key.startsWith('region:')) declareRegion(key.substring(7));
        if (key.startsWith('theme:')) declareTheme(key.substring(6));
        if (key.startsWith('place:')) {
          final known = _placeByCode[key.substring(6)];
          if (known != null) {
            declareRegion(known.region);
            labels[key] = known.label;
            parents[key] = 'region:${known.region}';
          }
        }
        place(key, group.key);
      }
      continue;
    }
    if (auto.isEmpty) {
      unclassified.add(group.key);
      continue;
    }
    if (analysis.uncertain) uncertain.add(group.key);
    for (final key in auto) {
      place(key, group.key);
    }
  }

  // Fusions : les groupes passent dans la catégorie cible.
  for (final from in edits.merged.keys) {
    final target = _resolve(from, edits.merged);
    final moved = members.remove(from);
    if (moved != null) {
      final into = members[target] ??= [];
      into.addAll(moved.where((g) => !into.contains(g)));
    }
    labels.putIfAbsent(target, () => target.split(':').last);
    parents.putIfAbsent(target, () => null);
  }

  // Une catégorie n'existe que si elle contient quelque chose, ou si l'utilisateur l'a créée.
  final keep = <String>{...members.keys, ...edits.custom.keys};
  for (final key in members.keys) {
    var parent = parents[key];
    while (parent != null) {
      keep.add(parent);
      parent = parents[parent];
    }
  }
  keep.removeAll(edits.merged.keys);

  int rank(String key) {
    if (key.startsWith('region:')) return regionLabels.keys.toList().indexOf(key.substring(7));
    if (key.startsWith('theme:')) return 100 + themes.keys.toList().indexOf(key.substring(6));
    return 200;
  }

  String labelOf(String key) => edits.renamed[key] ?? labels[key] ?? key;

  final keys = keep.toList()
    ..sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : labelOf(a).compareTo(labelOf(b));
    });
  return FilteredTree(
    nodes: [
      for (final key in keys)
        FilteredNode(key: key, label: labelOf(key), parent: keep.contains(parents[key]) ? parents[key] : null, groups: members[key] ?? []),
    ],
    uncertain: uncertain,
    unclassified: unclassified,
    analyzed: {for (final g in groups) g.key},
  );
}
