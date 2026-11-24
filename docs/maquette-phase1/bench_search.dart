// Maquette : coût d'une recherche tolérante aux fautes sur 100 000 chaînes, sans SQLite.
import 'dart:math';
import 'dart:typed_data';

String norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[éèêë]'), 'e')
    .replaceAll(RegExp('[àâä]'), 'a')
    .replaceAll(RegExp('[^a-z0-9]+'), ' ')
    .trim();

/// Distance de Damerau-Levenshtein bornée, sur un seul mot.
int dist(String a, String b, int max) {
  if ((a.length - b.length).abs() > max) return max + 1;
  var p2 = Uint8List(b.length + 1), p1 = Uint8List(b.length + 1), c = Uint8List(b.length + 1);
  for (var j = 0; j <= b.length; j++) {
    p1[j] = j;
  }
  for (var i = 1; i <= a.length; i++) {
    c[0] = i;
    var best = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      var v = min(min(p1[j] + 1, c[j - 1] + 1), p1[j - 1] + cost);
      if (i > 1 && j > 1 && a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) && a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1)) {
        v = min(v, p2[j - 2] + 1);
      }
      c[j] = v;
      best = min(best, v);
    }
    if (best > max) return max + 1;
    final t = p2;
    p2 = p1;
    p1 = c;
    c = t;
  }
  return p1[b.length];
}

void main() {
  final rnd = Random(1);
  const bases = ['TF1', 'France 2', 'Canal+ Sport', 'beIN SPORTS', 'RTL Télévision', 'Eurosport', 'Arte', 'M6', 'Téléfoot', 'Sky Atlantic', 'National Geographic', 'Discovery Channel'];
  const tags = ['HD', 'FHD', 'SD', '4K', 'FR', 'UK', 'DE', 'ES', 'US', 'IT'];
  final sw = Stopwatch()..start();
  final raw = List.generate(100000, (i) => '${tags[rnd.nextInt(tags.length)]}: ${bases[rnd.nextInt(bases.length)]} ${rnd.nextInt(2000)} ${tags[rnd.nextInt(tags.length)]}');
  final names = raw.map(norm).toList();
  final vocab = <String, List<int>>{};
  for (var i = 0; i < names.length; i++) {
    for (final w in names[i].split(' ')) {
      (vocab[w] ??= []).add(i);
    }
  }
  print('index: ${sw.elapsedMilliseconds} ms, vocabulaire ${vocab.length} mots');
  final words = vocab.keys.toList();
  for (final q in ['t', 'te', 'telefot', 'eurosprot', 'canal sport', 'nationl geo', 'discovry']) {
    sw.reset();
    final terms = norm(q).split(' ');
    Set<int>? hits;
    var fuzzyWords = 0;
    for (final t in terms) {
      final s = <int>{};
      final maxD = t.length < 4 ? 0 : (t.length < 8 ? 1 : 2);
      for (final w in words) {
        var ok = w.startsWith(t);
        if (!ok && maxD > 0) {
          final head = w.length > t.length + maxD ? w.substring(0, t.length) : w;
          ok = dist(t, head, maxD) <= maxD;
          if (ok) fuzzyWords++;
        }
        if (ok) s.addAll(vocab[w]!);
      }
      hits = hits == null ? s : hits.intersection(s);
    }
    print('${q.padRight(14)} ${(sw.elapsedMicroseconds / 1000).toStringAsFixed(1).padLeft(7)} ms  ${hits!.length} résultats, $fuzzyWords mots approchés');
  }
}
