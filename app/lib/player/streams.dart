import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/repository.dart';
import '../import/xtream.dart';
import '../models/catalog.dart';
import '../models/source.dart';
import 'playback.dart';

/// Identifiant Xtream d'un élément, tiré de sa clé (`id:123`, ou `id:123#2` pour un doublon).
String xtreamId(String stableKey) => stableKey.replaceFirst('id:', '').split('#').first;

String _xtreamUrl(Source s, String kind, String file) {
  final user = Uri.encodeComponent(s.username);
  final password = Uri.encodeComponent(s.password);
  return '${normalizeServer(s.url)}/$kind/$user/$password/$file';
}

Map<String, String> _headers(String json) {
  if (json.isEmpty) return const {};
  try {
    return (jsonDecode(json) as Map<String, dynamic>).map((k, v) => MapEntry(k, '$v'));
  } on FormatException {
    return const {};
  }
}

/// Adresse de lecture d'un élément du catalogue.
PlayRequest playRequest(Source source, StreamInfo info) {
  if (source.kind != SourceKind.xtream) {
    return PlayRequest(url: info.url, live: info.type == ItemType.live, headers: _headers(info.httpHeaders));
  }
  final id = xtreamId(info.stableKey);
  final extension = info.extension.isEmpty ? 'mp4' : info.extension;
  return switch (info.type) {
    ItemType.live => PlayRequest(url: _xtreamUrl(source, 'live', '$id.ts'), live: true),
    ItemType.movie => PlayRequest(url: _xtreamUrl(source, 'movie', '$id.$extension'), live: false),
    ItemType.series => PlayRequest(url: _xtreamUrl(source, 'series', '$id.$extension'), live: false),
  };
}

/// Les chaînes ou films d'une liste, parcourus avec précédent et suivant.
class CatalogQueue implements PlayQueue {
  CatalogQueue(this._repository, this._sources, this._query, this.length);

  final Repository _repository;
  final List<Source> _sources;
  final BrowseQuery _query;

  @override
  final int length;

  @override
  Future<PlayItem?> at(int index) async {
    final items = await _repository.page(_query, index, 1);
    if (items.isEmpty) return null;
    return itemToPlay(items.first, _repository, _sources);
  }
}

Future<PlayItem?> itemToPlay(Item item, Repository repository, List<Source> sources) async {
  final source = sources.where((s) => s.id == item.sourceId).firstOrNull;
  if (source == null) return null;
  final info = await repository.streamInfo(item.id);
  if (info == null) return null;
  return PlayItem(itemId: item.id, title: item.name, subtitle: item.nowTitle ?? item.categoryName, logo: item.logo, request: playRequest(source, info));
}

/// Un seul élément.
class SingleQueue implements PlayQueue {
  const SingleQueue(this.item);

  final PlayItem item;

  @override
  int get length => 1;

  @override
  Future<PlayItem?> at(int index) async => item;
}

class Episode {
  const Episode({required this.id, required this.number, required this.title, required this.extension, this.durationSeconds, this.image = ''});

  final String id;
  final int number;
  final String title;
  final String extension;
  final int? durationSeconds;
  final String image;
}

class Season {
  const Season(this.number, this.episodes);

  final int number;
  final List<Episode> episodes;
}

/// Lit `get_series_info`, dont `episodes` est selon les fournisseurs un objet par saison ou une liste.
List<Season> parseSeasons(Object? json) {
  final episodes = json is Map ? json['episodes'] : null;
  final groups = <int, List<Object?>>{};
  if (episodes is Map) {
    episodes.forEach((key, value) {
      if (value is List) groups[int.tryParse('$key') ?? 0] = value;
    });
  } else if (episodes is List) {
    for (final (i, value) in episodes.indexed) {
      if (value is List) groups[i + 1] = value;
    }
  }
  final seasons = <Season>[];
  for (final number in groups.keys.toList()..sort()) {
    final list = <Episode>[];
    for (final e in groups[number]!) {
      if (e is! Map || e['id'] == null) continue;
      final info = e['info'] is Map ? e['info'] as Map : const {};
      list.add(Episode(
        id: '${e['id']}',
        number: int.tryParse('${e['episode_num']}') ?? list.length + 1,
        title: '${e['title'] ?? ''}',
        extension: '${e['container_extension'] ?? 'mp4'}',
        durationSeconds: int.tryParse('${info['duration_secs']}'),
        image: '${info['movie_image'] ?? ''}',
      ));
    }
    if (list.isNotEmpty) seasons.add(Season(number, list));
  }
  return seasons;
}

/// Les saisons d'une série, demandées seulement à l'ouverture : les 64 000 séries d'un abonnement
/// ne se téléchargent pas avec leurs épisodes.
Future<List<Season>> fetchSeasons(Source source, String seriesId, {http.Client? client}) async {
  final uri = xtreamUri(source, 'get_series_info').replace(
    queryParameters: {...xtreamUri(source, 'get_series_info').queryParameters, 'series_id': seriesId},
  );
  final http.Response response;
  final own = client ?? http.Client();
  try {
    response = await own.get(uri, headers: {'User-Agent': 'ChudIPTV/1'}).timeout(const Duration(seconds: 20));
  } finally {
    if (client == null) own.close();
  }
  if (response.statusCode != 200) throw http.ClientException('HTTP ${response.statusCode}');
  return parseSeasons(jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true)));
}

/// Les épisodes d'une saison.
class EpisodeQueue implements PlayQueue {
  const EpisodeQueue(this._source, this._seriesName, this._season, this._logo);

  final Source _source;
  final String _seriesName;
  final Season _season;
  final String _logo;

  @override
  int get length => _season.episodes.length;

  @override
  Future<PlayItem?> at(int index) async {
    final e = _season.episodes[index];
    final info = StreamInfo(type: ItemType.series, stableKey: 'id:${e.id}', extension: e.extension);
    return PlayItem(title: e.title, subtitle: _seriesName, logo: _logo, request: playRequest(_source, info));
  }
}
