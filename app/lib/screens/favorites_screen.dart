import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../player/playback.dart';
import '../player/streams.dart';
import '../theme/tokens.dart';
import '../widgets/favorites_ui.dart';
import '../widgets/logo.dart';
import '../widgets/panel.dart';
import 'player_screen.dart';

/// Les listes de favoris, en onglets, et le contenu de la liste choisie.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int? _selected;
  List<Item>? _items;
  int _loadedVersion = -1;
  int? _loadedList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final c = AppScope.of(context);
    final lists = c.favoriteLists;
    if (_selected == null || !lists.any((l) => l.id == _selected)) _selected = lists.firstOrNull?.id;
    if (_loadedList != _selected || _loadedVersion != c.favoritesVersion + c.catalogVersion) _load(c);
  }

  Future<void> _load(AppController c) async {
    final id = _selected;
    _loadedList = id;
    _loadedVersion = c.favoritesVersion + c.catalogVersion;
    if (id == null) {
      if (mounted) setState(() => _items = const []);
      return;
    }
    final items = await c.repository.favoriteItems(id);
    if (mounted && id == _selected) setState(() => _items = items);
  }

  void _select(int id) {
    setState(() {
      _selected = id;
      _items = null;
    });
    _load(AppScope.of(context));
  }

  Future<void> _reorder(AppController c, int from, int to) async {
    final items = [...?_items];
    final moved = items.removeAt(from);
    items.insert(to, moved);
    setState(() => _items = items);
    await c.reorderItems(_selected!, items.map((i) => i.id).toList());
  }

  void _play(AppController c, int index) => openPlayer(context, _ItemsQueue(c, _items!), index);

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final l = context.l10n;
    final palette = Palette.of(context);
    final lists = c.favoriteLists;
    final items = _items;

    if (lists.isEmpty) {
      return EmptyState(
        title: l.navFavorites,
        message: l.favEmptyLists,
        action: FilledButton.icon(
          autofocus: usesKeyNavigation,
          onPressed: () => showListEditor(context),
          icon: const Icon(Icons.add),
          label: Text(l.favNewList),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 60,
        child: Row(children: [
          Expanded(
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s), children: [
              for (final list in lists)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpace.s),
                  child: ChoiceChip(
                    avatar: Icon(favoriteIcon(list.icon), size: 16),
                    showCheckmark: false,
                    label: Text('${list.name} (${list.itemCount})', maxLines: 1),
                    selected: list.id == _selected,
                    onSelected: (_) => _select(list.id),
                  ),
                ),
            ]),
          ),
          IconButton(tooltip: l.favNewList, icon: Icon(Icons.add, color: palette.textMuted), onPressed: () => showListEditor(context)),
          IconButton(
            tooltip: l.favManage,
            icon: Icon(Icons.edit_outlined, color: palette.textMuted),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => AppScope(controller: c, child: const _ManageLists())),
            ),
          ),
          const SizedBox(width: AppSpace.s),
        ]),
      ),
      Expanded(
        child: items == null
            ? const SizedBox.shrink()
            : items.isEmpty
                ? EmptyState(message: l.favEmptyList)
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    onReorderItem: (from, to) => _reorder(c, from, to),
                    itemBuilder: (context, i) => _FavoriteRow(
                      key: ValueKey(items[i].id),
                      item: items[i],
                      index: i,
                      listId: _selected!,
                      count: items.length,
                      onPlay: () => _play(c, i),
                      onMove: (delta) => _reorder(c, i, i + delta),
                    ),
                  ),
      ),
    ]);
  }
}

class _ItemsQueue implements PlayQueue {
  const _ItemsQueue(this._controller, this._items);

  final AppController _controller;
  final List<Item> _items;

  @override
  int get length => _items.length;

  @override
  Future<PlayItem?> at(int index) => itemToPlay(_items[index], _controller.repository, _controller.sources);
}

class _FavoriteRow extends StatelessWidget {
  const _FavoriteRow({super.key, required this.item, required this.index, required this.listId, required this.count, required this.onPlay, required this.onMove});

  final Item item;
  final int index;
  final int listId;
  final int count;
  final VoidCallback onPlay;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return SizedBox(
      height: 64,
      child: Row(children: [
        Expanded(
          child: FocusTile(
            onTap: onPlay,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.xs),
              child: Row(children: [
                Logo(url: item.logo, name: item.name, width: 72, height: 52),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleMedium),
                    Text(item.categoryName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        // Sans souris ni doigt, le glissé n'existe pas : des flèches font le même travail.
        if (c.isTelevision) ...[
          IconButton(tooltip: l.favMoveUp, icon: const Icon(Icons.arrow_upward), onPressed: index == 0 ? null : () => onMove(-1)),
          IconButton(tooltip: l.favMoveDown, icon: const Icon(Icons.arrow_downward), onPressed: index == count - 1 ? null : () => onMove(1)),
        ],
        IconButton(
          tooltip: l.favRemove,
          icon: Icon(Icons.star, color: palette.accent),
          onPressed: () => c.setInList(listId, item.id, false),
        ),
        if (!c.isTelevision)
          ReorderableDragStartListener(
            index: index,
            child: Padding(padding: const EdgeInsets.all(AppSpace.m), child: Icon(Icons.drag_handle, color: palette.textFaint)),
          ),
      ]),
    );
  }
}

/// Renommer, supprimer et réordonner les listes.
class _ManageLists extends StatelessWidget {
  const _ManageLists();

  Future<void> _delete(BuildContext context, AppController c, FavoriteList list) async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.favDeleteList),
        content: Text(l.favDeleteConfirm(list.name)),
        actions: [
          TextButton(autofocus: true, onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) await c.deleteList(list.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final lists = c.favoriteLists;

    void move(int from, int to) {
      final ids = lists.map((e) => e.id).toList();
      final id = ids.removeAt(from);
      ids.insert(to, id);
      c.reorderLists(ids);
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: palette.tabBar, surfaceTintColor: Colors.transparent, title: Text(l.favManage, style: theme.titleLarge)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.all(AppSpace.m),
            itemCount: lists.length,
            onReorderItem: move,
            itemBuilder: (context, i) {
              final list = lists[i];
              return SizedBox(
                key: ValueKey(list.id),
                height: 60,
                child: Row(children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpace.m), child: Icon(favoriteIcon(list.icon), color: palette.accent)),
                  Expanded(child: Text(l.favListLine(list.name, list.itemCount), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyLarge)),
                  if (c.isTelevision) ...[
                    IconButton(tooltip: l.favMoveUp, icon: const Icon(Icons.arrow_upward), onPressed: i == 0 ? null : () => move(i, i - 1)),
                    IconButton(tooltip: l.favMoveDown, icon: const Icon(Icons.arrow_downward), onPressed: i == lists.length - 1 ? null : () => move(i, i + 1)),
                  ],
                  IconButton(tooltip: l.favRename, icon: const Icon(Icons.edit_outlined), onPressed: () => showListEditor(context, list: list)),
                  IconButton(tooltip: l.favDeleteList, icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, c, list)),
                  if (!c.isTelevision)
                    ReorderableDragStartListener(
                      index: i,
                      child: Padding(padding: const EdgeInsets.all(AppSpace.m), child: Icon(Icons.drag_handle, color: palette.textFaint)),
                    ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
