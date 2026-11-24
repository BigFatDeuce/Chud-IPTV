import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../import/importer.dart';
import '../l10n/app_localizations.dart';
import '../models/format.dart';
import '../models/source.dart';
import '../theme/tokens.dart';
import '../widgets/panel.dart';
import 'source_form.dart';

/// Liste des sources et de leur état.
class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpace.l),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionTitle(l.sourcesTitle),
              const SizedBox(height: AppSpace.m),
              Wrap(spacing: AppSpace.s, runSpacing: AppSpace.s, children: [
                FilledButton.icon(
                  onPressed: () => openSourceForm(context),
                  icon: const Icon(Icons.add),
                  label: Text(l.addSource),
                ),
                if (controller.sources.length > 1)
                  OutlinedButton.icon(
                    onPressed: controller.refreshAll,
                    icon: const Icon(Icons.sync),
                    label: Text(l.refreshAll),
                  ),
              ]),
              const SizedBox(height: AppSpace.l),
              for (final source in controller.sources) ...[
                SourceCard(source: source),
                const SizedBox(height: AppSpace.m),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

String stageText(ImportProgress? p, AppLocalizations l) {
  if (p == null) return l.stageConnecting;
  return switch (p.stage) {
    ImportStage.connecting => l.stageConnecting,
    ImportStage.downloadingLive => l.stageLive,
    ImportStage.downloadingMovies => l.stageMovies,
    ImportStage.downloadingSeries => l.stageSeries,
    ImportStage.downloadingPlaylist => l.stagePlaylist,
    ImportStage.writing => p.items == 0 ? l.stageWriting : l.stageWritingCount(p.items),
  };
}

class SourceCard extends StatelessWidget {
  const SourceCard({super.key, required this.source});

  final Source source;

  Future<void> _confirmDelete(BuildContext context, AppController controller) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.deleteSource),
        content: Text(l.deleteSourceConfirm(source.name)),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteSource(source);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final activity = controller.activityOf(source.id);
    final waiting = activity == SourceActivity.queued;
    final busy = activity != SourceActivity.idle;
    final error = source.error;

    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(source.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleLarge)),
                if (source.isDefault) ...[
                  const SizedBox(width: AppSpace.s),
                  Tooltip(message: l.isDefault, child: const Icon(Icons.star, size: 16, color: AppColors.favorite)),
                ],
              ]),
              Text(sourceKindText(source.kind, l), style: theme.bodySmall),
            ]),
          ),
          Tooltip(
            message: l.sourceEnabled,
            child: Switch(
              value: source.enabled,
              onChanged: busy ? null : (v) => controller.setEnabled(source, v),
            ),
          ),
        ]),
        const SizedBox(height: AppSpace.s),
        Text(l.countsLine(source.liveCount, source.movieCount, source.seriesCount), style: theme.bodyMedium),
        const SizedBox(height: 2),
        Text(
          source.refreshedAt == null ? l.neverRefreshed : l.refreshedAt(formatDateTime(source.refreshedAt!, l)),
          style: theme.bodySmall,
        ),
        if (source.expiresAt != null) Text(l.expiresAt(formatDate(source.expiresAt!, l)), style: theme.bodySmall),
        if (source.maxConnections != null) Text(l.maxConnections(source.maxConnections!), style: theme.bodySmall),
        if (busy) ...[
          const SizedBox(height: AppSpace.m),
          Text(waiting ? l.stageQueued : stageText(controller.importProgress, l), style: theme.bodySmall?.copyWith(color: palette.accent)),
          const SizedBox(height: AppSpace.xs),
          LinearProgressIndicator(minHeight: 3, color: palette.accent, backgroundColor: palette.line),
        ] else if (error != null) ...[
          const SizedBox(height: AppSpace.m),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.error_outline, size: 16, color: AppColors.error),
            const SizedBox(width: AppSpace.s),
            Expanded(child: Text(importErrorText(error, source.errorDetail, l), style: theme.bodySmall)),
          ]),
        ],
        const SizedBox(height: AppSpace.s),
        Wrap(spacing: AppSpace.xs, runSpacing: AppSpace.xs, children: [
          TextButton.icon(
            onPressed: busy ? null : () => controller.refresh(source.id),
            icon: const Icon(Icons.sync, size: 18),
            label: Text(error == null ? l.refresh : l.commonRetry),
          ),
          if (error == ImportError.suspicious || error == ImportError.empty)
            TextButton(
              onPressed: busy ? null : () => controller.refresh(source.id, force: true),
              child: Text(l.applyAnyway),
            ),
          TextButton.icon(
            onPressed: busy ? null : () => openSourceForm(context, source: source),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l.editSource),
          ),
          if (!source.isDefault)
            TextButton.icon(
              onPressed: busy ? null : () => controller.setDefault(source),
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(l.makeDefault),
            ),
          TextButton.icon(
            onPressed: busy ? null : () => _confirmDelete(context, controller),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l.commonDelete),
          ),
        ]),
      ]),
    );
  }
}
