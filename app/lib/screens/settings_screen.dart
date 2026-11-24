import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../downloads/device_folder.dart';
import '../l10n/app_localizations.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import '../widgets/backup_ui.dart';
import '../widgets/guide_ui.dart';
import '../widgets/panel.dart';
import '../widgets/update_ui.dart';

/// Langues proposées, chacune dans sa propre langue.
const languages = <String, String>{
  'fr': 'Français',
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'de': 'Deutsch',
  'it': 'Italiano',
  'ru': 'Русский',
  'tr': 'Türkçe',
  'id': 'Bahasa Indonesia',
  'vi': 'Tiếng Việt',
};

String languageName(String? code, AppLocalizations l) => languages[code] ?? l.languageSystem;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickLanguage(BuildContext context) async {
    final controller = AppScope.of(context);
    final l = context.l10n;
    final current = controller.settings.language ?? '';
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.settingsLanguage),
        children: [
          for (final entry in [MapEntry('', l.languageSystem), ...languages.entries])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, entry.key),
              child: Row(children: [
                SizedBox(width: 28, child: entry.key == current ? const Icon(Icons.check, size: 18) : null),
                Text(entry.value),
              ]),
            ),
        ],
      ),
    );
    if (chosen != null) controller.updateSettings(controller.settings.copyWith(language: () => chosen.isEmpty ? null : chosen));
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final s = controller.settings;
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpace.l),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SectionTitle(l.settingsTitle),
              const SizedBox(height: AppSpace.m),
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.settingsTheme, style: theme.titleMedium),
                  const SizedBox(height: AppSpace.s),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
                      ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
                      ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => controller.updateSettings(s.copyWith(themeMode: v.first)),
                  ),
                  const SizedBox(height: AppSpace.l),
                  Text(l.settingsLanguage, style: theme.titleMedium),
                  const SizedBox(height: AppSpace.s),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.language),
                    label: Text(languageName(s.language, l)),
                    onPressed: () => _pickLanguage(context),
                  ),
                ]),
              ),
              const SizedBox(height: AppSpace.m),
              UpdatePanel(controller: controller),
              const SizedBox(height: AppSpace.m),
              GuideSourcesPanel(controller: controller),
              const SizedBox(height: AppSpace.m),
              _AutoRefreshPanel(controller: controller),
              if (!Platform.isAndroid) ...[
                const SizedBox(height: AppSpace.m),
                _ExternalPlayerPanel(controller: controller),
              ],
              const SizedBox(height: AppSpace.m),
              if (controller.phone != null) ...[
                _PhonePlaybackPanel(controller: controller),
                const SizedBox(height: AppSpace.m),
              ],
              // Android TV n'a pas de sélecteur de dossier.
              if (!controller.isTelevision) ...[
                _DownloadFolderPanel(controller: controller),
                const SizedBox(height: AppSpace.m),
              ],
              BackupPanel(controller: controller),
              const SizedBox(height: AppSpace.m),
              _DataPanel(controller: controller),
              const SizedBox(height: AppSpace.m),
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.settingsApp, style: theme.titleMedium),
                  if (controller.appVersion.isNotEmpty) Text(l.settingsVersion(controller.appVersion), style: theme.bodySmall),
                  const SizedBox(height: AppSpace.xs),
                  Text(l.settingsPrivacy, style: theme.bodySmall),
                  if (Platform.isWindows || Platform.isLinux) ...[
                    const SizedBox(height: AppSpace.xs),
                    Text(l.settingsShortcuts, style: theme.bodySmall),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Options réservées aux téléphones. Une fois activées, leurs boutons apparaissent dans le lecteur.
class _PhonePlaybackPanel extends StatelessWidget {
  const _PhonePlaybackPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = controller.settings;
    final phone = controller.phone!;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.settingsPhoneTitle, style: Theme.of(context).textTheme.titleMedium),
        if (phone.supportsPip)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.settingsPip),
            subtitle: Text(l.settingsPipBody),
            value: s.pipOption,
            onChanged: (value) => controller.updateSettings(s.copyWith(pipOption: value, pipActive: true)),
          ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.settingsRadio),
          subtitle: Text(l.settingsRadioBody),
          value: s.radioOption,
          onChanged: (value) {
            controller.updateSettings(s.copyWith(radioOption: value, radioActive: true));
            if (value) phone.askNotifications();
          },
        ),
      ]),
    );
  }
}

class _DownloadFolderPanel extends StatelessWidget {
  const _DownloadFolderPanel({required this.controller});

  final AppController controller;

  Future<void> _choose() async {
    final folder = Platform.isAndroid ? await AndroidDocuments.pick() : await getDirectoryPath();
    if (folder != null) controller.updateSettings(controller.settings.copyWith(downloadDir: folder));
  }

  String _label(AppLocalizations l) {
    final chosen = controller.settings.downloadDir;
    if (isDocument(chosen)) return folderLabel(chosen);
    return Platform.isAndroid ? l.downloadFolderApp : controller.downloadFolder;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.downloadFolder, style: theme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        Text(_label(l), maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
        Text(l.downloadFolderHint, style: theme.bodySmall),
        const SizedBox(height: AppSpace.s),
        Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
          OutlinedButton.icon(onPressed: _choose, icon: const Icon(Icons.folder_open), label: Text(l.downloadFolderChoose)),
          if (controller.settings.downloadDir.isNotEmpty)
            TextButton(
              onPressed: () => controller.updateSettings(controller.settings.copyWith(downloadDir: '')),
              child: Text(l.downloadFolderReset),
            ),
        ]),
      ]),
    );
  }
}

/// Intervalles proposés, en heures.
const _intervals = [0, 6, 12, 24, 48, 168];

class _AutoRefreshPanel extends StatelessWidget {
  const _AutoRefreshPanel({required this.controller});

  final AppController controller;

  Widget _row(BuildContext context, String label, int value, ValueChanged<int> onChanged) {
    final l = context.l10n;
    return Row(children: [
      Expanded(child: Text(label)),
      DropdownButton<int>(
        value: _intervals.contains(value) ? value : 24,
        items: [
          for (final hours in _intervals) DropdownMenuItem(value: hours, child: Text(hours == 0 ? l.autoOff : l.autoEvery(hours))),
        ],
        onChanged: (hours) {
          if (hours != null) onChanged(hours);
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = controller.settings;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.autoTitle, style: Theme.of(context).textTheme.titleMedium),
        _row(context, l.navSources, s.sourceHours, (hours) => controller.updateSettings(s.copyWith(sourceHours: hours))),
        _row(context, l.guideTitle, s.guideHours, (hours) => controller.updateSettings(s.copyWith(guideHours: hours))),
      ]),
    );
  }
}

class _DataPanel extends StatefulWidget {
  const _DataPanel({required this.controller});

  final AppController controller;

  @override
  State<_DataPanel> createState() => _DataPanelState();
}

class _DataPanelState extends State<_DataPanel> {
  int? _cache;
  bool _visible = false;

  /// Les réglages restent construits derrière les autres onglets : on mesure à chaque retour.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible) _measure();
    _visible = visible;
  }

  Future<void> _measure() async {
    final size = await widget.controller.cacheSize();
    if (mounted) setState(() => _cache = size);
  }

  Future<void> _clear() async {
    final message = context.l10n.cacheCleared;
    final messenger = ScaffoldMessenger.of(context);
    await widget.controller.clearCache();
    await _measure();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _wipe() async {
    final l = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.wipeTitle),
        content: Text(l.wipeBody),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l.wipeConfirm),
          ),
        ],
      ),
    );
    if (sure == true) await widget.controller.wipeAll();
    await _measure();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final c = widget.controller;
    final size = _cache;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.dataTitle, style: theme.titleMedium),
        if (size != null) Text(l.cacheLine((size / (1024 * 1024)).toStringAsFixed(1)), style: theme.bodySmall),
        const SizedBox(height: AppSpace.s),
        Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
          OutlinedButton.icon(onPressed: _clear, icon: const Icon(Icons.cleaning_services_outlined), label: Text(l.cacheClear)),
          OutlinedButton.icon(
            onPressed: c.busy || c.guideBusy ? null : _wipe,
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(l.wipeButton),
          ),
        ]),
      ]),
    );
  }
}

class _ExternalPlayerPanel extends StatelessWidget {
  const _ExternalPlayerPanel({required this.controller});

  final AppController controller;

  Future<void> _choose() async {
    final file = await openFile(acceptedTypeGroups: Platform.isWindows ? const [XTypeGroup(label: 'exe', extensions: ['exe'])] : const []);
    if (file != null) controller.updateSettings(controller.settings.copyWith(externalPlayer: file.path));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final current = controller.externalPlayer;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.externalTitle, style: theme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        Text(current.isEmpty ? l.externalNone : current, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
        const SizedBox(height: AppSpace.s),
        Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
          OutlinedButton.icon(onPressed: _choose, icon: const Icon(Icons.folder_open), label: Text(l.formChooseFile)),
          if (controller.settings.externalPlayer.isNotEmpty)
            TextButton(
              onPressed: () => controller.updateSettings(controller.settings.copyWith(externalPlayer: '')),
              child: Text(l.externalDefault),
            ),
        ]),
      ]),
    );
  }
}
