import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/catalog.dart';
import '../models/download.dart';
import '../models/format.dart';
import '../models/source.dart';
import '../player/playback.dart';
import '../player/streams.dart';
import '../screens/player_screen.dart';
import '../theme/tokens.dart';

String downloadSize(int bytes, AppLocalizations l) {
  final megabytes = bytes / (1024 * 1024);
  return megabytes >= 1024 ? l.downloadSizeGb((megabytes / 1024).toStringAsFixed(1)) : l.downloadSizeMb(megabytes.toStringAsFixed(0));
}

String downloadErrorText(DownloadError? error, AppLocalizations l) => switch (error) {
      DownloadError.server => l.downloadErrorServer,
      DownloadError.format => l.downloadErrorFormat,
      DownloadError.disk => l.downloadErrorDisk,
      DownloadError.source => l.downloadErrorSource,
      DownloadError.missing => l.downloadErrorMissing,
      DownloadError.network || null => l.downloadErrorNetwork,
    };

/// Lit le fichier téléchargé : aucune connexion n'est nécessaire.
Future<void> playDownload(BuildContext context, Download d) => openPlayer(
      context,
      SingleQueue(PlayItem(title: d.title, subtitle: d.subtitle, logo: d.logo, request: PlayRequest(url: d.path, live: false))),
      0,
    );

void _notify(BuildContext context, Download? added, String title) {
  final l = context.l10n;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(added == null ? l.downloadErrorFormat : l.downloadAdded(title))));
}

/// Bouton de la fiche d'un film ou d'une vidéo de playlist.
class ItemDownloadButton extends StatelessWidget {
  const ItemDownloadButton({super.key, required this.item, required this.streamKey});

  final Item item;
  final String streamKey;

  @override
  Widget build(BuildContext context) {
    final manager = AppScope.of(context).downloads;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        final d = manager.find(item.sourceId, item.type, streamKey);
        if (d == null) {
          return OutlinedButton.icon(
            onPressed: () async {
              final added = await manager.enqueueItem(item);
              if (context.mounted) _notify(context, added, item.name);
            },
            icon: const Icon(Icons.download_outlined),
            label: Text(l.downloadAction),
          );
        }
        if (d.state == DownloadState.done) {
          return OutlinedButton.icon(
            onPressed: () => playDownload(context, d),
            icon: const Icon(Icons.offline_pin_outlined),
            label: Text(l.downloadPlay),
          );
        }
        final progress = d.progress;
        return OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.downloading),
          label: Text(progress == null ? l.navDownloads : '${l.navDownloads} · ${(progress * 100).round()} %'),
        );
      },
    );
  }
}

/// Bouton d'un épisode : télécharger, puis suivre l'avancement.
class EpisodeDownloadButton extends StatelessWidget {
  const EpisodeDownloadButton({super.key, required this.source, required this.series, required this.logo, required this.season, required this.episode});

  final Source source;
  final String series;
  final String logo;
  final int season;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final manager = AppScope.of(context).downloads;
    final l = context.l10n;
    final palette = Palette.of(context);
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        final d = manager.find(source.id, ItemType.series, 'id:${episode.id}');
        return switch (d?.state) {
          null => IconButton(
              tooltip: l.downloadAction,
              icon: const Icon(Icons.download_outlined),
              onPressed: () async {
                final added = await manager.enqueueEpisode(source, series, logo, season, episode);
                if (context.mounted) _notify(context, added, episode.title);
              },
            ),
          DownloadState.done => IconButton(
              tooltip: l.downloadPlay,
              icon: Icon(Icons.offline_pin, color: palette.accent),
              onPressed: () => playDownload(context, d!),
            ),
          DownloadState.failed => IconButton(
              tooltip: l.commonRetry,
              icon: Icon(Icons.error_outline, color: palette.warning),
              onPressed: () => manager.resume(d!),
            ),
          DownloadState.paused => IconButton(tooltip: l.downloadResume, icon: const Icon(Icons.play_arrow), onPressed: () => manager.resume(d!)),
          _ => Padding(
              padding: const EdgeInsets.all(AppSpace.m),
              child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 3, value: d?.progress, color: palette.accent)),
            ),
        };
      },
    );
  }
}
