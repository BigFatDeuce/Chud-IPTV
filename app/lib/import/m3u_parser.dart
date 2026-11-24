import 'dart:convert';

import '../models/catalog.dart';
import '../models/source.dart';
import 'entry.dart';
import 'text.dart';

final _attribute = RegExp(r'''([A-Za-z0-9_-]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s,"']+))''');

const _videoExtensions = {'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', 'mpg', 'mpeg'};
const _streamSchemes = ['http://', 'https://', 'rtmp://', 'rtmps://', 'rtsp://', 'udp://', 'rtp://', 'mms://'];

/// Attributs de `#EXTINF` / `#EXTM3U`.
Map<String, String> parseAttributes(String text) => {
      for (final m in _attribute.allMatches(text)) m.group(1)!.toLowerCase(): m.group(2) ?? m.group(3) ?? m.group(4) ?? '',
    };

/// Position de la virgule qui sépare les attributs du titre : la première hors guillemets.
int _titleComma(String line) {
  String? quote;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (quote != null) {
      if (c == quote) quote = null;
    } else if (c == '"') {
      quote = c;
    } else if (c == ',') {
      return i;
    }
  }
  return -1;
}

ItemType _typeOf(String url) {
  final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
  if (path.contains('/movie/')) return ItemType.movie;
  if (path.contains('/series/')) return ItemType.series;
  final ext = path.contains('.') ? path.substring(path.lastIndexOf('.') + 1) : '';
  return _videoExtensions.contains(ext) ? ItemType.movie : ItemType.live;
}

String _extensionOf(String url) {
  final path = Uri.tryParse(url)?.path ?? url;
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot < path.lastIndexOf('/')) return '';
  return path.substring(dot + 1).toLowerCase();
}

String _nameFromUrl(String url) {
  final segments = Uri.tryParse(url)?.pathSegments.where((s) => s.isNotEmpty) ?? const <String>[];
  return segments.isEmpty ? url : Uri.decodeComponent(segments.last);
}

/// Lit une playlist ligne à ligne, sans la charger en mémoire. Refuse ce qui n'en est pas une,
/// typiquement la page HTML d'erreur d'un fournisseur.
class M3uParser {
  /// Guide des programmes annoncé par l'en-tête de la playlist.
  String epgUrl = '';

  Stream<ImportEntry> parse(Stream<List<int>> bytes) async* {
    Map<String, String>? attributes;
    var title = '';
    var group = '';
    final options = <String, String>{};
    var sawHeader = false;
    var count = 0;
    var firstLine = true;

    final lines = bytes.transform(const Utf8Decoder(allowMalformed: true)).transform(const LineSplitter());
    await for (var line in lines) {
      if (firstLine && line.startsWith('﻿')) line = line.substring(1);
      line = line.trim();
      if (line.isEmpty) continue;
      if (firstLine) {
        firstLine = false;
        if (line.startsWith('<') || line.startsWith('{')) throw const ImportFailure(ImportError.notPlaylist);
      }
      if (line.startsWith('#EXTM3U')) {
        sawHeader = true;
        final header = parseAttributes(line);
        epgUrl = header['url-tvg'] ?? header['x-tvg-url'] ?? header['tvg-url'] ?? epgUrl;
      } else if (line.startsWith('#EXTINF:')) {
        final comma = _titleComma(line);
        attributes = parseAttributes(comma < 0 ? line : line.substring(0, comma));
        title = comma < 0 ? '' : line.substring(comma + 1).trim();
      } else if (line.startsWith('#EXTGRP:')) {
        group = line.substring(8).trim();
      } else if (line.startsWith('#EXTVLCOPT:')) {
        final option = line.substring(11);
        final eq = option.indexOf('=');
        if (eq > 0) options[option.substring(0, eq).trim().toLowerCase()] = option.substring(eq + 1).trim();
      } else if (line.startsWith('#')) {
        continue;
      } else if (_streamSchemes.any((s) => line.toLowerCase().startsWith(s))) {
        count++;
        yield _entry(line, attributes ?? const {}, title, group, options);
        attributes = null;
        title = '';
        group = '';
        options.clear();
      }
    }
    if (count == 0 && !sawHeader) throw const ImportFailure(ImportError.notPlaylist);
  }

  ImportEntry _entry(String url, Map<String, String> a, String title, String group, Map<String, String> options) {
    final name = title.isNotEmpty ? title : (a['tvg-name'] ?? _nameFromUrl(url));
    final groupName = a['group-title']?.trim().isNotEmpty == true ? a['group-title']!.trim() : group;
    final declared = (a['tvg-country'] ?? '').split(RegExp('[;,]')).first.trim().toUpperCase();
    final country = declared.length == 2 ? declared : detectCountry(name, groupName);
    final catchup = a['catchup'] ?? a['catchup-type'] ?? '';
    final userAgent = options['http-user-agent'] ?? a['http-user-agent'] ?? '';
    final referrer = options['http-referrer'] ?? a['http-referrer'] ?? '';
    return ImportEntry(
      type: _typeOf(url),
      key: streamKey(url),
      name: name,
      categoryRemote: normalizeText(groupName),
      categoryName: groupName,
      logo: a['tvg-logo'] ?? a['logo'] ?? '',
      country: country,
      tvgId: a['tvg-id'] ?? '',
      tvgName: a['tvg-name'] ?? '',
      url: url,
      extension: _extensionOf(url),
      catchup: catchup,
      catchupDays: int.tryParse(a['catchup-days'] ?? a['timeshift'] ?? a['tvg-rec'] ?? '') ?? 0,
      catchupSource: a['catchup-source'] ?? '',
      httpHeaders: userAgent.isEmpty && referrer.isEmpty
          ? ''
          : jsonEncode({if (userAgent.isNotEmpty) 'User-Agent': userAgent, if (referrer.isNotEmpty) 'Referer': referrer}),
    );
  }
}
