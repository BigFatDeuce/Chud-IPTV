import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/updates/release.dart';
import 'package:chud_iptv/updates/updater.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as ed;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late ed.SimpleKeyPair keys;
  late String publicKey;
  final payload = List<int>.generate(4096, (i) => i % 251);

  setUpAll(() async {
    keys = await ed.Ed25519().newKeyPair();
    publicKey = base64.encode((await keys.extractPublicKey()).bytes);
  });

  List<int> manifest({String version = '9.9.9', String platform = 'windows', String? digest}) => utf8.encode(jsonEncode({
        'version': version,
        'notes': {'fr': 'Le guide arrive', 'en': 'The guide is here'},
        'files': {
          platform: {'name': 'Chud IPTV.zip', 'sha256': digest ?? sha256.convert(payload).toString(), 'size': payload.length},
        },
      }));

  Future<String> sign(List<int> data, [ed.SimpleKeyPair? key]) async => base64.encode((await ed.Ed25519().sign(data, keyPair: key ?? keys)).bytes);

  Future<Updater> updater(List<int> json, {String? signature, http.Client? client}) async {
    final sig = signature ?? await sign(json);
    return Updater(
      baseUrl: 'http://u.example',
      publicKey: publicKey,
      platform: 'windows',
      client: client ??
          MockClient((request) async => switch (request.url.pathSegments.last) {
                'latest.json' => http.Response.bytes(json, 200),
                'latest.json.sig' => http.Response(sig, 200),
                _ => http.Response.bytes(payload, 200),
              }),
    );
  }

  group('versions', () {
    test('comparaison numérique', () {
      expect(compareVersions('0.10.0', '0.9.1'), 1);
      expect(compareVersions('1.0.0+4', '1.0.0'), 0);
      expect(compareVersions('0.4.0', '0.4.1'), -1);
    });

    test('notes dans la langue, sinon en anglais', () {
      const r = Release(version: '1', files: {}, notes: {'fr': 'a', 'en': 'b'});
      expect(r.notesFor('fr'), 'a');
      expect(r.notesFor('de'), 'b');
    });
  });

  group('recherche', () {
    test('version plus récente, signée : proposée avec ses notes', () async {
      final u = await updater(manifest());
      await u.check('0.4.0');
      expect(u.stage, UpdateStage.available);
      expect(u.release!.notesFor('fr'), 'Le guide arrive');
    });

    test('déjà à jour', () async {
      final u = await updater(manifest(version: '0.4.0'));
      await u.check('0.4.0');
      expect(u.stage, UpdateStage.upToDate);
      expect(u.release, isNull);
    });

    test('une version plus ancienne n\'est jamais proposée', () async {
      final u = await updater(manifest(version: '0.3.0'));
      await u.check('0.4.0');
      expect(u.release, isNull);
    });

    test('rien pour cette plateforme', () async {
      final u = await updater(manifest(platform: 'linux'));
      await u.check('0.4.0');
      expect(u.stage, UpdateStage.upToDate);
    });

    test('signature d\'une autre clé : refusée', () async {
      final other = await ed.Ed25519().newKeyPair();
      final json = manifest();
      final u = await updater(json, signature: await sign(json, other));
      await u.check('0.4.0');
      expect(u.stage, UpdateStage.failed);
      expect(u.failure, UpdateFailure.signature);
      expect(u.release, isNull);
    });

    test('manifeste modifié après signature : refusé', () async {
      final signature = await sign(manifest());
      final u = await updater(manifest(version: '9.9.8'), signature: signature);
      await u.check('0.4.0');
      expect(u.failure, UpdateFailure.signature);
    });

    test('signature illisible : refusée', () async {
      final u = await updater(manifest(), signature: 'n importe quoi');
      await u.check('0.4.0');
      expect(u.failure, UpdateFailure.signature);
    });

    test('serveur injoignable : erreur à la demande, silence en arrière-plan', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final asked = await updater(manifest(), client: client);
      await asked.check('0.4.0');
      expect(asked.failure, UpdateFailure.network);
      final quiet = await updater(manifest(), client: client);
      await quiet.check('0.4.0', quiet: true);
      expect(quiet.stage, UpdateStage.idle);
      expect(quiet.failure, isNull);
    });

    test('sans adresse ou sans clé : aucune recherche', () async {
      expect(Updater(baseUrl: '', publicKey: publicKey, platform: 'windows').enabled, isFalse);
      expect(Updater(baseUrl: 'http://u', publicKey: '', platform: 'windows').enabled, isFalse);
      expect(Updater(baseUrl: 'http://u', publicKey: publicKey).enabled, isTrue);
    });
  });

  group('téléchargement', () {
    late Directory dir;
    ReleaseFile file({String? digest}) => ReleaseFile(name: 'a.zip', sha256: digest ?? sha256.convert(payload).toString(), size: payload.length);

    setUp(() async => dir = await Directory.systemTemp.createTemp('chud_update'));
    tearDown(() => dir.delete(recursive: true));

    test('progression, puis vérification', () async {
      final u = await updater(manifest());
      final seen = <UpdateStage>{};
      u.addListener(() => seen.add(u.stage));
      final out = File('${dir.path}/a.zip');
      await u.download(Uri.parse('http://u.example/a.zip'), file(), out);
      expect(out.lengthSync(), payload.length);
      expect(u.progress, 1);
      expect(seen, contains(UpdateStage.verifying));
    });

    test('empreinte fausse : fichier supprimé', () async {
      final u = await updater(manifest());
      final out = File('${dir.path}/a.zip');
      await expectLater(u.download(Uri.parse('http://u.example/a.zip'), file(digest: 'faux'), out), throwsFormatException);
      expect(out.existsSync(), isFalse);
    });

    test('annulation : rien ne reste', () async {
      final stream = StreamController<List<int>>();
      final client = MockClient.streaming((request, _) async => http.StreamedResponse(stream.stream, 200, contentLength: payload.length));
      final u = await updater(manifest(), client: client);
      final out = File('${dir.path}/a.zip');
      final download = u.download(Uri.parse('http://u.example/a.zip'), file(), out);
      final failed = expectLater(download, throwsA(anything));
      stream.add(payload.sublist(0, 100));
      await Future<void>.delayed(Duration.zero);
      u.cancel();
      stream.add(payload.sublist(100, 200));
      await failed;
      await stream.close();
      expect(out.existsSync(), isFalse);
    });

    test('une vérification de fond ne recouvre pas une installation en cours', () async {
      final gate = Completer<void>();
      final json = manifest();
      final sig = await sign(json);
      final client = MockClient((request) async {
        switch (request.url.pathSegments.last) {
          case 'latest.json':
            await gate.future;
            return http.Response.bytes(json, 200);
          case 'latest.json.sig':
            return http.Response(sig, 200);
          default:
            return http.Response.bytes(payload, 200);
        }
      });
      final u = await updater(json, client: client);
      final background = u.check('0.4.0', quiet: true);
      await u.download(Uri.parse('http://u.example/a.zip'), file(), File('${dir.path}/a.zip'));
      expect(u.stage, UpdateStage.verifying);
      gate.complete();
      await background;
      expect(u.stage, UpdateStage.verifying, reason: 'sinon « Installer » reparaît et lance un second téléchargement');
      expect(u.release, isNull, reason: 'rien de ce que l\'écran affiche ne change sous l\'installation');
    });

    test('install : un fichier faux n\'est jamais lancé', () async {
      final u = await updater(manifest(digest: 'faux'));
      var restarted = false;
      u.onRestart = (_) async => restarted = true;
      await u.check('0.4.0');
      await u.install();
      expect(u.stage, UpdateStage.failed);
      expect(u.failure, UpdateFailure.integrity);
      expect(restarted, isFalse);
    });
  });

  test('étapes : seuls les passages prévus existent', () {
    const resting = {UpdateStage.checking, UpdateStage.idle, UpdateStage.available};
    const withRelease = {...resting, UpdateStage.downloading};
    const allowed = {
      UpdateStage.idle: resting,
      UpdateStage.upToDate: resting,
      UpdateStage.available: withRelease,
      UpdateStage.handedToSystem: withRelease,
      UpdateStage.cancelled: withRelease,
      UpdateStage.failed: withRelease,
      UpdateStage.checking: {UpdateStage.upToDate, UpdateStage.available, UpdateStage.failed},
      UpdateStage.downloading: {UpdateStage.verifying, UpdateStage.restarting, UpdateStage.handedToSystem, UpdateStage.cancelled, UpdateStage.failed},
      UpdateStage.verifying: {UpdateStage.restarting, UpdateStage.handedToSystem, UpdateStage.failed},
      UpdateStage.restarting: {UpdateStage.failed},
    };
    for (final from in UpdateStage.values) {
      for (final to in UpdateStage.values) {
        expect(from.canBecome(to), allowed[from]!.contains(to), reason: '$from → $to');
      }
    }
    expect(UpdateStage.values.where((s) => s.isWorking), [UpdateStage.checking, UpdateStage.downloading, UpdateStage.verifying, UpdateStage.restarting]);
  });

  test('commande Windows : une console masquée, et un titre entre guillemets', () {
    final command = Updater.windowsScriptCommand(script: 's.ps1', processId: 7, zip: 'u.zip', dir: 'd', exe: 'Chud IPTV.exe');
    expect(command.take(5), ['cmd.exe', '/c', 'start', 'Chud IPTV', '/min']);
    expect(command, containsAllInOrder(['-File', 's.ps1', '-ProcessId', '7', '-Zip', 'u.zip', '-Dir', 'd', '-Exe', 'Chud IPTV.exe']));
  });
}
