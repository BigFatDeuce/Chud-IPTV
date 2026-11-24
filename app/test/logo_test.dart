import 'package:chud_iptv/widgets/logo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les affiches TMDB sont demandées en petit', () {
    expect(
      thumbnailUrl('https://image.tmdb.org/t/p/w600_and_h900_bestv2/qGCDd0.jpg'),
      'https://image.tmdb.org/t/p/w185/qGCDd0.jpg',
    );
  });

  test('les autres adresses ne changent pas', () {
    expect(thumbnailUrl('http://logos.example/t/p/w600/a.png'), 'http://logos.example/t/p/w600/a.png');
  });
}
