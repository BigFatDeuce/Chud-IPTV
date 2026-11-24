import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:chud_iptv/player/streams.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const xtream = Source(id: 1, name: 'X', kind: SourceKind.xtream, url: 'http://s.example:8080/', username: 'a b', password: 'p/w&1');
  const playlist = Source(id: 2, name: 'P', kind: SourceKind.m3uUrl);

  group('adresses Xtream', () {
    test('direct', () {
      final r = playRequest(xtream, const StreamInfo(type: ItemType.live, stableKey: 'id:12'));
      expect(r.url, 'http://s.example:8080/live/a%20b/p%2Fw%261/12.ts');
      expect(r.live, isTrue);
    });

    test('film, avec son format', () {
      final r = playRequest(xtream, const StreamInfo(type: ItemType.movie, stableKey: 'id:99', extension: 'mkv'));
      expect(r.url, 'http://s.example:8080/movie/a%20b/p%2Fw%261/99.mkv');
      expect(r.live, isFalse);
    });

    test('format absent : mp4', () {
      expect(playRequest(xtream, const StreamInfo(type: ItemType.movie, stableKey: 'id:9')).url, endsWith('/9.mp4'));
    });

    test('doublon : le suffixe de clé ne va pas dans l\'adresse', () {
      expect(xtreamId('id:12#2'), '12');
    });

    test('épisode', () {
      final r = playRequest(xtream, const StreamInfo(type: ItemType.series, stableKey: 'id:7', extension: 'mp4'));
      expect(r.url, contains('/series/'));
      expect(r.live, isFalse);
    });
  });

  group('playlists', () {
    test('adresse d\'origine et en-têtes conservés', () {
      final r = playRequest(
        playlist,
        const StreamInfo(type: ItemType.live, stableKey: 'path:/a', url: 'http://c.example/a.m3u8', httpHeaders: '{"User-Agent":"Lavf/58"}'),
      );
      expect(r.url, 'http://c.example/a.m3u8');
      expect(r.headers, {'User-Agent': 'Lavf/58'});
    });

    test('un film de playlist n\'est pas un direct', () {
      expect(playRequest(playlist, const StreamInfo(type: ItemType.movie, stableKey: 'x', url: 'http://c/a.mkv')).live, isFalse);
    });
  });

  group('saisons', () {
    Map<String, Object?> episode(int id, int number) => {
          'id': '$id',
          'episode_num': number,
          'title': 'S01E0$number',
          'container_extension': 'mkv',
          'info': {'duration_secs': 2768, 'movie_image': 'http://i/x.jpg'},
        };

    test('épisodes rangés par saison', () {
      final seasons = parseSeasons({
        'episodes': {
          '2': [episode(3, 1)],
          '1': [episode(1, 1), episode(2, 2)],
        },
      });
      expect(seasons.map((s) => s.number), [1, 2]);
      expect(seasons.first.episodes.map((e) => e.id), ['1', '2']);
      final e = seasons.first.episodes.first;
      expect(e.extension, 'mkv');
      expect(e.durationSeconds, 2768);
      expect(e.image, 'http://i/x.jpg');
    });

    test('certains fournisseurs renvoient une liste', () {
      final seasons = parseSeasons({
        'episodes': [
          [episode(1, 1)],
          [episode(2, 1)],
        ],
      });
      expect(seasons.map((s) => s.number), [1, 2]);
    });

    test('réponses vides ou inattendues', () {
      expect(parseSeasons({'episodes': []}), isEmpty);
      expect(parseSeasons({'episodes': null}), isEmpty);
      expect(parseSeasons([]), isEmpty);
      expect(parseSeasons({'episodes': {'1': [{'title': 'sans id'}]}}), isEmpty);
    });

    test('la série demandée part dans la requête', () async {
      late Uri asked;
      final client = MockClient((r) async {
        asked = r.url;
        return http.Response('{"episodes":{}}', 200);
      });
      await fetchSeasons(xtream, '44', client: client);
      expect(asked.queryParameters['action'], 'get_series_info');
      expect(asked.queryParameters['series_id'], '44');
      expect(asked.queryParameters['password'], 'p/w&1');
    });

    test('serveur en erreur', () {
      final client = MockClient((_) async => http.Response('', 500));
      expect(fetchSeasons(xtream, '44', client: client), throwsA(isA<http.ClientException>()));
    });
  });

  test('épisodes : adresse et titre', () async {
    const season = Season(1, [Episode(id: '5', number: 1, title: 'Pilote', extension: 'mp4')]);
    final item = await const EpisodeQueue(xtream, 'Ma série', season, 'http://l').at(0);
    expect(item!.title, 'Pilote');
    expect(item.subtitle, 'Ma série');
    expect(item.request.url, endsWith('/series/a%20b/p%2Fw%261/5.mp4'));
  });
}
