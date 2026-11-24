import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../data/repository.dart';
import '../epg/catchup.dart';
import '../l10n/app_localizations.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../player/streams.dart';
import '../theme/tokens.dart';
import '../widgets/favorites_ui.dart';
import '../widgets/guide_ui.dart';
import '../widgets/item_views.dart';
import '../widgets/logo.dart';
import '../widgets/panel.dart';
import 'player_screen.dart';

const _rowHeight = 64.0;
const _headerHeight = 32.0;
const _pixelsPerMinute = 4.0;

/// Pas des boutons « plus tôt » et « plus tard ».
const _stepMinutes = 120;

/// Jours proposés : la semaine écoulée et la semaine à venir.
const _daysAround = 7;

/// Programmes déjà chargés d'une chaîne, pour ne rien relire en revenant sur une ligne.
class _Line {
  const _Line(this.programs, this.info);

  final List<Program> programs;
  final StreamInfo? info;
}

/// Vue générale : les chaînes en lignes, le temps en colonnes.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final _horizontal = ScrollController();
  final _names = ScrollController();
  final _rows = ScrollController();
  final _lines = <int, _Line>{};
  late DateTime _day = _midnight(DateTime.now());
  DateTime _now = DateTime.now();
  Timer? _clock;
  ItemPager? _pager;
  int? _list;
  Category? _category;
  String _text = '';
  Timer? _debounce;
  int _catalogVersion = -1;
  int _guideVersion = -1;
  int? _source;
  bool _placed = false;

  static DateTime _midnight(DateTime t) => DateTime(t.year, t.month, t.day);

  @override
  void initState() {
    super.initState();
    _names.addListener(() => _follow(_names, _rows));
    _rows.addListener(() => _follow(_rows, _names));
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => setState(() => _now = DateTime.now()));
  }

  void _follow(ScrollController from, ScrollController to) {
    if (to.hasClients && from.hasClients && to.offset != from.offset) to.jumpTo(from.offset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = AppScope.of(context);
    final source = c.defaultSource?.id;
    if (c.catalogVersion != _catalogVersion || c.guideVersion != _guideVersion || source != _source) {
      _catalogVersion = c.catalogVersion;
      _guideVersion = c.guideVersion;
      _source = source;
      _lines.clear();
      _syncPager();
    }
  }

  void _syncPager() {
    final c = AppScope.of(context);
    _pager?.dispose();
    _placed = false;
    _pager = ItemPager(
      c.repository,
      BrowseQuery(
        type: ItemType.live,
        sourceId: c.defaultSource?.id,
        categoryId: _category?.id,
        favoriteList: _list,
        text: _text,
        onlyGuide: true,
      ),
    );
  }

  double _xOf(DateTime t) => t.difference(_day).inSeconds / 60 * _pixelsPerMinute;

  /// Amène le temps présent à l'écran une fois la grille posée.
  void _placeOnNow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_horizontal.hasClients) return;
      final isToday = _day == _midnight(_now);
      final target = isToday ? _xOf(_now) - 30 * _pixelsPerMinute : 19 * 60 * _pixelsPerMinute;
      _horizontal.jumpTo(target.clamp(0, _horizontal.position.maxScrollExtent));
    });
  }

  void _shift(int minutes) {
    if (!_horizontal.hasClients) return;
    final target = (_horizontal.offset + minutes * _pixelsPerMinute).clamp(0.0, _horizontal.position.maxScrollExtent);
    _horizontal.animateTo(target, duration: AppMotion.normal, curve: AppMotion.curve);
  }

  void _selectDay(DateTime day) {
    setState(() {
      _day = day;
      _lines.clear();
    });
    _placeOnNow();
  }

  void _goToNow() {
    final today = _midnight(DateTime.now());
    if (today != _day) {
      _selectDay(today);
    } else {
      _placeOnNow();
    }
  }

  void _setText(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _text = text;
        _syncPager();
      });
    });
  }

  Future<void> _pickScope() async {
    final c = AppScope.of(context);
    final l = context.l10n;
    final categories = await c.repository.categories(ItemType.live, c.defaultSource?.id);
    if (!mounted) return;
    final chosen = await showDialog<(int?, Category?)>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l.guideScope),
        children: [
          SimpleDialogOption(onPressed: () => Navigator.pop(dialogContext, (null, null)), child: Text(l.guideAllChannels)),
          for (final list in c.favoriteLists)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, (list.id, null)),
              child: Row(children: [Icon(favoriteIcon(list.icon), size: 18), const SizedBox(width: AppSpace.s), Expanded(child: Text(list.name))]),
            ),
          const Divider(),
          for (final category in categories)
            SimpleDialogOption(onPressed: () => Navigator.pop(dialogContext, (null, category)), child: Text(category.name)),
        ],
      ),
    );
    if (chosen == null) return;
    setState(() {
      _list = chosen.$1;
      _category = chosen.$2;
      _syncPager();
    });
  }

  String _scopeLabel(AppController c, AppLocalizations l) =>
      _category?.name ?? c.favoriteLists.where((f) => f.id == _list).firstOrNull?.name ?? l.guideAllChannels;

  String _dayLabel(DateTime day, AppLocalizations l) {
    final offset = day.difference(_midnight(_now)).inHours / 24;
    return switch (offset.round()) {
      -1 => l.guideYesterday,
      0 => l.guideToday,
      1 => l.guideTomorrow,
      _ => DateFormat.MMMEd(l.localeName).format(day),
    };
  }

  void _openChannel(int index) {
    final c = AppScope.of(context);
    final pager = _pager!;
    openPlayer(context, CatalogQueue(c.repository, c.sources, pager.query, pager.total ?? 0), index);
  }

  @override
  void dispose() {
    _clock?.cancel();
    _debounce?.cancel();
    _pager?.dispose();
    _horizontal.dispose();
    _names.dispose();
    _rows.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final l = context.l10n;
    final pager = _pager!;
    if (c.epgSources.every((s) => s.programs == 0)) {
      return EmptyState(
        title: l.guideEmptyTitle,
        message: c.guideBusy ? l.guideImporting(c.guideProgress) : l.guideEmptyBody,
        action: FilledButton.icon(
          onPressed: c.guideBusy ? null : c.refreshGuides,
          icon: const Icon(Icons.download),
          label: Text(l.guideImport),
        ),
      );
    }
    final wide = MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;
    final channelWidth = wide ? 200.0 : 72.0;
    final today = _midnight(_now);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.m, AppSpace.s, AppSpace.m, AppSpace.xs),
        child: Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SizedBox(
            width: wide ? 240 : double.infinity,
            child: FieldNavigation(
              child: TextField(
                onChanged: _setText,
                decoration: InputDecoration(isDense: true, hintText: l.searchHint, prefixIcon: const Icon(Icons.search, size: 20)),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pickScope,
            icon: const Icon(Icons.filter_list, size: 18),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(_scopeLabel(c, l), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          IconButton(tooltip: l.guideEarlier, onPressed: () => _shift(-_stepMinutes), icon: const Icon(Icons.chevron_left)),
          OutlinedButton(onPressed: _goToNow, child: Text(l.guideNow)),
          IconButton(tooltip: l.guideLater, onPressed: () => _shift(_stepMinutes), icon: const Icon(Icons.chevron_right)),
        ]),
      ),
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
          children: [
            for (var i = -_daysAround; i <= _daysAround; i++)
              Builder(builder: (context) {
                final day = DateTime(today.year, today.month, today.day + i);
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpace.xs),
                  child: ChoiceChip(label: Text(_dayLabel(day, l)), selected: day == _day, onSelected: (_) => _selectDay(day)),
                );
              }),
          ],
        ),
      ),
      Expanded(
        child: ListenableBuilder(
          listenable: pager,
          builder: (context, _) {
            final total = pager.total;
            if (total == null) return const SizedBox.shrink();
            if (total == 0) return EmptyState(message: l.guideNoChannels);
            if (!_placed) {
              _placed = true;
              _placeOnNow();
            }
            final dayEnd = DateTime(_day.year, _day.month, _day.day + 1);
            final width = _xOf(dayEnd);
            return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: channelWidth,
                child: Column(children: [
                  const SizedBox(height: _headerHeight),
                  Expanded(
                    child: ListView.builder(
                      controller: _names,
                      itemExtent: _rowHeight,
                      itemCount: total,
                      itemBuilder: (context, i) {
                        final item = pager.at(i);
                        if (item == null) return const SizedBox.shrink();
                        return _ChannelCell(item: item, compact: !wide, onTap: () => _openChannel(i));
                      },
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Scrollbar(
                  controller: _horizontal,
                  thumbVisibility: wide,
                  child: SingleChildScrollView(
                    controller: _horizontal,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: Stack(children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          _TimeHeader(day: _day, dayEnd: dayEnd),
                          Expanded(
                            child: ListView.builder(
                              controller: _rows,
                              itemExtent: _rowHeight,
                              itemCount: total,
                              itemBuilder: (context, i) {
                                final item = pager.at(i);
                                if (item == null) return const SizedBox.shrink();
                                return _Timeline(key: ValueKey('${item.id}-$_day-$_guideVersion'), item: item, day: _day, dayEnd: dayEnd, lines: _lines, now: _now, horizontal: _horizontal);
                              },
                            ),
                          ),
                        ]),
                        if (!_now.isBefore(_day) && _now.isBefore(dayEnd))
                          Positioned(
                            left: _xOf(_now),
                            top: 0,
                            bottom: 0,
                            width: 2,
                            child: IgnorePointer(child: ColoredBox(color: AppColors.live)),
                          ),
                      ]),
                    ),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    ]);
  }
}

class _TimeHeader extends StatelessWidget {
  const _TimeHeader({required this.day, required this.dayEnd});

  final DateTime day;
  final DateTime dayEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final format = DateFormat.Hm(context.l10n.localeName);
    final marks = <DateTime>[];
    for (var t = day; t.isBefore(dayEnd); t = t.add(const Duration(minutes: 30))) {
      marks.add(t);
    }
    return SizedBox(
      height: _headerHeight,
      child: Row(children: [
        for (final mark in marks)
          Container(
            width: 30 * _pixelsPerMinute,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: AppSpace.xs),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: palette.line))),
            child: Text(format.format(mark), style: theme.labelSmall?.copyWith(color: palette.textMuted)),
          ),
      ]),
    );
  }
}

class _ChannelCell extends StatelessWidget {
  const _ChannelCell({required this.item, required this.compact, required this.onTap});

  final Item item;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line), right: BorderSide(color: palette.line))),
      child: FocusTile(
        onTap: onTap,
        onLongPress: () => showChannelGuide(context, item),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xs),
          child: compact
              ? Tooltip(message: item.name, child: Center(child: Logo(url: item.logo, name: item.name, width: 56, height: 48)))
              : Row(children: [
                  Logo(url: item.logo, name: item.name, width: 56, height: 48),
                  const SizedBox(width: AppSpace.s),
                  Expanded(child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.labelMedium)),
                ]),
        ),
      ),
    );
  }
}

/// Ligne d'une chaîne : ses programmes de la journée, placés à leur heure.
class _Timeline extends StatefulWidget {
  const _Timeline({super.key, required this.item, required this.day, required this.dayEnd, required this.lines, required this.now, required this.horizontal});

  final Item item;
  final DateTime day;
  final DateTime dayEnd;
  final Map<int, _Line> lines;
  final DateTime now;
  final ScrollController horizontal;

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  _Line? _line;

  @override
  void initState() {
    super.initState();
    _line = widget.lines[widget.item.id];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_line == null) _load();
  }

  Future<void> _load() async {
    final repository = AppScope.of(context).repository;
    final programs = await repository.programs(widget.item.id, widget.day, widget.dayEnd);
    final info = await repository.streamInfo(widget.item.id);
    final line = _Line(programs, info);
    widget.lines[widget.item.id] = line;
    if (mounted) setState(() => _line = line);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final line = _line;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.line))),
      child: line == null
          ? const SizedBox.expand()
          : Stack(children: [
              for (final program in line.programs) _block(program, line.info),
            ]),
    );
  }

  Widget _block(Program program, StreamInfo? info) {
    final dayStart = widget.day.millisecondsSinceEpoch ~/ 1000;
    final dayStop = widget.dayEnd.millisecondsSinceEpoch ~/ 1000;
    final from = max(program.start, dayStart);
    final to = min(program.stop, dayStop);
    final left = (from - dayStart) / 60 * _pixelsPerMinute;
    final width = max((to - from) / 60 * _pixelsPerMinute, 8.0);
    return Positioned(
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: _ProgramBlock(item: widget.item, program: program, info: info, now: widget.now, left: left, width: width, horizontal: widget.horizontal),
    );
  }
}

class _ProgramBlock extends StatelessWidget {
  const _ProgramBlock({
    required this.item,
    required this.program,
    required this.info,
    required this.now,
    required this.left,
    required this.width,
    required this.horizontal,
  });

  final Item item;
  final Program program;
  final StreamInfo? info;
  final DateTime now;
  final double left;
  final double width;
  final ScrollController horizontal;

  /// Largeur gardée pour le titre quand le début du programme a quitté l'écran.
  static const _minTextWidth = 110.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final l = context.l10n;
    final state = programState(program, now);
    final replay = info != null && canReplay(info!, program, now);
    final color = state == ProgramState.past && !replay ? palette.textFaint : palette.text;
    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: state == ProgramState.current ? palette.accent.withValues(alpha: 0.16) : palette.panel,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: FocusTile(
          onTap: () => showProgramSheet(context, item, program, info),
          child: ListenableBuilder(
            listenable: horizontal,
            // Le titre reste à l'écran tant que le programme y est.
            builder: (context, child) {
              final hidden = horizontal.hasClients ? horizontal.offset - left : 0.0;
              final shift = hidden.clamp(0.0, max(0.0, width - _minTextWidth));
              return Padding(padding: EdgeInsets.only(left: AppSpace.s + shift, right: AppSpace.s, top: AppSpace.xs, bottom: AppSpace.xs), child: child);
            },
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(program.title, maxLines: 1, overflow: TextOverflow.clip, softWrap: false, style: theme.labelMedium?.copyWith(color: color)),
              Row(children: [
                if (replay) ...[Icon(Icons.replay, size: 12, color: palette.accent), const SizedBox(width: 3)],
                Expanded(
                  child: Text(
                    programTimes(program, l),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    softWrap: false,
                    style: theme.labelSmall?.copyWith(color: palette.textMuted),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
