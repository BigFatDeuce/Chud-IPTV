import 'package:flutter/material.dart';

import '../models/catalog.dart';

/// Présentation d'une liste.
enum ViewMode { compact, detailed, grid }

/// Préférences de l'utilisateur, gardées en base sous forme clé / valeur.
class Settings {
  const Settings({
    this.themeMode = ThemeMode.dark,
    this.language,
    this.fullscreen = false,
    this.externalPlayer = '',
    this.sourceHours = 24,
    this.guideHours = 24,
    this.autoUpdates = true,
    this.downloadDir = '',
    this.pipOption = false,
    this.radioOption = false,
    this.pipActive = true,
    this.radioActive = true,
    this.views = const {ItemType.live: ViewMode.detailed, ItemType.movie: ViewMode.grid, ItemType.series: ViewMode.grid},
  });

  factory Settings.fromMap(Map<String, String> m) {
    const defaults = Settings();
    return Settings(
      themeMode: ThemeMode.values.asNameMap()[m['theme']] ?? defaults.themeMode,
      language: m['language'],
      fullscreen: m['player.fullscreen'] == 'true',
      externalPlayer: m['player.external'] ?? '',
      sourceHours: int.tryParse(m['refresh.sources'] ?? '') ?? defaults.sourceHours,
      guideHours: int.tryParse(m['refresh.guide'] ?? '') ?? defaults.guideHours,
      autoUpdates: m['update.auto'] != 'false',
      downloadDir: m['download.dir'] ?? '',
      pipOption: m['player.pip'] == 'true',
      radioOption: m['player.radio'] == 'true',
      pipActive: m['player.pipActive'] != 'false',
      radioActive: m['player.radioActive'] != 'false',
      views: {
        for (final type in ItemType.values)
          type: ViewMode.values.asNameMap()[m['view.${type.name}']] ?? defaults.views[type]!,
      },
    );
  }

  final ThemeMode themeMode;

  /// Null : la langue du système.
  final String? language;

  /// Le lecteur était en plein écran : il y revient à la prochaine lecture.
  final bool fullscreen;

  /// Chemin du lecteur externe. Vide : VLC s'il est installé.
  final String externalPlayer;

  /// Intervalle d'actualisation automatique, en heures. 0 : jamais.
  final int sourceHours;
  final int guideHours;

  /// Regarder de temps en temps si une nouvelle version existe.
  final bool autoUpdates;

  /// Dossier des téléchargements. Vide : celui de l'appareil.
  final String downloadDir;

  /// Téléphone : la fonction est proposée, et son bouton apparaît dans le lecteur.
  final bool pipOption;
  final bool radioOption;

  /// État du bouton dans le lecteur.
  final bool pipActive;
  final bool radioActive;
  final Map<ItemType, ViewMode> views;

  Map<String, String> toMap() => {
        'theme': themeMode.name,
        'language': language ?? '',
        'player.fullscreen': '$fullscreen',
        'player.external': externalPlayer,
        'refresh.sources': '$sourceHours',
        'refresh.guide': '$guideHours',
        'update.auto': '$autoUpdates',
        'download.dir': downloadDir,
        'player.pip': '$pipOption',
        'player.radio': '$radioOption',
        'player.pipActive': '$pipActive',
        'player.radioActive': '$radioActive',
        for (final e in views.entries) 'view.${e.key.name}': e.value.name,
      };

  Settings copyWith({
    ThemeMode? themeMode,
    String? Function()? language,
    bool? fullscreen,
    String? externalPlayer,
    int? sourceHours,
    int? guideHours,
    bool? autoUpdates,
    String? downloadDir,
    bool? pipOption,
    bool? radioOption,
    bool? pipActive,
    bool? radioActive,
    Map<ItemType, ViewMode>? views,
  }) =>
      Settings(
        themeMode: themeMode ?? this.themeMode,
        language: language == null ? this.language : language(),
        fullscreen: fullscreen ?? this.fullscreen,
        externalPlayer: externalPlayer ?? this.externalPlayer,
        sourceHours: sourceHours ?? this.sourceHours,
        guideHours: guideHours ?? this.guideHours,
        autoUpdates: autoUpdates ?? this.autoUpdates,
        downloadDir: downloadDir ?? this.downloadDir,
        pipOption: pipOption ?? this.pipOption,
        radioOption: radioOption ?? this.radioOption,
        pipActive: pipActive ?? this.pipActive,
        radioActive: radioActive ?? this.radioActive,
        views: views ?? this.views,
      );
}
