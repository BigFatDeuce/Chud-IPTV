import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../downloads/download_manager.dart';
import '../models/download.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import '../widgets/download_ui.dart';
import '../widgets/logo.dart';
import '../widgets/panel.dart';

/// Films et épisodes enregistrés sur cet appareil, lisibles sans connexion.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  Future<void> _delete(BuildContext context, DownloadManager manager, Download d) async {
    final l = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.downloadDeleteTitle),
        content: Text(l.downloadDeleteBody(d.title)),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l.commonDelete)),
        ],
      ),
    );
    if (sure == true) await manager.remove(d);
  }

  @override
  Widget build(BuildContext context) {
    final manager = AppScope.of(context).downloads;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        final entries = manager.entries;
        if (entries.isEmpty) return EmptyState(title: l.downloadEmptyTitle, message: l.downloadEmptyBody);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
          itemExtent: 92,
          itemCount: entries.length,
          itemBuilder: (context, i) => _Row(
            download: entries[i],
            manager: manager,
            first: i == 0,
            onDelete: () => _delete(context, manager, entries[i]),
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.download, required this.manager, required this.first, required this.onDelete});

  final Download download;
  final DownloadManager manager;
  final bool first;
  final VoidCallback onDelete;

  String _status(BuildContext context) {
    final l = context.l10n;
    final d = download;
    final amount = d.total == null ? downloadSize(d.received, l) : '${downloadSize(d.received, l)} / ${downloadSize(d.total!, l)}';
    return switch (d.state) {
      DownloadState.done => downloadSize(d.total ?? d.received, l),
      DownloadState.failed => downloadErrorText(d.error, l),
      DownloadState.active => amount,
      DownloadState.paused => '${l.downloadPaused} · $amount',
      DownloadState.queued => manager.held ? l.downloadHeld : l.downloadQueued,
    };
  }

  @override
  Widget build(BuildContext context) {
    final d = download;
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final done = d.state == DownloadState.done;
    return Row(children: [
      Expanded(
        child: FocusTile(
          autofocus: first && usesKeyNavigation,
          onTap: () {
            if (done) playDownload(context, d);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
            child: Row(children: [
              Logo(url: d.logo, name: d.title, width: 96, height: 72),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleMedium),
                  if (d.subtitle.isNotEmpty) Text(d.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
                  Text(
                    _status(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall?.copyWith(color: d.state == DownloadState.failed ? palette.warning : palette.textMuted),
                  ),
                  if (d.state == DownloadState.active) ...[
                    const SizedBox(height: AppSpace.xs),
                    LinearProgressIndicator(minHeight: 3, value: d.progress, color: palette.accent, backgroundColor: palette.line),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
      if (done) IconButton(tooltip: l.downloadPlay, icon: const Icon(Icons.play_arrow), onPressed: () => playDownload(context, d)),
      if (d.state == DownloadState.active || d.state == DownloadState.queued)
        IconButton(tooltip: l.downloadPause, icon: const Icon(Icons.pause), onPressed: () => manager.pause(d)),
      if (d.state == DownloadState.paused) IconButton(tooltip: l.downloadResume, icon: const Icon(Icons.play_arrow), onPressed: () => manager.resume(d)),
      if (d.state == DownloadState.failed) IconButton(tooltip: l.commonRetry, icon: const Icon(Icons.refresh), onPressed: () => manager.resume(d)),
      IconButton(tooltip: l.commonDelete, icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      const SizedBox(width: AppSpace.s),
    ]);
  }
}
