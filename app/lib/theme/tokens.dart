import 'package:flutter/material.dart';

/// Couleurs de sens : elles ne changent pas avec le thème.
abstract final class AppColors {
  /// Or du trophée.
  static const brand = Color(0xFFF9C83A);
  static const live = Color(0xFF12C96A);
  static const warning = Color(0xFFE8960C);
  static const error = Color(0xFFE5484D);
  static const favorite = Color(0xFFFFC53D);
}

/// Couleurs du thème. Sombre : la charte de MatchTV Guide, fond nuit, panneaux biseautés, accent cyan.
/// Clair : beige chaud et or.
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.brightness,
    required this.background,
    required this.backgroundDeep,
    required this.panel,
    required this.panelRaised,
    required this.line,
    required this.lineStrong,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.accent,
    required this.onAccent,
    required this.tabBar,
    required this.brand,
    required this.warning,
    required this.logoTile,
    required this.onLogoTile,
  });

  final Brightness brightness;
  final Color background;
  final Color backgroundDeep;
  final Color panel;
  final Color panelRaised;
  final Color line;
  final Color lineStrong;
  final Color text;
  final Color textMuted;
  final Color textFaint;

  /// Onglet actif, élément sélectionné ou ciblé par la télécommande.
  final Color accent;
  final Color onAccent;
  final Color tabBar;

  /// Violet du logo, assombri sur fond clair pour rester lisible.
  final Color brand;
  final Color warning;

  /// Fond des logos, sombre dans les deux thèmes : la plupart sont dessinés pour un fond sombre.
  final Color logoTile;
  final Color onLogoTile;

  static const night = Palette(
    brightness: Brightness.dark,
    background: Color(0xFF0B0F1A),
    backgroundDeep: Color(0xFF060911),
    panel: Color(0xFF121A2B),
    panelRaised: Color(0xFF1A2440),
    line: Color(0x1FFFFFFF),
    lineStrong: Color(0x33FFFFFF),
    text: Color(0xFFF2F5FA),
    textMuted: Color(0xFF9AA6BF),
    textFaint: Color(0xFF66728C),
    accent: Color(0xFF38D6FF),
    onAccent: Color(0xFF060911),
    tabBar: Color(0xFF060911),
    brand: AppColors.brand,
    warning: AppColors.warning,
    logoTile: Color(0xFF1A2440),
    onLogoTile: Color(0xFF9AA6BF),
  );

  /// Thème clair : sable et crème assombris, or discret. Jamais de blanc franc ni de jaune vif.
  static const day = Palette(
    brightness: Brightness.light,
    background: Color(0xFFD9CBAD),
    backgroundDeep: Color(0xFFCBBA96),
    panel: Color(0xFFE8DCC3),
    panelRaised: Color(0xFFD3C3A2),
    line: Color(0x332B2110),
    lineStrong: Color(0x662B2110),
    text: Color(0xFF2A2013),
    textMuted: Color(0xFF473A28),
    textFaint: Color(0xFF5C4C36),
    accent: Color(0xFF5E3A00),
    onAccent: Color(0xFFFFF6E3),
    tabBar: Color(0xFFCFBE9A),
    // L'or du trophée, assombri pour rester lisible sur le sable.
    brand: Color(0xFF7A5A00),
    warning: Color(0xFF8A4B00),
    logoTile: Color(0xFF3F3425),
    onLogoTile: Color(0xFFD9CBAD),
  );

  static Palette of(BuildContext context) => Theme.of(context).extension<Palette>()!;

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) => t < 0.5 ? this : (other ?? this);
}

abstract final class AppSpace {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const curve = Curves.easeOutCubic;
}

/// Largeur à partir de laquelle on passe à la mise en page PC et TV (catégories à côté de la liste).
const wideLayoutBreakpoint = 840.0;
