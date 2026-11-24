import 'package:flutter/services.dart';

/// Vrai pour un fichier rangé par Android dans un dossier choisi par l'utilisateur.
bool isDocument(String path) => path.startsWith('content://');

/// Nom lisible d'un dossier Android : `content://…/tree/primary%3AMovies%2FFilms` donne `Movies/Films`.
String folderLabel(String uri) {
  final tree = Uri.decodeComponent(uri.split('/').last);
  final colon = tree.indexOf(':');
  final path = colon < 0 ? tree : tree.substring(colon + 1);
  return path.isEmpty ? tree : path;
}

/// Dossiers choisis par l'utilisateur sur Android. Une app ne peut pas y écrire comme dans un
/// dossier ordinaire : tout passe par le système, à qui l'app demande un accès à ce dossier-là.
abstract class DocumentStore {
  /// Copie [path] dans [folder]. Renvoie l'adresse du document, null en cas d'échec.
  Future<String?> save(String folder, String path, String name);
  Future<void> delete(String uri);
  Future<bool> exists(String uri);
}

class AndroidDocuments implements DocumentStore {
  const AndroidDocuments();

  static const _channel = MethodChannel('chud_iptv/device');

  /// Ouvre le sélecteur du système. Null si l'utilisateur annule ou si l'appareil n'en a pas.
  static Future<String?> pick() => _channel.invokeMethod<String>('pickFolder');

  @override
  Future<String?> save(String folder, String path, String name) =>
      _channel.invokeMethod<String>('saveToFolder', {'folder': folder, 'path': path, 'name': name});

  @override
  Future<void> delete(String uri) => _channel.invokeMethod<void>('deleteDocument', {'uri': uri});

  @override
  Future<bool> exists(String uri) async => await _channel.invokeMethod<bool>('documentExists', {'uri': uri}) ?? false;
}
