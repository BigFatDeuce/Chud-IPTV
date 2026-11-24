// Publication d'une version : clé de signature, `latest.json` et sa signature.
//
//   dart run tool/make_release.dart keygen <fichier-clé>
//   dart run tool/make_release.dart sign <fichier-clé> <version> <notes.json> <dossier> <installeurs...>
//
// `keygen` écrit la clé privée et affiche la clé publique, à mettre dans lib/updates/release.dart.
// `sign` écrit `latest.json` et `latest.json.sig` dans <dossier>. La clé privée ne va jamais dans
// le dépôt : perdue, plus aucune app installée n'acceptera de mise à jour.
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as ed;

const _platforms = {
  'windows-x64.zip': 'windows',
  'x86_64.AppImage': 'linux',
  'arm64.apk': 'android-arm64',
  'armv7.apk': 'android-arm',
};

Future<void> _keygen(String path) async {
  final file = File(path);
  if (file.existsSync()) {
    print('Refusé : $path existe déjà. Remplacer cette clé couperait les mises à jour des apps installées.');
    exit(1);
  }
  final pair = await ed.Ed25519().newKeyPair();
  await file.writeAsString(base64.encode(await pair.extractPrivateKeyBytes()));
  print(base64.encode((await pair.extractPublicKey()).bytes));
}

Future<void> _sign(List<String> args) async {
  final [keyPath, version, notesPath, folder, ...installers] = args;
  final files = <String, Object>{};
  for (final path in installers) {
    final file = File(path);
    final name = file.uri.pathSegments.last;
    final platform = _platforms.entries.where((e) => name.endsWith(e.key)).firstOrNull?.value;
    if (platform == null) {
      print('Plateforme inconnue : $name');
      exit(1);
    }
    files[platform] = {'name': name, 'sha256': '${await sha256.bind(file.openRead()).first}', 'size': file.lengthSync()};
  }
  final manifest = utf8.encode(const JsonEncoder.withIndent('  ').convert({
    'version': version,
    'notes': jsonDecode(File(notesPath).readAsStringSync()),
    'files': files,
  }));
  final seed = base64.decode(File(keyPath).readAsStringSync().trim());
  final pair = await ed.Ed25519().newKeyPairFromSeed(seed);
  final signature = await ed.Ed25519().sign(manifest, keyPair: pair);
  File('$folder/latest.json').writeAsBytesSync(manifest);
  File('$folder/latest.json.sig').writeAsStringSync(base64.encode(signature.bytes));
  print('latest.json signé : version $version, ${files.length} plateforme(s).');
}

Future<void> main(List<String> args) async {
  if (args.length == 2 && args.first == 'keygen') return _keygen(args[1]);
  if (args.length >= 6 && args.first == 'sign') return _sign(args.sublist(1));
  print('Usage : voir l\'en-tête de tool/make_release.dart');
  exit(2);
}
