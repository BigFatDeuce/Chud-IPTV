import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../models/source.dart';
import '../player/streams.dart';
import '../theme/tokens.dart';
import '../widgets/download_ui.dart';
import '../widgets/logo.dart';
import '../widgets/panel.dart';
import 'player_screen.dart';

/// Saisons et épisodes d'une série Xtream, demandés au fournisseur à l'ouverture.
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key, required this.item, required this.source, required this.seriesId});

  final Item item;
  final Source source;
  final String seriesId;

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<Season>? _seasons;
  bool _failed = false;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _seasons = null;
      _failed = false;
    });
    try {
      final seasons = await fetchSeasons(widget.source, widget.seriesId);
      if (mounted) setState(() => _seasons = seasons);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final seasons = _seasons;
    final Widget body;
    if (_failed) {
      body = EmptyState(
        message: l.seriesFailed,
        action: FilledButton(autofocus: true, onPressed: _load, child: Text(l.commonRetry)),
      );
    } else if (seasons == null) {
      body = Center(child: CircularProgressIndicator(color: palette.accent));
    } else if (seasons.isEmpty) {
      body = EmptyState(message: l.seriesEmpty);
    } else {
      final season = seasons[_selected.clamp(0, seasons.length - 1)];
      body = Column(children: [
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
            itemCount: seasons.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: AppSpace.s),
              child: FilterChip(
                label: Text(l.seriesSeason(seasons[i].number)),
                selected: i == _selected,
                onSelected: (_) => setState(() => _selected = i),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemExtent: 76,
            itemCount: season.episodes.length,
            itemBuilder: (context, i) {
              final e = season.episodes[i];
              final minutes = e.durationSeconds == null ? null : (e.durationSeconds! / 60).round();
              return Row(children: [
                Expanded(
                  child: FocusTile(
                autofocus: i == 0 && usesKeyNavigation,
                onTap: () => openPlayer(context, EpisodeQueue(widget.source, widget.item.name, season, widget.item.logo), i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
                  child: Row(children: [
                    Logo(url: e.image.isEmpty ? widget.item.logo : e.image, name: '${e.number}', width: 96, height: 60, fit: BoxFit.cover),
                    const SizedBox(width: AppSpace.m),
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.seriesEpisode(e.number), style: theme.titleMedium),
                        Text(
                          [e.title, if (minutes != null) l.seriesMinutes(minutes)].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.bodySmall,
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
                ),
                EpisodeDownloadButton(source: widget.source, series: widget.item.name, logo: widget.item.logo, season: season.number, episode: e),
                const SizedBox(width: AppSpace.s),
              ]);
            },
          ),
        ),
      ]);
    }
    final downloads = AppScope.of(context).downloads;
    final current = seasons == null || seasons.isEmpty ? null : seasons[_selected.clamp(0, seasons.length - 1)];
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (current != null)
            TextButton.icon(
              icon: const Icon(Icons.download_outlined),
              label: Text(l.downloadSeason),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                for (final episode in current.episodes) {
                  await downloads.enqueueEpisode(widget.source, widget.item.name, widget.item.logo, current.number, episode);
                }
                messenger.showSnackBar(SnackBar(content: Text(l.downloadAdded(l.seriesSeason(current.number)))));
              },
            ),
        ],
        backgroundColor: palette.tabBar,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleLarge),
      ),
      body: body,
    );
  }
}
