import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/tokens.dart';

/// Les affiches de films pèsent lourd : on demande à TMDB une version adaptée à une vignette.
String thumbnailUrl(String url) => url.replaceFirstMapped(RegExp(r'(image\.tmdb\.org/t/p/)[^/]+/'), (m) => '${m[1]}w185/');

/// Cache disque des logos, borné, avec des téléchargements limités en nombre.
///
/// Des milliers de lignes défilent devant l'écran : les demandes les plus récentes passent d'abord
/// (ce sont celles qu'on regarde) et les plus anciennes sont abandonnées si la file déborde.
abstract final class LogoCache {
  static const _maxConcurrent = 6;
  static const _maxQueue = 80;
  static const _maxBytes = 300 * 1024 * 1024;
  static const _timeout = Duration(seconds: 12);

  static String? _dir;
  static final _client = http.Client();
  static final _queue = Queue<Completer<void>>();
  static final _failed = <String>{};
  static var _running = 0;

  /// À appeler au démarrage. Le nettoyage du cache se fait hors de l'interface.
  static void init(String dir) {
    _dir = dir;
    unawaited(compute(_trim, dir));
  }

  static void _trim(String dir) {
    final folder = Directory(dir);
    if (!folder.existsSync()) return;
    final files = folder.listSync().whereType<File>().map((f) => (f, f.statSync())).toList()
      ..sort((a, b) => b.$2.modified.compareTo(a.$2.modified));
    var total = 0;
    for (final (file, stat) in files) {
      total += stat.size;
      if (total > _maxBytes) file.deleteSync();
    }
  }

  static List<File> _files() {
    final dir = _dir;
    if (dir == null || !Directory(dir).existsSync()) return const [];
    return Directory(dir).listSync().whereType<File>().toList();
  }

  /// Place occupée par les logos, en octets.
  static Future<int> size() async => _files().fold<int>(0, (total, f) => total + f.lengthSync());

  static Future<void> clear() async {
    for (final file in _files()) {
      try {
        await file.delete();
      } on FileSystemException {
        // Un logo en cours de lecture partira au prochain nettoyage.
      }
    }
    _failed.clear();
  }

  static Future<Uint8List> load(String url) async {
    if (_failed.contains(url)) throw StateError('logo indisponible');
    final dir = _dir;
    final file = dir == null ? null : File('$dir/${sha1.convert(utf8.encode(url))}');
    if (file != null && file.existsSync()) return file.readAsBytes();

    if (_running >= _maxConcurrent) {
      final turn = Completer<void>();
      _queue.addLast(turn);
      if (_queue.length > _maxQueue) _queue.removeFirst().completeError(StateError('file pleine'));
      await turn.future;
    }
    _running++;
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) throw StateError('HTTP ${response.statusCode}');
      if (file != null) {
        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
      }
      return response.bodyBytes;
    } catch (_) {
      _failed.add(url);
      rethrow;
    } finally {
      _running--;
      if (_queue.isNotEmpty) _queue.removeLast().complete();
    }
  }
}

class _LogoProvider extends ImageProvider<_LogoProvider> {
  const _LogoProvider(this.url);

  final String url;

  @override
  Future<_LogoProvider> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(_LogoProvider key, ImageDecoderCallback decode) => MultiFrameImageStreamCompleter(
        codec: _load(decode),
        scale: 1,
        debugLabel: url,
      );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await LogoCache.load(url);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) => other is _LogoProvider && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

/// Logo de chaîne ou affiche, chargé seulement quand il apparaît. Sans image, l'initiale du nom.
class Logo extends StatelessWidget {
  const Logo({super.key, required this.url, required this.name, required this.width, required this.height, this.fit = BoxFit.contain});

  final String url;
  final String name;
  final double width;
  final double height;
  final BoxFit fit;

  bool get _usable => url.startsWith('http://') || url.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final fallback = _Initial(name: name, width: width, height: height);
    if (!_usable) return fallback;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final image = ResizeImage(
      _LogoProvider(thumbnailUrl(url)),
      width: (width * pixelRatio).round(),
      policy: ResizeImagePolicy.fit,
      allowUpscaling: false,
    );
    return ColoredBox(
      color: palette.logoTile,
      child: SizedBox(
        width: width,
        height: height,
        child: Image(
          image: image,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback,
          frameBuilder: (_, child, frame, sync) => sync || frame != null ? child : fallback,
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.width, required this.height});

  final String name;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final trimmed = name.replaceFirst(RegExp(r'^[^\p{L}\p{N}]*(?:[A-Z]{2}(?:-[A-Z]+)?\s*[|:\]-]\s*)?', unicode: true), '').characters;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: palette.logoTile,
      child: Text(
        trimmed.isEmpty ? '?' : trimmed.first.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Barlow Condensed',
          fontWeight: FontWeight.w700,
          fontSize: (height * 0.42).clamp(12.0, 40.0),
          color: palette.onLogoTile,
        ),
      ),
    );
  }
}
