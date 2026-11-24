import 'dart:math';

import 'package:chud_iptv/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rapport de contraste WCAG entre deux couleurs opaques.
double contrast(Color a, Color b) {
  double channel(double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) => 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final (x, y) = (luminance(a), luminance(b));
  return (max(x, y) + 0.05) / (min(x, y) + 0.05);
}

void main() {
  for (final (name, p) in [('sombre', Palette.night), ('clair', Palette.day)]) {
    group('thème $name', () {
      final surfaces = {'fond': p.background, 'fond bas': p.backgroundDeep, 'panneau': p.panel, 'relief': p.panelRaised, 'barre': p.tabBar};

      surfaces.forEach((label, surface) {
        test('texte lisible sur $label', () {
          expect(contrast(p.text, surface), greaterThanOrEqualTo(7));
          expect(contrast(p.textMuted, surface), greaterThanOrEqualTo(4.5));
          expect(contrast(p.textFaint, surface), greaterThanOrEqualTo(3));
          expect(contrast(p.accent, surface), greaterThanOrEqualTo(4.5), reason: 'liens et boutons texte');
        });
      });

      test('bouton plein lisible', () => expect(contrast(p.onAccent, p.accent), greaterThanOrEqualTo(4.5)));
      test('logo lisible', () => expect(contrast(p.brand, p.tabBar), greaterThanOrEqualTo(3)));
      test('avertissement lisible', () => expect(contrast(p.warning, p.panel), greaterThanOrEqualTo(4.5)));
    });
  }

  test('le thème clair n\'est ni blanc ni jaune vif', () {
    const p = Palette.day;
    for (final c in [p.background, p.panel, p.panelRaised, p.tabBar]) {
      expect(c.b, lessThan(c.r), reason: 'teinte chaude');
      expect(c.r, lessThan(0.95), reason: 'pas de blanc');
      expect(c.r - c.b, lessThan(0.25), reason: 'pas de jaune vif');
    }
  });
}
