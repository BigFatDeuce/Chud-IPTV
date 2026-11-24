import 'package:flutter/material.dart';

import 'tokens.dart';

const _display = 'Barlow Condensed';
const _body = 'Inter';

// Barlow Condensed n'a que l'alphabet latin : Inter prend le relais pour le cyrillique,
// puis les polices du système pour le reste (noms de chaînes en arabe, chinois…).
const _fallback = [_body];

/// Cadre d'un bouton ciblé au clavier ou à la télécommande : il doit se voir à trois mètres.
WidgetStateProperty<BorderSide?> _focusSide(Color color, [BorderSide? rest]) =>
    WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.focused) ? BorderSide(color: color, width: 3) : rest);

ThemeData buildAppTheme(Palette p) {
  final scheme = ColorScheme(
    brightness: p.brightness,
    surface: p.background,
    onSurface: p.text,
    primary: p.accent,
    onPrimary: p.onAccent,
    secondary: p.accent,
    onSecondary: p.onAccent,
    error: AppColors.error,
    onError: Colors.white,
    surfaceContainerHighest: p.panelRaised,
    outline: p.lineStrong,
    outlineVariant: p.line,
    surfaceContainerLowest: p.panel,
    surfaceContainerLow: p.panel,
    surfaceContainer: p.panel,
    surfaceContainerHigh: p.panelRaised,
    secondaryContainer: p.accent.withValues(alpha: 0.22),
    onSecondaryContainer: p.text,
    inverseSurface: p.text,
    onInverseSurface: p.background,
    surfaceTint: Colors.transparent,
  );

  final textTheme = TextTheme(
    displaySmall: const TextStyle(
        fontFamily: _display, fontFamilyFallback: _fallback, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, fontSize: 40, height: 1),
    headlineSmall: const TextStyle(
        fontFamily: _display, fontFamilyFallback: _fallback, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic, fontSize: 26, height: 1.05),
    titleLarge: const TextStyle(fontFamily: _display, fontFamilyFallback: _fallback, fontWeight: FontWeight.w700, fontSize: 22, letterSpacing: 0.3),
    titleMedium: const TextStyle(fontFamily: _display, fontFamilyFallback: _fallback, fontWeight: FontWeight.w600, fontSize: 17, letterSpacing: 0.4),
    titleSmall: const TextStyle(
        fontFamily: _display, fontFamilyFallback: _fallback, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, fontSize: 13, letterSpacing: 1.2),
    bodyLarge: const TextStyle(fontFamily: _body, fontSize: 15, height: 1.4),
    bodyMedium: const TextStyle(fontFamily: _body, fontSize: 13.5, height: 1.4),
    bodySmall: TextStyle(fontFamily: _body, fontSize: 12, height: 1.35, color: p.textMuted),
    labelLarge: const TextStyle(fontFamily: _body, fontSize: 13, fontWeight: FontWeight.w600),
    labelMedium: const TextStyle(fontFamily: _body, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    labelSmall: const TextStyle(fontFamily: _body, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.6),
  ).apply(bodyColor: p.text, displayColor: p.text);

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    extensions: [p],
    scaffoldBackgroundColor: p.background,
    fontFamily: _body,
    textTheme: textTheme,
    splashFactory: NoSplash.splashFactory,
    dividerColor: p.line,
    focusColor: p.accent.withValues(alpha: 0.18),
    hoverColor: p.accent.withValues(alpha: 0.08),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: p.panelRaised, borderRadius: const BorderRadius.all(Radius.circular(4))),
      textStyle: TextStyle(fontFamily: _body, fontSize: 12, color: p.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.tabBar,
      indicatorColor: p.accent.withValues(alpha: 0.2),
      labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: _display, fontFamilyFallback: _fallback, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.6)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(side: _focusSide(p.text))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(side: _focusSide(p.accent, BorderSide(color: p.lineStrong)))),
    textButtonTheme: TextButtonThemeData(style: ButtonStyle(side: _focusSide(p.accent))),
    iconButtonTheme: IconButtonThemeData(style: ButtonStyle(side: _focusSide(p.accent))),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        // Les segments partagent leur bordure : c'est le fond qui distingue celui qui est ciblé.
        side: WidgetStatePropertyAll(BorderSide(color: p.lineStrong)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return p.accent.withValues(alpha: 0.5);
          return states.contains(WidgetState.selected) ? p.accent.withValues(alpha: 0.22) : Colors.transparent;
        }),
        foregroundColor: WidgetStatePropertyAll(p.text),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.panelRaised,
      selectedColor: p.accent.withValues(alpha: 0.3),
      side: BorderSide(color: p.line),
      labelStyle: TextStyle(fontFamily: _body, fontSize: 13, color: p.text),
      checkmarkColor: p.text,
    ),
    listTileTheme: ListTileThemeData(textColor: p.text, iconColor: p.textMuted),
    iconTheme: IconThemeData(color: p.text),
    dialogTheme: DialogThemeData(backgroundColor: p.panel, surfaceTintColor: Colors.transparent),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.panel, surfaceTintColor: Colors.transparent),
    popupMenuTheme: PopupMenuThemeData(color: p.panelRaised, surfaceTintColor: Colors.transparent),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.panelRaised,
      border: OutlineInputBorder(borderSide: BorderSide(color: p.line)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: p.line)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: p.accent, width: 2)),
    ),
  );
}
