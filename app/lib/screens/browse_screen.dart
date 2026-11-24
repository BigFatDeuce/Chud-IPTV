import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../import/text.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import '../widgets/catalog_view.dart';
import '../widgets/panel.dart';
import 'source_form.dart';

/// Catalogue d'un type de contenu tel que le fournisseur l'organise : catégories d'un côté
/// (ou dans un panneau sur téléphone), liste de l'autre.
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key, required this.type, this.catalogKey});

  final ItemType type;
  final GlobalKey<CatalogViewState>? catalogKey;

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

/// Choix de source de l'utilisateur ; tant qu'il n'y en a pas, la source par défaut.
const _untouched = -1;

class _BrowseScreenState extends State<BrowseScreen> {
  int? _sourceChoice = _untouched;
  Category? _category;
  List<Category> _categories = const [];
  int _version = -1;
  int? _loadedSource = _untouched;
  bool _loaded = false;
  AppController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppScope.of(context);
    _controller = controller;
    final source = _source(controller);
    if (controller.catalogVersion != _version || source != _loadedSource) {
      _version = controller.catalogVersion;
      _loadedSource = source;
      _reload(controller, source);
    }
  }

  int? _source(AppController c) {
    if (_sourceChoice != _untouched) {
      final stillThere = _sourceChoice == null || c.sources.any((s) => s.id == _sourceChoice && s.enabled);
      if (stillThere) return _sourceChoice;
    }
    return c.defaultSource?.id;
  }

  Future<void> _reload(AppController c, int? source) async {
    final categories = await c.repository.categories(widget.type, source);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _category = categories.where((x) => x.id == _category?.id).firstOrNull;
      _loaded = true;
    });
  }

  void _selectSource(int? source) {
    setState(() {
      _sourceChoice = source;
      _category = null;
      _loadedSource = source;
    });
    _reload(_controller!, source);
  }

  /// Pendant une recherche : les groupes dont le nom correspond, pour y aller d'un clic.
  List<CatalogChip> _matchingGroups(String text) {
    final query = normalizeText(text);
    if (query.length < 2) return const [];
    return [
      for (final c in _categories.where((c) => normalizeText(c.name).contains(query)).take(12))
        CatalogChip(c.name, () => setState(() => _category = c), selected: c.id == _category?.id),
    ];
  }

  void _openCategorySheet(BuildContext context) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: CategoryList(
          categories: _categories,
          selected: _category,
          onSelect: (category) {
            Navigator.pop(sheetContext);
            setState(() => _category = category);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;

    if (controller.sources.isEmpty) {
      return EmptyState(
        title: l.welcomeTitle,
        message: l.welcomeBody,
        action: FilledButton.icon(
          autofocus: usesKeyNavigation,
          onPressed: () => openSourceForm(context),
          icon: const Icon(Icons.add),
          label: Text(l.addSource),
        ),
      );
    }
    if (!_loaded) return const SizedBox.shrink();

    final wide = MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;
    final category = _category;
    final catalog = CatalogView(
      key: widget.catalogKey,
      type: widget.type,
      title: category == null ? l.allCategories : (category.name.isEmpty ? l.noCategoryName : category.name),
      sourceId: _source(controller),
      categoryId: category?.id,
      onSource: _selectSource,
      onCategories: wide ? null : () => _openCategorySheet(context),
      chipsFor: _matchingGroups,
    );
    if (!wide) return catalog;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        width: 280,
        child: FocusTraversalGroup(
          child: CategoryList(
            categories: _categories,
            selected: category,
            autofocus: usesKeyNavigation,
            onSelect: (c) => setState(() => _category = c),
          ),
        ),
      ),
      VerticalDivider(width: 1, color: Palette.of(context).line),
      Expanded(child: FocusTraversalGroup(child: catalog)),
    ]);
  }
}

/// Catégories d'une source, avec un filtre : certains fournisseurs en ont plusieurs centaines.
/// Le champ n'apparaît qu'à la demande, sinon le clavier virtuel surgirait dès que la
/// télécommande passe dessus.
class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.categories, required this.selected, required this.onSelect, this.autofocus = false});

  final List<Category> categories;
  final Category? selected;
  final ValueChanged<Category?> onSelect;
  final bool autofocus;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  String _filter = '';
  bool _filtering = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final query = normalizeText(_filter);
    final shown = query.isEmpty
        ? widget.categories
        : widget.categories.where((c) => normalizeText(c.name).contains(query)).toList();
    return Column(children: [
      if (_filtering)
        Padding(
          padding: const EdgeInsets.all(AppSpace.s),
          child: FieldNavigation(
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _filter = v),
              decoration: InputDecoration(
                isDense: true,
                hintText: l.filterCategories,
                prefixIcon: const Icon(Icons.filter_list, size: 18),
                suffixIcon: IconButton(
                  tooltip: l.commonClose,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                    _filtering = false;
                    _filter = '';
                  }),
                ),
              ),
            ),
          ),
        )
      else
        SizedBox(
          height: 44,
          child: FocusTile(
            onTap: () => setState(() => _filtering = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
              child: Row(children: [
                const Icon(Icons.filter_list, size: 18),
                const SizedBox(width: AppSpace.s),
                Expanded(child: Text(l.filterCategories, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)),
              ]),
            ),
          ),
        ),
      Expanded(
        child: ListView.builder(
          itemExtent: 44,
          itemCount: shown.length + (query.isEmpty ? 1 : 0),
          itemBuilder: (context, i) {
            if (query.isEmpty && i == 0) {
              return _CategoryRow(
                name: l.allCategories,
                selected: widget.selected == null,
                autofocus: widget.autofocus,
                onTap: () => widget.onSelect(null),
              );
            }
            final category = shown[query.isEmpty ? i - 1 : i];
            return _CategoryRow(
              name: category.name.isEmpty ? l.noCategoryName : category.name,
              count: category.itemCount,
              selected: widget.selected?.id == category.id,
              onTap: () => widget.onSelect(category),
            );
          },
        ),
      ),
    ]);
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.name, this.count, required this.selected, required this.onTap, this.autofocus = false});

  final String name;
  final int? count;
  final bool selected;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return FocusTile(
      onTap: onTap,
      selected: selected,
      autofocus: autofocus,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
        child: Row(children: [
          Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyMedium)),
          if (count != null) Text('$count', style: theme.labelSmall?.copyWith(color: palette.textFaint)),
        ]),
      ),
    );
  }
}
