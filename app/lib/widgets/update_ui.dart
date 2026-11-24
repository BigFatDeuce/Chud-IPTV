import 'dart:io';

import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import '../updates/updater.dart';
import 'panel.dart';

String _failureText(UpdateFailure? failure, AppLocalizations l) => switch (failure) {
      UpdateFailure.signature => l.updateFailedSignature,
      UpdateFailure.integrity => l.updateFailedIntegrity,
      UpdateFailure.install => l.updateFailedInstall,
      UpdateFailure.network || null => l.updateFailedNetwork,
    };

String? _stageText(Updater u, AppLocalizations l) => switch (u.stage) {
      UpdateStage.idle || UpdateStage.available => null,
      UpdateStage.checking => l.updateChecking,
      UpdateStage.upToDate => l.updateLatest,
      UpdateStage.downloading => l.updateDownloading((u.progress * 100).round()),
      UpdateStage.verifying => l.updateVerifying,
      UpdateStage.restarting => l.updateRestarting,
      UpdateStage.handedToSystem => Platform.isAndroid ? l.updateConfirmSystem : l.updateOpened,
      UpdateStage.cancelled => l.updateCancelled,
      UpdateStage.failed => _failureText(u.failure, l),
    };

class UpdatePanel extends StatelessWidget {
  const UpdatePanel({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final updater = controller.updater;
    return ListenableBuilder(
      listenable: updater,
      builder: (context, _) {
        final release = updater.release;
        final text = _stageText(updater, l);
        return Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.updateTitle, style: theme.titleMedium),
            if (!updater.enabled)
              Text(l.updateNoChannel, style: theme.bodySmall)
            else ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.updateAuto),
                value: controller.settings.autoUpdates,
                onChanged: (value) => controller.updateSettings(controller.settings.copyWith(autoUpdates: value)),
              ),
              if (release != null && updater.stage != UpdateStage.upToDate) ...[
                Text(l.updateAvailable(release.version), style: theme.titleSmall),
                if (release.notesFor(l.localeName).isNotEmpty) Text(release.notesFor(l.localeName), style: theme.bodySmall),
                const SizedBox(height: AppSpace.xs),
              ],
              if (text != null) Text(text, style: theme.bodySmall),
              if (updater.stage == UpdateStage.downloading) ...[
                const SizedBox(height: AppSpace.xs),
                LinearProgressIndicator(value: updater.progress),
              ],
              const SizedBox(height: AppSpace.s),
              Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
                if (release != null && !updater.working)
                  FilledButton.icon(onPressed: updater.install, icon: const Icon(Icons.system_update_alt), label: Text(l.updateInstall)),
                if (updater.stage == UpdateStage.downloading)
                  OutlinedButton(onPressed: updater.cancel, child: Text(l.commonCancel)),
                if (!updater.working && release == null)
                  OutlinedButton.icon(
                    onPressed: () => updater.check(controller.appVersion),
                    icon: const Icon(Icons.refresh),
                    label: Text(l.updateCheck),
                  ),
              ]),
            ],
          ]),
        );
      },
    );
  }
}
