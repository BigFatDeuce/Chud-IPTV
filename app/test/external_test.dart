import 'package:chud_iptv/player/external.dart';
import 'package:chud_iptv/player/playback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = PlayItem(
    title: 'TF1 HD',
    request: PlayRequest(url: 'http://x/1.ts', live: true, headers: {'User-Agent': 'Lavf/58', 'Referer': 'http://r/'}),
  );

  test('VLC reçoit le titre et les en-têtes', () {
    expect(externalArguments(r'C:\Program Files\VideoLAN\VLC\vlc.exe', item), [
      '--meta-title=TF1 HD',
      '--http-user-agent=Lavf/58',
      '--http-referrer=http://r/',
      'http://x/1.ts',
    ]);
  });

  test('un autre lecteur reçoit seulement l\'adresse', () {
    expect(externalArguments('/usr/bin/mpv', item), ['http://x/1.ts']);
  });

  test('sans lecteur, on le dit au lieu de planter', () async {
    expect(await openExternally('', item), isFalse);
    expect(await openExternally(r'C:\nexiste\pas.exe', item), isFalse);
  });
}
