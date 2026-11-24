import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../filtered/classifier.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import '../widgets/catalog_view.dart';
import '../widgets/panel.dart';
import 'filtered_review_screen.dart';

const treeSetting = 'filtered.tree';
const editsSetting = 'filtered.edits';

/// Groupes du direct, tels que le classement les voit.
Future<(List<GroupRef>, Map<String, Category>)> loadGroups(AppController c) async {
  final categories = await c.repository.categories(ItemType.live, null);
  final dominant = await c.repository.dominantCountries();
  final byKey = {for (final x in categories) x.key: x};
  return (
    [for (final x in categories) GroupRef(key: x.key, name: x.name, itemCount: x.itemCount, dominant: dominant[x.id])],
    byKey,
  );
}

/// Organisation intelligente des chaînes. À côté de « Direct », qui reste celle du fournisseur :
/// rien ici ne modifie les playlists, le classement ne fait que pointer vers leurs groupes.
class FilteredScreen extends StatefulWidget {
  const FilteredScreen({super.key, this.catalogKey});

  final GlobalKey<CatalogViewState>? catalogKey;

  @override
  State<FilteredScreen> createState() => _FilteredScreenState();
}

class _FilteredScreenState extends State<FilteredScreen> {
  FilteredTree? _tree;
  Map<String, Category> _categories = const {};
  bool _loaded = false;
  int _version = -1;
  FilteredNode? _node;
  Category? _group;
  int? _sourceId;
  final _expanded = <String>{};
  int _newGroups = 0;

  /// Liste stable tant que la sélection ne change pas : la vue s'en sert pour éviter de recharger.
  List<int>? _ids;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = AppScope.of(context);
    if (c.catalogVersion != _version) {
      _version = c.catalogVersion;
      _load(c);
    }
  }

  Future<void> _load(AppController c) async {
    final text = await c.repository.loadSetting(treeSetting);
    final (groups, byKey) = await loadGroups(c);
    if (!mounted) return;
    final tree = text == null || text.isEmpty ? null : FilteredTree.fromJson(text);
    setState(() {
      _tree = tree;
      _categories = byKey;
      _loaded = true;
      _newGroups = tree == null ? 0 : groups.where((g) => !tree.analyzed.contains(g.key)).length;
      _node = tree?.nodes.where((n) => n.key == _node?.key).firstOrNull;
      _group = null;
      _resolveIds();
    });
  }

  void _resolveIds() {
    final tree = _tree;
    if (tree == null) return;
    final node = _node;
    final group = _group;
    if (group != null) {
      _ids = [group.id];
      return;
    }
    final keys = node == null ? tree.nodes.expand((n) => n.groups).toSet() : tree.groupsUnder(node.key);
    _ids = [for (final k in keys) if (_categories[k] != null) _categories[k]!.id];
  }

  void _select(FilteredNode? node) => setState(() {
        _node = node;
        _group = null;
        _resolveIds();
      });

  void _selectGroup(Category? group) => setState(() {
        _group = group;
        _resolveIds();
      });

  int _itemsUnder(String key) => _tree!.groupsUnder(key).fold(0, (sum, g) => sum + (_categories[g]?.itemCount ?? 0));

  Future<void> _review({bool restore = false}) async {
    final c = AppScope.of(context);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AppScope(controller: c, child: FilteredReviewScreen(restore: restore))),
    );
    if (saved == true) await _load(c);
  }

  Future<void> _confirmRestore() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.filteredRestore),
        content: Text(l.filteredRestoreConfirm),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l.filteredRestore)),
        ],
      ),
    );
    if (confirmed == true) await _review(restore: true);
  }

  Widget _treeList({ValueChanged<FilteredNode?>? onPick}) {
    final tree = _tree!;
    final l = context.l10n;
    void pick(FilteredNode? node) {
      _select(node);
      onPick?.call(node);
    }

    final rows = <Widget>[
      _TreeRow(label: l.allCategories, depth: 0, selected: _node == null, autofocus: usesKeyNavigation, onTap: () => pick(null)),
    ];
    void add(FilteredNode node, int depth) {
      final children = tree.childrenOf(node.key);
      final open = _expanded.contains(node.key);
      rows.add(_TreeRow(
        label: node.label,
        count: _itemsUnder(node.key),
        depth: depth,
        selected: _node?.key == node.key,
        expandable: children.isNotEmpty,
        expanded: open,
        onTap: () {
          setState(() {
            if (children.isNotEmpty && !open) {
              _expanded.add(node.key);
            } else if (_node?.key == node.key) {
              _expanded.remove(node.key);
            }
          });
          pick(node);
        },
      ));
      if (open) {
        for (final child in children) {
          add(child, depth + 1);
        }
      }
    }

    for (final node in tree.childrenOf(null)) {
      add(node, 0);
    }
    return ListView(children: rows);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final palette = Palette.of(context);
    final theme = Theme.of(context).textTheme;
    if (!_loaded) return const SizedBox.shrink();
    final tree = _tree;

    if (tree == null || _categories.isEmpty) {
      return EmptyState(
        title: 'FILTERED',
        message: _categories.isEmpty ? l.filteredNoGroups : l.filteredIntro,
        action: _categories.isEmpty
            ? null
            : FilledButton.icon(
                autofocus: usesKeyNavigation,
                onPressed: _review,
                icon: const Icon(Icons.auto_awesome),
                label: Text(l.filteredAnalyze),
              ),
      );
    }

    final node = _node;
    final group = _group;
    final groupsHere = node == null ? const <String>[] : tree.groupsUnder(node.key).where(_categories.containsKey).toList();
    final menu = PopupMenuButton<String>(
      tooltip: l.filteredManage,
      icon: Icon(Icons.more_vert, color: palette.textMuted),
      onSelected: (action) {
        if (action == 'restore') {
          _confirmRestore();
        } else {
          _review();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'review', child: Text(l.filteredReanalyze)),
        PopupMenuItem(value: 'restore', child: Text(l.filteredRestore)),
      ],
    );

    final wide = MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;
    final catalog = CatalogView(
      key: widget.catalogKey,
      type: ItemType.live,
      title: group?.name ?? node?.label ?? l.allCategories,
      sourceId: _sourceId,
      categoryIds: _ids,
      onSource: (id) => setState(() => _sourceId = id),
      onCategories: wide ? null : () => _openTreeSheet(context),
      actions: [menu],
    );

    final content = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (_newGroups > 0)
        Material(
          color: palette.panelRaised,
          child: InkWell(
            onTap: _review,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
              child: Row(children: [
                Icon(Icons.auto_awesome, size: 16, color: palette.accent),
                const SizedBox(width: AppSpace.s),
                Expanded(child: Text(l.filteredNewGroups(_newGroups), style: theme.bodySmall)),
              ]),
            ),
          ),
        ),
      if (groupsHere.length > 1)
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpace.s),
                child: Center(child: FilterChip(label: Text(l.allCategories), selected: group == null, onSelected: (_) => _selectGroup(null))),
              ),
              for (final key in groupsHere)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpace.s),
                  child: Center(
                    child: FilterChip(
                      label: Text(_categories[key]!.name, maxLines: 1),
                      selected: group?.key == key,
                      onSelected: (_) => _selectGroup(_categories[key]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      Expanded(child: catalog),
    ]);
    if (!wide) return content;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(width: 280, child: FocusTraversalGroup(child: _treeList())),
      VerticalDivider(width: 1, color: palette.line),
      Expanded(child: FocusTraversalGroup(child: content)),
    ]);
  }

  void _openTreeSheet(BuildContext context) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: StatefulBuilder(
          builder: (context, setSheet) => _treeList(onPick: (node) {
            if (node == null || _tree!.childrenOf(node.key).isEmpty) {
              Navigator.pop(sheetContext);
            } else {
              setSheet(() {});
            }
          }),
        ),
      ),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.label,
    required this.depth,
    required this.selected,
    required this.onTap,
    this.count,
    this.expandable = false,
    this.expanded = false,
    this.autofocus = false,
  });

  final String label;
  final int depth;
  final bool selected;
  final VoidCallback onTap;
  final int? count;
  final bool expandable;
  final bool expanded;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return SizedBox(
      height: 44,
      child: FocusTile(
        onTap: onTap,
        selected: selected,
        autofocus: autofocus,
        child: Padding(
          padding: EdgeInsets.only(left: AppSpace.m + depth * AppSpace.l, right: AppSpace.m),
          child: Row(children: [
            SizedBox(
              width: 20,
              child: expandable ? Icon(expanded ? Icons.expand_more : Icons.chevron_right, size: 18, color: palette.textMuted) : null,
            ),
            const SizedBox(width: AppSpace.xs),
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: depth == 0 ? theme.titleMedium : theme.bodyMedium),
            ),
            if (count != null) Text('$count', style: theme.labelSmall?.copyWith(color: palette.textFaint)),
          ]),
        ),
      ),
    );
  }
}
