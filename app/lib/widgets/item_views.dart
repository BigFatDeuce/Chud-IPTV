import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/repository.dart';
import '../data/settings.dart';
import '../models/catalog.dart';
import '../theme/tokens.dart';
import 'favorites_ui.dart';
import 'logo.dart';
import 'panel.dart';

const compactRowHeight = 48.0;
const detailedRowHeight = 76.0;

/// Fenêtre glissante sur une liste de taille quelconque : seules les pages regardées sont en mémoire.
class ItemPager extends ChangeNotifier {
  ItemPager(this._repository, this.query) {
    _loadCount();
  }

  static const pageSize = 120;
  static const _maxPages = 24;

  final Repository _repository;
  final BrowseQuery query;

  int? total;
  final _pages = <int, List<Item>>{};
  final _loading = <int>{};
  bool _disposed = false;

  Future<void> _loadCount() async {
    final count = await _repository.count(query);
    if (_disposed) return;
    total = count;
    notifyListeners();
  }

  /// L'élément [index], ou null s'il arrive (la page est alors demandée).
  Item? at(int index) {
    final page = index ~/ pageSize;
    final loaded = _pages.remove(page);
    if (loaded != null) {
      _pages[page] = loaded; // Remis en fin : dernière page utilisée.
      final offset = index % pageSize;
      return offset < loaded.length ? loaded[offset] : null;
    }
    _load(page);
    return null;
  }

  Future<void> _load(int page) async {
    if (!_loading.add(page)) return;
    final items = await _repository.page(query, page * pageSize, pageSize);
    _loading.remove(page);
    if (_disposed) return;
    _pages[page] = items;
    while (_pages.length > _maxPages) {
      _pages.remove(_pages.keys.first);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Liste ou grille virtualisée : seuls les éléments visibles sont construits.
class ItemCollection extends StatelessWidget {
  const ItemCollection({super.key, required this.pager, required this.mode, required this.onOpen, required this.onDetails, this.header});

  final ItemPager pager;
  final ViewMode mode;
  final void Function(Item item, int index) onOpen;

  /// Clic droit ou appui long : la fiche, avec les listes de favoris.
  final void Function(Item item, int index) onDetails;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pager,
      builder: (context, _) {
        final total = pager.total ?? 0;
        final type = pager.query.type;
        final Widget sliver = switch (mode) {
          ViewMode.grid => SliverPadding(
              padding: const EdgeInsets.all(AppSpace.m),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: type == ItemType.live ? 150 : 170,
                  mainAxisSpacing: AppSpace.m,
                  crossAxisSpacing: AppSpace.m,
                  childAspectRatio: type == ItemType.live ? 1 : 0.58,
                ),
                itemCount: total,
                itemBuilder: (context, i) {
                  final item = pager.at(i);
                  return item == null ? const _Skeleton() : _GridCard(item: item, onTap: () => onOpen(item, i), onDetails: () => onDetails(item, i));
                },
              ),
            ),
          ViewMode.compact || ViewMode.detailed => SliverFixedExtentList.builder(
              itemExtent: mode == ViewMode.compact ? compactRowHeight : detailedRowHeight,
              itemCount: total,
              itemBuilder: (context, i) {
                final item = pager.at(i);
                if (item == null) return const _Skeleton();
                return mode == ViewMode.compact
                    ? _CompactRow(item: item, onTap: () => onOpen(item, i), onDetails: () => onDetails(item, i))
                    : _DetailedRow(item: item, onTap: () => onOpen(item, i), onDetails: () => onDetails(item, i));
              },
            ),
        };
        return CustomScrollView(
          slivers: [
            if (header != null) SliverToBoxAdapter(child: header),
            sliver,
          ],
        );
      },
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

class _CompactRow extends StatelessWidget {
  const _CompactRow({required this.item, required this.onTap, required this.onDetails});

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return Row(children: [
      Expanded(
        child: FocusTile(
          onTap: onTap,
          onLongPress: onDetails,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: 6),
            child: Row(children: [
              Logo(url: item.logo, name: item.name, width: 36, height: 36),
              const SizedBox(width: AppSpace.m),
              Expanded(flex: 2, child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyMedium)),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Text(item.nowTitle ?? item.categoryName, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.labelMedium?.copyWith(color: palette.textFaint)),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 2),
      FavoriteStar(itemId: item.id),
      const SizedBox(width: 10),
    ]);
  }
}

class _DetailedRow extends StatelessWidget {
  const _DetailedRow({required this.item, required this.onTap, required this.onDetails});

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    return Row(children: [
      Expanded(
        child: FocusTile(
          onTap: onTap,
          onLongPress: onDetails,
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
        child: Row(children: [
          Logo(url: item.logo, name: item.name, width: 84, height: 60),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleMedium),
              const SizedBox(height: 2),
              Text(
                item.nowTitle ?? [if (item.country.isNotEmpty) item.country, item.categoryName].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.bodySmall?.copyWith(color: palette.textMuted),
              ),
              if (item.nowTitle != null) ...[
                const SizedBox(height: AppSpace.xs),
                SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(minHeight: 3, value: item.nowProgress.clamp(0.0, 1.0), color: palette.accent, backgroundColor: palette.line),
                ),
              ],
            ]),
          ),
        ]),
          ),
        ),
      ),
      const SizedBox(width: 2),
      FavoriteStar(itemId: item.id),
      const SizedBox(width: 10),
    ]);
  }
}

class _GridCard extends StatefulWidget {
  const _GridCard({required this.item, required this.onTap, required this.onDetails});

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  @override
  State<_GridCard> createState() => _GridCardState();
}

/// À la télécommande, l'étoile posée en haut de la case serait atteinte avant la case elle-même en
/// descendant. Elle sort donc du parcours : on l'atteint par la droite, depuis sa case seulement.
class _GridCardState extends State<_GridCard> {
  final _card = FocusNode();
  final _star = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _card.dispose();
    _star.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (_card.hasPrimaryFocus && key == LogicalKeyboardKey.arrowRight) {
      _star.requestFocus();
      return KeyEventResult.handled;
    }
    if (!_star.hasPrimaryFocus) return KeyEventResult.ignored;
    _card.requestFocus();
    // À gauche, on revient sur la case ; ailleurs, la flèche continue depuis la case.
    return key == LogicalKeyboardKey.arrowLeft ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final poster = item.type != ItemType.live;
    final theme = Theme.of(context).textTheme;
    return Panel(
      padding: EdgeInsets.zero,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: Stack(fit: StackFit.expand, children: [
        FocusTile(
        focusNode: _card,
        onTap: widget.onTap,
        onLongPress: widget.onDetails,
        child: LayoutBuilder(builder: (context, c) {
          const textHeight = 44.0;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: Logo(
                url: item.logo,
                name: item.name,
                width: c.maxWidth,
                height: c.maxHeight - textHeight,
                fit: poster ? BoxFit.cover : BoxFit.contain,
              ),
            ),
            SizedBox(
              height: textHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.s, vertical: AppSpace.xs),
                child: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.labelMedium),
              ),
            ),
          ]);
        }),
      ),
        Align(alignment: Alignment.topRight, child: FavoriteStar(itemId: item.id, size: 20, focusNode: _star)),
      ]),
      ),
    );
  }
}
