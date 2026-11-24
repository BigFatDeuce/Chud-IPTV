import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../data/repository.dart';
import '../epg/catchup.dart';
import '../l10n/app_localizations.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../player/playback.dart';
import '../player/streams.dart';
import '../screens/player_screen.dart';
import '../theme/tokens.dart';
import 'panel.dart';

String programTimes(Program p, AppLocalizations l) {
  final hour = DateFormat.Hm(l.localeName);
  return '${hour.format(p.startTime)} – ${hour.format(p.stopTime)}';
}

/// Place d'un programme dans le temps.
enum ProgramState { past, current, future }

ProgramState programState(Program p, DateTime now) {
  final seconds = now.millisecondsSinceEpoch ~/ 1000;
  if (p.stop <= seconds) return ProgramState.past;
  return p.start <= seconds ? ProgramState.current : ProgramState.future;
}

Future<void> _playLive(BuildContext context, AppController c, Item item) async {
  final target = await itemToPlay(item, c.repository, c.sources);
  if (target != null && context.mounted) await openPlayer(context, SingleQueue(target), 0);
}

Future<void> _playReplay(BuildContext context, AppController c, Item item, StreamInfo info, Program program) async {
  final source = c.sources.where((s) => s.id == item.sourceId).firstOrNull;
  final request = source == null ? null : catchupRequest(source, info, program);
  if (request == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.guideReplayOff)));
    return;
  }
  await openPlayer(context, SingleQueue(PlayItem(title: program.title, subtitle: item.name, logo: item.logo, request: request)), 0);
}

/// Fiche d'un programme : regarder en direct s'il passe, revoir s'il est passé et que la source
/// le permet. Sinon, on le dit : un bouton qui ne mène à rien serait pire.
void showProgramSheet(BuildContext context, Item item, Program program, StreamInfo? info) {
  final controller = AppScope.of(context);
  final l = context.l10n;
  final now = DateTime.now();
  final state = programState(program, now);
  final replay = info != null && canReplay(info, program, now);
  showAppSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext).textTheme;
      final palette = Palette.of(sheetContext);
      void leaveThen(Future<void> Function() action) {
        Navigator.pop(sheetContext);
        action();
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(program.title, style: theme.titleLarge),
          const SizedBox(height: AppSpace.xs),
          Text(
            '${item.name} · ${DateFormat.MMMEd(l.localeName).format(program.startTime)} · ${programTimes(program, l)} · ${l.seriesMinutes(program.minutes)}',
            style: theme.bodySmall?.copyWith(color: palette.textMuted),
          ),
          if (program.description.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s),
            Text(program.description, style: theme.bodyMedium),
          ],
          const SizedBox(height: AppSpace.m),
          Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
            if (state == ProgramState.current)
              FilledButton.icon(
                autofocus: true,
                onPressed: () => leaveThen(() => _playLive(context, controller, item)),
                icon: const Icon(Icons.play_arrow),
                label: Text(l.guideWatchLive),
              ),
            if (replay)
              FilledButton.icon(
                autofocus: true,
                onPressed: () => leaveThen(() => _playReplay(context, controller, item, info, program)),
                icon: const Icon(Icons.replay),
                label: Text(l.guideReplay),
              ),
            if (state == ProgramState.past && !replay) Text(l.guideReplayOff, style: theme.bodySmall),
            if (state == ProgramState.future) Text(l.guideComing, style: theme.bodySmall),
            TextButton(onPressed: () => Navigator.pop(sheetContext), child: Text(l.commonClose)),
          ]),
        ]),
      );
    },
  );
}

/// Programme d'une chaîne, de la veille aux jours à venir, ouvert sur ce qui passe maintenant.
void showChannelGuide(BuildContext context, Item item) {
  final controller = AppScope.of(context);
  showAppSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AppScope(
      controller: controller,
      child: FractionallySizedBox(heightFactor: 0.85, child: _ChannelGuide(item: item)),
    ),
  );
}

class _ChannelGuide extends StatefulWidget {
  const _ChannelGuide({required this.item});

  final Item item;

  @override
  State<_ChannelGuide> createState() => _ChannelGuideState();
}

class _ChannelGuideState extends State<_ChannelGuide> {
  static const _rowHeight = 56.0;

  List<Program>? _programs;
  StreamInfo? _info;
  ScrollController? _scroll;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_programs == null) _load();
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final now = DateTime.now();
    final programs = await repository.programs(widget.item.id, now.subtract(const Duration(days: 1)), now.add(const Duration(days: 3)));
    final info = await repository.streamInfo(widget.item.id);
    if (!mounted) return;
    final current = programs.indexWhere((p) => programState(p, now) != ProgramState.past);
    setState(() {
      _programs = programs;
      _info = info;
      _scroll?.dispose();
      _scroll = ScrollController(initialScrollOffset: current <= 0 ? 0 : current * _rowHeight);
    });
  }

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final programs = _programs;
    final now = DateTime.now();
    final day = DateFormat.MMMEd(l.localeName);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.s, 0),
        child: Row(children: [
          Expanded(child: Text(widget.item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleLarge)),
          TextButton.icon(
            onPressed: () async {
              if (await showGuideLinker(context, widget.item)) _load();
            },
            icon: const Icon(Icons.link),
            label: Text(l.guideLink),
          ),
        ]),
      ),
      const SizedBox(height: AppSpace.s),
      Expanded(
        child: programs == null
            ? const SizedBox.shrink()
            : programs.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(AppSpace.l), child: Text(l.guideNoProgram)))
                : ListView.builder(
                    controller: _scroll,
                    itemExtent: _rowHeight,
                    itemCount: programs.length,
                    itemBuilder: (context, i) {
                      final p = programs[i];
                      final state = programState(p, now);
                      final replay = _info != null && canReplay(_info!, p, now);
                      return FocusTile(
                        selected: state == ProgramState.current,
                        autofocus: state == ProgramState.current,
                        onTap: () => showProgramSheet(context, widget.item, p, _info),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: AppSpace.xs),
                          child: Row(children: [
                            SizedBox(
                              width: 118,
                              child: Text(
                                '${day.format(p.startTime)}\n${programTimes(p, l)}',
                                maxLines: 2,
                                style: theme.labelSmall?.copyWith(color: palette.textMuted),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                p.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodyMedium?.copyWith(color: state == ProgramState.past && !replay ? palette.textFaint : null),
                              ),
                            ),
                            if (state == ProgramState.current) const Icon(Icons.circle, size: 10, color: AppColors.live),
                            if (replay) Icon(Icons.replay, size: 18, color: palette.accent),
                          ]),
                        ),
                      );
                    },
                  ),
      ),
    ]);
  }
}

/// Choix manuel de la chaîne du guide. Renvoie vrai si une chaîne a été choisie.
Future<bool> showGuideLinker(BuildContext context, Item item) async {
  final controller = AppScope.of(context);
  final chosen = await showDialog<String>(context: context, builder: (_) => AppScope(controller: controller, child: _GuideLinker(item: item)));
  if (chosen == null) return false;
  await controller.linkToGuide(item.id, chosen);
  return true;
}

class _GuideLinker extends StatefulWidget {
  const _GuideLinker({required this.item});

  final Item item;

  @override
  State<_GuideLinker> createState() => _GuideLinkerState();
}

class _GuideLinkerState extends State<_GuideLinker> {
  List<String> _matches = const [];

  Future<void> _search(String text) async {
    final found = await AppScope.of(context).repository.searchGuideChannels(text);
    if (mounted) setState(() => _matches = found);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.guideLink),
      content: SizedBox(
        width: 420,
        height: 360,
        child: Column(children: [
          FieldNavigation(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: l.guideLinkHint, prefixIcon: const Icon(Icons.search)),
              onChanged: _search,
            ),
          ),
          const SizedBox(height: AppSpace.s),
          Expanded(
            child: ListView(children: [
              for (final channel in _matches)
                FocusTile(
                  onTap: () => Navigator.pop(context, channel),
                  child: Padding(padding: const EdgeInsets.all(AppSpace.m), child: Text(channel)),
                ),
            ]),
          ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel))],
    );
  }
}

/// Sources du guide : celles des sources IPTV, et les adresses ou fichiers ajoutés à la main.
class GuideSourcesPanel extends StatelessWidget {
  const GuideSourcesPanel({super.key, required this.controller});

  final AppController controller;

  Future<void> _addUrl(BuildContext context) async {
    final l = context.l10n;
    final text = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.guideAddUrl),
        content: SizedBox(
          width: 420,
          child: FieldNavigation(
            child: TextField(
              controller: text,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(hintText: l.guideUrlHint),
              onSubmitted: (value) => Navigator.pop(dialogContext, value),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, text.text), child: Text(l.commonSave)),
        ],
      ),
    );
    text.dispose();
    final address = url?.trim() ?? '';
    final uri = Uri.tryParse(address);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return;
    await controller.addGuideUrl(address);
  }

  Future<void> _addFile() async {
    final file = await openFile(acceptedTypeGroups: const [XTypeGroup(label: 'XMLTV', extensions: ['xml', 'gz', 'xmltv'])]);
    if (file != null) await controller.addGuideFile(file.path, file.name);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.guideTitle, style: theme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        for (final source in controller.epgSources)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xs),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(source.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyMedium),
                  Text(
                    source.refreshedAt == null ? l.guideNeverRefreshed : l.guideSourceLine(source.programs, formatDateTime(source.refreshedAt!, l)),
                    style: theme.bodySmall,
                  ),
                  if (source.error != null) Text(l.guideLastFailed, style: theme.bodySmall?.copyWith(color: palette.warning)),
                ]),
              ),
              if (source.sourceId == null)
                IconButton(
                  tooltip: l.commonDelete,
                  onPressed: () => controller.deleteGuide(source),
                  icon: const Icon(Icons.delete_outline),
                ),
            ]),
          ),
        if (controller.guideBusy) ...[
          const SizedBox(height: AppSpace.xs),
          Text(l.guideImporting(controller.guideProgress), style: theme.bodySmall),
          const SizedBox(height: AppSpace.xs),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: AppSpace.s),
        Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
          OutlinedButton.icon(
            onPressed: controller.guideBusy || controller.sources.isEmpty && controller.epgSources.isEmpty ? null : controller.refreshGuides,
            icon: const Icon(Icons.refresh),
            label: Text(l.guideRefresh),
          ),
          OutlinedButton.icon(onPressed: () => _addUrl(context), icon: const Icon(Icons.link), label: Text(l.guideAddUrl)),
          OutlinedButton.icon(onPressed: _addFile, icon: const Icon(Icons.folder_open), label: Text(l.guideAddFile)),
        ]),
      ]),
    );
  }
}
