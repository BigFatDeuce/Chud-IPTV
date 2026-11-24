import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../app_controller.dart';
import '../backup/backup.dart';
import '../l10n/app_localizations.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import 'panel.dart';

const _minPassphrase = 8;

String backupErrorText(BackupError error, AppLocalizations l) => switch (error) {
      BackupError.notBackup => l.backupNotOurs,
      BackupError.tooNew => l.backupTooNew,
      BackupError.wrongPassphrase => l.backupWrongPassphrase,
      BackupError.damaged => l.backupDamaged,
    };

/// Sauvegarde et restauration, depuis un fichier que l'utilisateur garde où il veut.
class BackupPanel extends StatefulWidget {
  const BackupPanel({super.key, required this.controller});

  final AppController controller;

  @override
  State<BackupPanel> createState() => _BackupPanelState();
}

class _BackupPanelState extends State<BackupPanel> {
  bool _busy = false;

  void _tell(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export() async {
    final l = context.l10n;
    final choice = await showDialog<_ExportChoice>(context: context, builder: (_) => const _ExportDialog());
    if (choice == null) return;
    final day = DateTime.now().toIso8601String().substring(0, 10);
    final name = 'chud-iptv-$day.$backupExtension';
    final String? path;
    if (Platform.isAndroid) {
      final folder = await getExternalStorageDirectory();
      path = folder == null ? null : '${folder.path}/$name';
    } else {
      final location = await getSaveLocation(
        suggestedName: name,
        acceptedTypeGroups: const [XTypeGroup(label: 'Chud IPTV', extensions: [backupExtension])],
      );
      path = location?.path;
    }
    if (path == null) return;
    setState(() => _busy = true);
    try {
      await widget.controller.exportBackup(path, passphrase: choice.passphrase);
      _tell(l.backupSaved);
    } on FileSystemException {
      _tell(l.backupFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l = context.l10n;
    final file = await openFile(acceptedTypeGroups: const [XTypeGroup(label: 'Chud IPTV', extensions: [backupExtension])]);
    if (file == null) return;
    setState(() => _busy = true);
    try {
      final text = await file.readAsString();
      final header = readHeader(text);
      String? passphrase;
      if (header.encrypted) {
        if (!mounted) return;
        passphrase = await showDialog<String>(context: context, builder: (_) => const _PassphraseDialog());
        if (passphrase == null) return;
      }
      final data = await decodeBackup(text, passphrase: passphrase);
      if (!mounted) return;
      final sure = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.backupConfirmTitle),
          content: Text(l.backupConfirmBody(formatDateTime(header.createdAt, l), header.sources, header.lists, header.favorites)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.commonCancel)),
            FilledButton(autofocus: true, onPressed: () => Navigator.pop(dialogContext, true), child: Text(l.backupRestore)),
          ],
        ),
      );
      if (sure != true) return;
      final report = await widget.controller.restoreBackup(data);
      _tell(report.incomplete > 0 ? l.backupIncomplete(report.incomplete) : l.backupRestored);
    } on BackupFailure catch (e) {
      _tell(backupErrorText(e.error, l));
    } on FileSystemException {
      _tell(l.backupDamaged);
    } on FormatException {
      _tell(l.backupNotOurs);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.backupTitle, style: theme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        if (_busy) ...[const LinearProgressIndicator(), const SizedBox(height: AppSpace.xs)],
        Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
          OutlinedButton.icon(onPressed: _busy ? null : _export, icon: const Icon(Icons.save_alt), label: Text(l.backupExport)),
          OutlinedButton.icon(onPressed: _busy ? null : _import, icon: const Icon(Icons.restore), label: Text(l.backupImport)),
        ]),
      ]),
    );
  }
}

class _ExportChoice {
  const _ExportChoice(this.passphrase);

  /// Null : fichier lisible, sans mots de passe ni adresses complètes.
  final String? passphrase;
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  bool _secrets = false;
  String? _problem;

  void _confirm() {
    final l = context.l10n;
    if (!_secrets) {
      Navigator.pop(context, const _ExportChoice(null));
    } else if (_first.text.length < _minPassphrase) {
      setState(() => _problem = l.backupPassphraseShort);
    } else if (_first.text != _second.text) {
      setState(() => _problem = l.backupPassphraseMismatch);
    } else {
      Navigator.pop(context, _ExportChoice(_first.text));
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.backupExport),
      content: SizedBox(
        width: 440,
        child: FieldNavigation(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.backupSecrets),
              subtitle: Text(l.backupSecretsBody),
              value: _secrets,
              onChanged: (value) => setState(() => _secrets = value),
            ),
            if (_secrets) ...[
              TextField(controller: _first, obscureText: true, autofocus: true, decoration: InputDecoration(labelText: l.backupPassphrase)),
              const SizedBox(height: AppSpace.s),
              TextField(
                controller: _second,
                obscureText: true,
                decoration: InputDecoration(labelText: l.backupPassphraseAgain, errorText: _problem),
                onSubmitted: (_) => _confirm(),
              ),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: _confirm, child: Text(l.commonSave)),
      ],
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog();

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.backupPassphrase),
      content: SizedBox(
        width: 400,
        child: FieldNavigation(
          child: TextField(controller: _text, obscureText: true, autofocus: true, onSubmitted: (value) => Navigator.pop(context, value)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _text.text), child: Text(l.backupRestore)),
      ],
    );
  }
}
