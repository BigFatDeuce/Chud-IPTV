import 'dart:async';

import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../data/settings.dart';
import '../filtered/classifier.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../player/streams.dart';
import '../screens/player_screen.dart';
import '../screens/series_screen.dart';
import '../screens/sources_screen.dart';
import '../models/source.dart';
import '../theme/tokens.dart';
import 'favorites_ui.dart';
import 'item_views.dart';
import 'panel.dart';

/// Pastille au-dessus de la liste : un groupe à ouvrir, par exemple.
class CatalogChip {
  const CatalogChip(this.label, this.onTap, {this.selected = false});

  final String label;
  final VoidCallback onTap;
  final bool selected;
}

/// Une liste du catalogue, avec sa recherche, son tri et ses filtres.
///
/// Partagée par le direct, FILTERED, les films et les séries. La saisie, le tri et les filtres
/// vivent ici ; le parent ne décide que du périmètre (groupe, catégorie FILTERED, source).
class CatalogView extends StatefulWidget {
  const CatalogView({
    super.key,
    required this.type,
    required this.title,
    this.sourceId,
    this.categoryId,
    this.categoryIds,
    this.onCategories,
    this.onSource,
    this.chipsFor,
    this.actions = const [],
  });

  final ItemType type;
  final String title;
  final int? sourceId;
  final int? categoryId;
  final List<int>? categoryIds;

  /// Sur téléphone : ouvre la liste des catégories.
  final VoidCallback? onCategories;
  final ValueChanged<int?>? onSource;

  /// Pastilles à montrer pour la saisie en cours.
  final List<CatalogChip> Function(String text)? chipsFor;
  final List<Widget> actions;

  @override
  State<CatalogView> createState() => CatalogViewState();
}

class CatalogViewState extends State<CatalogView> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  String _text = '';
  String _country = '';
  ItemSort _sort = ItemSort.source;
  bool _searchOpen = false;
  ItemPager? _pager;
  BrowseQuery? _query;
  Timer? _debounce;
  int _version = -1;
  AppController? _controller;

  /// Ouvre la recherche et y place le curseur (Ctrl+F).
  void focusSearch() {
    setState(() => _searchOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocus.requestFocus();
      _search.selection = TextSelection(baseOffset: 0, extentOffset: _search.text.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AppScope.of(context);
    _syncPager();
  }

  @override
  void didUpdateWidget(CatalogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPager();
  }

  void _syncPager() {
    final c = _controller!;
    final query = BrowseQuery(
      type: widget.type,
      sourceId: widget.sourceId,
      categoryId: widget.categoryId,
      categoryIds: widget.categoryIds,
      text: _text,
      country: _country,
      sort: _sort,
    );
    final old = _query;
    final same = old != null &&
        old.sourceId == query.sourceId &&
        old.categoryId == query.categoryId &&
        identical(old.categoryIds, query.categoryIds) &&
        old.text == query.text &&
        old.country == query.country &&
        old.sort == query.sort;
    if (same && _version == c.catalogVersion) return;
    _version = c.catalogVersion;
    _query = query;
    _pager?.dispose();
    _pager = ItemPager(c.repository, query);
  }

  void _onText(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _text = value.trim();
        _syncPager();
      });
    });
  }

  void _closeSearch() {
    _debounce?.cancel();
    _search.clear();
    setState(() {
      _searchOpen = false;
      _text = '';
      _syncPager();
    });
  }

  void _setSort(ItemSort sort) => setState(() {
        _sort = sort;
        _syncPager();
      });

  void _setCountry(String country) => setState(() {
        _country = country;
        _syncPager();
      });

  /// Une chaîne se lance aussitôt ; un film passe par sa fiche, une série par ses épisodes.
  void _open(Item item, int index) {
    final c = _controller!;
    final pager = _pager!;
    final queue = CatalogQueue(c.repository, c.sources, pager.query, pager.total ?? 0);
    if (item.type == ItemType.live) {
      openPlayer(context, queue, index);
      return;
    }
    final source = c.sources.where((s) => s.id == item.sourceId).firstOrNull;
    if (item.type == ItemType.series && source?.kind == SourceKind.xtream) {
      _openSeries(item, source!);
      return;
    }
    _sheet(item, queue, index);
  }

  void _sheet(Item item, CatalogQueue queue, int index) => showItemSheet(
        context,
        item,
        onPlay: () => openPlayer(context, queue, index),
        resolve: () => queue.at(index),
      );

  void _details(Item item, int index) {
    final c = _controller!;
    final pager = _pager!;
    _sheet(item, CatalogQueue(c.repository, c.sources, pager.query, pager.total ?? 0), index);
  }

  Future<void> _openSeries(Item item, Source source) async {
    final info = await _controller!.repository.streamInfo(item.id);
    if (info == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => SeriesScreen(item: item, source: source, seriesId: xtreamId(info.stableKey))),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pager?.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    final pager = _pager!;
    final chips = _text.isEmpty ? const <CatalogChip>[] : widget.chipsFor?.call(_text) ?? const <CatalogChip>[];

    final list = ListenableBuilder(
      listenable: pager,
      builder: (context, _) {
        if (pager.total == null) return const SizedBox.shrink();
        if (pager.total == 0) {
          final message = controller.busy
              ? '${l.emptyWhileImporting}\n${stageText(controller.importProgress, l)}'
              : (_text.isNotEmpty ? l.noResults(_text) : l.emptyList);
          return EmptyState(message: message);
        }
        return ItemCollection(pager: pager, mode: controller.settings.views[widget.type]!, onOpen: _open, onDetails: _details);
      },
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _Toolbar(state: this, pager: pager),
      if (chips.isNotEmpty) _ChipRow(chips: chips),
      Expanded(child: list),
    ]);
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.chips});

  final List<CatalogChip> chips;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpace.s),
          itemBuilder: (context, i) => Center(
            child: FilterChip(
              label: Text(chips[i].label, maxLines: 1),
              selected: chips[i].selected,
              onSelected: (_) => chips[i].onTap(),
            ),
          ),
        ),
      );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state, required this.pager});

  final CatalogViewState state;
  final ItemPager pager;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget;
    final controller = AppScope.of(context);
    final l = context.l10n;
    final palette = Palette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final type = widget.type;
    final filtered = state._country.isNotEmpty || widget.sourceId != null && controller.sources.length > 1;

    final field = TextField(
      controller: state._search,
      focusNode: state._searchFocus,
      autofocus: false,
      onChanged: state._onText,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: l.searchHint,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: state._search.text.isEmpty && !state._searchOpen
            ? null
            : IconButton(tooltip: l.commonClose, icon: const Icon(Icons.close, size: 18), onPressed: state._closeSearch),
      ),
    );

    final sortMenu = PopupMenuButton<ItemSort>(
      tooltip: l.sortLabel,
      icon: Icon(Icons.sort, color: state._sort == ItemSort.source ? palette.textMuted : palette.accent),
      initialValue: state._sort,
      onSelected: state._setSort,
      itemBuilder: (_) => [
        for (final sort in ItemSort.values)
          if (sort != ItemSort.rating || type != ItemType.live) PopupMenuItem(value: sort, child: Text(sortLabel(sort, l))),
      ],
    );

    final filterButton = IconButton(
      tooltip: l.filterLabel,
      icon: Badge(isLabelVisible: filtered, smallSize: 8, backgroundColor: palette.accent, child: Icon(Icons.tune, color: palette.textMuted)),
      onPressed: () => showFilterSheet(
        context,
        type: type,
        country: state._country,
        sourceId: widget.sourceId,
        onCountry: state._setCountry,
        onSource: widget.onSource,
      ),
    );

    final mode = controller.settings.views[type]!;
    final views = [
      for (final (viewMode, icon, label) in [
        (ViewMode.compact, Icons.view_headline, l.viewCompact),
        (ViewMode.detailed, Icons.view_list, l.viewDetailed),
        (ViewMode.grid, Icons.grid_view, l.viewGrid),
      ])
        IconButton(
          tooltip: label,
          isSelected: mode == viewMode,
          icon: Icon(icon, color: mode == viewMode ? palette.accent : palette.textMuted),
          onPressed: () => controller.setView(type, viewMode),
        ),
    ];

    final title = _Title(title: widget.title, pager: pager);
    final narrow = width < 640;
    // Téléphone : la recherche prend toute la ligne. TV : elle s'ouvre à la demande,
    // sinon le clavier virtuel surgirait au simple passage de la télécommande.
    if (state._searchOpen && (narrow || controller.isTelevision)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.m, AppSpace.s, AppSpace.m, AppSpace.s),
        child: FieldNavigation(child: field),
      );
    }

    final inlineSearch = !narrow && !controller.isTelevision;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.m, AppSpace.s, AppSpace.s, AppSpace.s),
      child: Row(children: [
        Expanded(
          child: widget.onCategories == null
              ? title
              : InkWell(
                  onTap: widget.onCategories,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                    child: Row(children: [
                      Flexible(child: title),
                      Icon(Icons.expand_more, size: 20, color: palette.textMuted),
                    ]),
                  ),
                ),
        ),
        if (inlineSearch) ...[
          const SizedBox(width: AppSpace.s),
          SizedBox(width: width < 1000 ? 180 : 260, child: FieldNavigation(child: field)),
          const SizedBox(width: AppSpace.xs),
        ] else
          IconButton(tooltip: l.searchHint, icon: Icon(Icons.search, color: palette.textMuted), onPressed: state.focusSearch),
        sortMenu,
        filterButton,
        if (!narrow) ...views,
        if (narrow)
          IconButton(
            tooltip: l.viewGrid,
            icon: Icon(mode == ViewMode.grid ? Icons.view_list : Icons.grid_view, color: palette.textMuted),
            onPressed: () => controller.setView(type, mode == ViewMode.grid ? ViewMode.detailed : ViewMode.grid),
          ),
        ...widget.actions,
      ]),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.pager});

  final String title;
  final ItemPager pager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: pager,
      builder: (context, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleMedium),
        if (pager.total != null) Text(context.l10n.itemCount(pager.total!), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
      ]),
    );
  }
}

/// Filtres par source et par pays. Le pays s'applique à toute la liste, pas seulement à la page visible.
void showFilterSheet(
  BuildContext context, {
  required ItemType type,
  required String country,
  required int? sourceId,
  required ValueChanged<String> onCountry,
  ValueChanged<int?>? onSource,
}) {
  final controller = AppScope.of(context);
  showAppSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => FractionallySizedBox(
      heightFactor: 0.8,
      child: AppScope(
        controller: controller,
        child: _FilterSheet(type: type, country: country, sourceId: sourceId, onCountry: onCountry, onSource: onSource),
      ),
    ),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.type, required this.country, required this.sourceId, required this.onCountry, required this.onSource});

  final ItemType type;
  final String country;
  final int? sourceId;
  final ValueChanged<String> onCountry;
  final ValueChanged<int?>? onSource;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  List<(String, int)>? _countries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_countries != null) return;
    AppScope.of(context).repository.countries(widget.type).then((list) {
      if (mounted) setState(() => _countries = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final sources = controller.sources.where((s) => s.enabled).toList();
    final countries = _countries;

    void pickCountry(String code) {
      Navigator.pop(context);
      widget.onCountry(code);
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpace.l),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(l.filterLabel),
        if (widget.onSource != null && sources.length > 1) ...[
          const SizedBox(height: AppSpace.m),
          Text(l.itemSource, style: theme.titleMedium),
          const SizedBox(height: AppSpace.s),
          Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
            ChoiceChip(
              label: Text(l.allSources),
              selected: widget.sourceId == null,
              onSelected: (_) {
                Navigator.pop(context);
                widget.onSource!(null);
              },
            ),
            for (final s in sources)
              ChoiceChip(
                label: Text(s.name),
                selected: widget.sourceId == s.id,
                onSelected: (_) {
                  Navigator.pop(context);
                  widget.onSource!(s.id);
                },
              ),
          ]),
        ],
        const SizedBox(height: AppSpace.m),
        Text(l.filterCountry, style: theme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        Expanded(
          child: countries == null
              ? Center(child: CircularProgressIndicator(color: palette.accent))
              : ListView.builder(
                  itemExtent: 44,
                  itemCount: countries.length + 1,
                  itemBuilder: (context, i) {
                    final code = i == 0 ? '' : countries[i - 1].$1;
                    return FocusTile(
                      autofocus: i == 0 && usesKeyNavigation,
                      selected: widget.country == code,
                      onTap: () => pickCountry(code),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
                        child: Row(children: [
                          Expanded(child: Text(i == 0 ? l.filterAllCountries : placeLabel(code), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyMedium)),
                          if (i > 0) Text('${countries[i - 1].$2}', style: theme.labelSmall?.copyWith(color: palette.textFaint)),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
