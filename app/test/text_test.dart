import 'package:chud_iptv/import/text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeText', () {
    test('retire accents, majuscules et ponctuation', () {
      expect(normalizeText('Téléfoot  HD+'), 'telefoot hd');
      expect(normalizeText('FR| Canal+ Sport'), 'fr canal sport');
      expect(normalizeText('Œuvre Straße Çà'), 'oeuvre strasse ca');
    });

    test('garde les alphabets non latins', () {
      expect(normalizeText('الجزيرة HD'), 'الجزيرة hd');
      expect(normalizeText('Россия 1'), 'россия 1');
    });

    test('accents combinants', () => expect(normalizeText('Télé'), 'tele'));
    test('vide', () => expect(normalizeText(' -- '), ''));
  });

  group('detectCountry', () {
    test('préfixes courants', () {
      expect(detectCountry('FR| TF1', ''), 'FR');
      expect(detectCountry('FR-REU| Kolotv HD', ''), 'FR');
      expect(detectCountry('[DE] ARD', ''), 'DE');
      expect(detectCountry('UK: BBC One', ''), 'GB');
      expect(detectCountry('EN| Some Movie - 2023', ''), 'EN');
    });

    test('se rabat sur le groupe', () => expect(detectCountry('TF1', 'FR | Généralistes'), 'FR'));

    test('ne confond pas un nom avec un pays', () {
      expect(detectCountry('VIP | FIFA PLUS', ''), '');
      expect(detectCountry('M6 HD', ''), '');
      expect(detectCountry('TF1', 'Sports'), '');
      expect(detectCountry('TV: Something', ''), '');
    });
  });

  group('streamKey', () {
    test('adresses Xtream : indépendantes du domaine et des identifiants', () {
      final a = streamKey('http://a.example:8080/live/user/pass/12345.ts');
      final b = streamKey('http://b.example/live/other/secret/12345.m3u8');
      expect(a, b);
      expect(a, isNot(contains('user')));
      expect(streamKey('http://a.example/user/pass/12345'), 'id:live:12345');
      expect(streamKey('http://a.example/movie/user/pass/99.mkv'), 'id:movie:99');
      expect(streamKey('http://a.example/movie/u/p/99.mkv'), isNot(streamKey('http://a.example/series/u/p/99.mkv')));
    });

    test('ignore les jetons qui tournent', () {
      expect(streamKey('https://cdn.example/ch/tf1/index.m3u8?token=abc'), streamKey('https://cdn.example/ch/tf1/index.m3u8?token=xyz'));
    });

    test('garde les paramètres qui désignent la chaîne', () {
      expect(streamKey('https://cdn.example/play?id=1'), isNot(streamKey('https://cdn.example/play?id=2')));
    });
  });

  test('fingerprint est stable et sensible au contenu', () {
    expect(fingerprint(['a', 1, null]), fingerprint(['a', 1, null]));
    expect(fingerprint(['ab', 'c']), isNot(fingerprint(['a', 'bc'])));
  });
}
