import 'dart:convert';

import 'package:chud_iptv/import/entry.dart';
import 'package:chud_iptv/import/m3u_parser.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:flutter_test/flutter_test.dart';

Future<(List<ImportEntry>, M3uParser)> parse(String text, {int chunk = 7}) async {
  final bytes = utf8.encode(text);
  final chunks = [for (var i = 0; i < bytes.length; i += chunk) bytes.sublist(i, (i + chunk).clamp(0, bytes.length))];
  final parser = M3uParser();
  return (await parser.parse(Stream.fromIterable(chunks)).toList(), parser);
}

void main() {
  test('lit les métadonnées courantes', () async {
    final (entries, parser) = await parse('''
#EXTM3U url-tvg="http://epg.example/guide.xml"
#EXTINF:-1 tvg-id="tf1.fr" tvg-name="TF1 HD" tvg-logo="http://l.example/tf1.png" group-title="France, Généralistes" tvg-country="FR",TF1, le direct
http://s.example/live/u/p/1.ts
''');
    expect(parser.epgUrl, 'http://epg.example/guide.xml');
    final e = entries.single;
    expect(e.name, 'TF1, le direct');
    expect(e.tvgId, 'tf1.fr');
    expect(e.tvgName, 'TF1 HD');
    expect(e.logo, 'http://l.example/tf1.png');
    expect(e.categoryName, 'France, Généralistes');
    expect(e.country, 'FR');
    expect(e.type, ItemType.live);
    expect(e.key, 'id:live:1');
  });

  test('accepte BOM, CRLF, lignes vides et attributs sans guillemets', () async {
    final (entries, _) = await parse('﻿#EXTM3U\r\n\r\n#EXTINF:0 tvg-id=abc group-title=News,Info\r\nhttp://s.example/a.m3u8\r\n');
    expect(entries.single.tvgId, 'abc');
    expect(entries.single.categoryName, 'News');
    expect(entries.single.name, 'Info');
  });

  test('reconnaît films et séries', () async {
    final (entries, _) = await parse('''
#EXTM3U
#EXTINF:-1,Film
http://s.example/movie/u/p/10.mkv
#EXTINF:-1,Episode
http://s.example/series/u/p/11.mp4
#EXTINF:-1,Fichier
http://s.example/video/trailer.mp4
#EXTINF:-1,Direct
http://s.example/live/stream.m3u8
''');
    expect(entries.map((e) => e.type), [ItemType.movie, ItemType.series, ItemType.movie, ItemType.live]);
    expect(entries.first.extension, 'mkv');
  });

  test('catch-up, options du lecteur et groupe séparé', () async {
    final (entries, _) = await parse('''
#EXTM3U
#EXTINF:-1 catchup="shift" catchup-days="7" catchup-source="?utc={utc}",Replay
#EXTGRP:Sport
#EXTVLCOPT:http-user-agent=Lavf/58
#EXTVLCOPT:http-referrer=http://r.example/
http://s.example/live.ts
''');
    final e = entries.single;
    expect(e.catchup, 'shift');
    expect(e.catchupDays, 7);
    expect(e.catchupSource, '?utc={utc}');
    expect(e.categoryName, 'Sport');
    expect(jsonDecode(e.httpHeaders), {'User-Agent': 'Lavf/58', 'Referer': 'http://r.example/'});
  });

  test('ligne sans #EXTINF : le nom vient de l\'adresse', () async {
    final (entries, _) = await parse('#EXTM3U\nhttp://s.example/chaines/Ma%20Chaine.m3u8\n');
    expect(entries.single.name, 'Ma Chaine.m3u8');
  });

  test('détecte le pays dans le préfixe du nom', () async {
    final (entries, _) = await parse('#EXTM3U\n#EXTINF:-1,DE: ARD\nhttp://s.example/x.ts\n');
    expect(entries.single.country, 'DE');
  });

  test('refuse une page HTML', () {
    expect(parse('<html><body>Forbidden</body></html>'),
        throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.notPlaylist)));
  });

  test('refuse un contenu sans en-tête ni flux', () {
    expect(parse('bonjour\nle monde\n'), throwsA(isA<ImportFailure>().having((e) => e.kind, 'kind', ImportError.notPlaylist)));
  });

  test('playlist valide mais vide', () async {
    final (entries, _) = await parse('#EXTM3U\n');
    expect(entries, isEmpty);
  });
}
