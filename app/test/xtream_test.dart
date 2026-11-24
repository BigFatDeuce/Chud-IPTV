import 'dart:convert';

import 'package:chud_iptv/import/entry.dart';
import 'package:chud_iptv/import/xtream.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';

Stream<List<int>> chunked(String text, int size) {
  final bytes = utf8.encode(text);
  return Stream.fromIterable([for (var i = 0; i < bytes.length; i += size) bytes.sublist(i, (i + size).clamp(0, bytes.length))]);
}

void main() {
  group('normalizeServer', () {
    test('ajoute le protocole et nettoie', () {
      expect(normalizeServer('example.com'), 'http://example.com');
      expect(normalizeServer(' http://example.com:8080/ '), 'http://example.com:8080');
      expect(normalizeServer('https://example.com/player_api.php?username=a'), 'https://example.com');
      expect(normalizeServer('http://example.com/get.php?username=a&password=b&type=m3u'), 'http://example.com');
      expect(normalizeServer('http://example.com/prefix/'), 'http://example.com/prefix');
    });
  });

  test('l\'adresse encode les caractères spéciaux du mot de passe', () {
    const source = Source(name: 'x', kind: SourceKind.xtream, url: 'http://e.example', username: 'a b', password: 'p&=?');
    final uri = xtreamUri(source, 'get_live_streams');
    expect(uri.queryParameters, {'username': 'a b', 'password': 'p&=?', 'action': 'get_live_streams'});
    expect(uri.path, '/player_api.php');
  });

  group('XtreamAccount', () {
    test('lit l\'expiration et les connexions, en nombres ou en texte', () {
      final a = XtreamAccount.fromJson({
        'user_info': {'auth': 1, 'status': 'Active', 'exp_date': '1818925334', 'max_connections': '1'},
      });
      expect(a.expiresAt!.year, 2027);
      expect(a.maxConnections, 1);
    });

    test('abonnement sans limite', () {
      final a = XtreamAccount.fromJson({
        'user_info': {'auth': 1, 'status': 'Active', 'exp_date': null},
      });
      expect(a.expiresAt, isNull);
    });

    void expectFailure(Object? json, ImportError kind) =>
        expect(() => XtreamAccount.fromJson(json), throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', kind)));

    test('mauvais identifiants', () => expectFailure({'user_info': {'auth': 0}}, ImportError.credentials));
    test('expiré', () => expectFailure({'user_info': {'auth': 1, 'status': 'Expired'}}, ImportError.expired));
    test('banni', () => expectFailure({'user_info': {'auth': 1, 'status': 'Banned'}}, ImportError.credentials));
    test('pas un serveur Xtream', () => expectFailure([], ImportError.invalidData));
  });

  group('splitJsonArray', () {
    const text = ' [{"a":1,"b":"x}y"},{"c":{"d":[1,2]},"e":"é\\"]"}, {"f":null}]\n';

    test('quelle que soit la taille des morceaux', () async {
      for (final size in [1, 2, 3, 7, 1000]) {
        final objects = await splitJsonArray(chunked(text, size)).toList();
        expect(objects, [
          {'a': 1, 'b': 'x}y'},
          {'c': {'d': [1, 2]}, 'e': 'é"]'},
          {'f': null},
        ], reason: 'morceaux de $size');
      }
    });

    test('tableau vide', () async => expect(await splitJsonArray(chunked('[]', 1)).toList(), isEmpty));

    test('refuse autre chose qu\'un tableau', () {
      expect(splitJsonArray(chunked('{"user_info":{}}', 4)).toList(), throwsA(isA<ImportFailure>()));
    });

    test('refuse un document tronqué', () {
      expect(splitJsonArray(chunked('[{"a":1},{"b":', 4)).toList(), throwsA(isA<ImportFailure>()));
      expect(splitJsonArray(chunked('[{"a":1}', 4)).toList(), throwsA(isA<ImportFailure>()));
    });

    test('réponse vide', () => expect(splitJsonArray(chunked('', 4)).toList(), throwsA(isA<ImportFailure>())));
  });

  group('xtreamEntry', () {
    test('chaîne avec champs de types variables', () {
      final e = xtreamEntry(ItemType.live, {
        'name': 'FR| TF1 HD',
        'stream_id': 12,
        'stream_icon': 'http://l.example/a.png',
        'epg_channel_id': null,
        'category_id': 279,
        'tv_archive': '1',
        'tv_archive_duration': '7',
        'added': '1788878020',
      })!;
      expect(e.key, 'id:12');
      expect(e.categoryRemote, '279');
      expect(e.country, 'FR');
      expect(e.catchup, 'xtream');
      expect(e.catchupDays, 7);
      expect(e.addedAt, 1788878020);
      expect(e.tvgId, '');
    });

    test('pas de replay annoncé', () {
      final e = xtreamEntry(ItemType.live, {'name': 'X', 'stream_id': '5', 'tv_archive': 0, 'tv_archive_duration': 0, 'category_id': '1'})!;
      expect(e.catchup, '');
      expect(e.catchupDays, 0);
    });

    test('film et note en texte', () {
      final e = xtreamEntry(ItemType.movie, {'name': 'Film', 'stream_id': 1, 'rating': '4.5', 'container_extension': 'mkv', 'category_id': '2'})!;
      expect(e.rating, 4.5);
      expect(e.extension, 'mkv');
    });

    test('série', () {
      final e = xtreamEntry(ItemType.series, {'name': 'Série', 'series_id': 9, 'cover': 'http://c.example/a.jpg', 'rating': 8, 'category_id': '3', 'last_modified': '100'})!;
      expect(e.key, 'id:9');
      expect(e.logo, 'http://c.example/a.jpg');
      expect(e.addedAt, 100);
    });

    test('ignore un élément inutilisable', () {
      expect(xtreamEntry(ItemType.live, {'name': '', 'stream_id': 1}), isNull);
      expect(xtreamEntry(ItemType.live, {'name': 'X'}), isNull);
    });
  });
}
