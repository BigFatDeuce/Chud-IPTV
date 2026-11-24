import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../app_scope.dart';
import '../models/catalog.dart';
import '../models/format.dart';
import '../models/source.dart';
import '../player/external.dart';
import '../player/playback.dart';
import '../theme/tokens.dart';
import 'download_ui.dart';
import 'guide_ui.dart';
import 'logo.dart';
import 'panel.dart';

/// Icônes proposées pour une liste de favoris. La clé est gardée en base.
const favoriteIcons = <String, IconData>{
  'star': Icons.star,
  'heart': Icons.favorite,
  'sports': Icons.sports_soccer,
  'news': Icons.newspaper,
  'movie': Icons.movie,
  'tv': Icons.live_tv,
  'kids': Icons.child_care,
  'music': Icons.music_note,
  'doc': Icons.public,
  'home': Icons.home,
};

IconData favoriteIcon(String key) => favoriteIcons[key] ?? Icons.star;

/// Étoile d'un élément. Sans liste, on demande où le ranger. Un clic suffit s'il n'y en a qu'une ;
/// sinon on choisit lesquelles.
class FavoriteStar extends StatelessWidget {
  const FavoriteStar({super.key, required this.itemId, this.size = 22, this.focusNode});

  final int itemId;
  final double size;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    final palette = Palette.of(context);
    final active = controller.isFavorite(itemId);
    return IconButton(
      focusNode: focusNode,
      tooltip: active ? l.favRemove : l.favAdd,
      iconSize: size,
      visualDensity: VisualDensity.compact,
      icon: Icon(active ? Icons.star : Icons.star_border, color: active ? palette.accent : palette.textFaint),
      onPressed: () => toggleFavorite(context, itemId),
    );
  }
}

Future<void> toggleFavorite(BuildContext context, int itemId) async {
  final controller = AppScope.of(context);
  final lists = controller.favoriteLists;
  if (lists.isEmpty) {
    await _addFirstFavorite(context, itemId);
    return;
  }
  if (lists.length > 1) {
    await showListPicker(context, itemId);
    return;
  }
  final listId = lists.first.id;
  await controller.setInList(listId, itemId, !controller.isInList(listId, itemId));
}

/// Premier favori : favoris généraux, ou une liste nommée par l'utilisateur.
Future<void> _addFirstFavorite(BuildContext context, int itemId) async {
  final controller = AppScope.of(context);
  final l = context.l10n;
  final create = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.favAdd),
      contentPadding: const EdgeInsets.only(top: AppSpace.m, bottom: AppSpace.s),
      content: SizedBox(
        width: 360,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            child: Text(l.favChooseBody),
          ),
          const SizedBox(height: AppSpace.s),
          ListTile(
            autofocus: true,
            leading: const Icon(Icons.star),
            title: Text(l.favGlobal),
            onTap: () => Navigator.pop(dialogContext, false),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l.favNewList),
            onTap: () => Navigator.pop(dialogContext, true),
          ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.commonCancel))],
    ),
  );
  if (create == null || !context.mounted) return;
  final listId = create ? await showListEditor(context) : await controller.createList(l.favDefaultName, 'star');
  if (listId != null) await controller.setInList(listId, itemId, true);
}

/// Choix des listes d'un élément : il peut être dans plusieurs à la fois.
Future<void> showListPicker(BuildContext context, int itemId) => showDialog<void>(
      context: context,
      builder: (_) => AppScope(controller: AppScope.of(context), child: _ListPicker(itemId: itemId)),
    );

class _ListPicker extends StatelessWidget {
  const _ListPicker({required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.favPickLists),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpace.m),
      content: SizedBox(
        width: 360,
        child: ListView(shrinkWrap: true, children: [
          for (final list in controller.favoriteLists)
            CheckboxListTile(
              secondary: Icon(favoriteIcon(list.icon)),
              title: Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              value: controller.isInList(list.id, itemId),
              onChanged: (v) => controller.setInList(list.id, itemId, v ?? false),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l.favNewList),
            onTap: () async {
              final created = await showListEditor(context);
              if (created != null) await controller.setInList(created, itemId, true);
            },
          ),
        ]),
      ),
      actions: [TextButton(autofocus: true, onPressed: () => Navigator.pop(context), child: Text(l.commonClose))],
    );
  }
}

/// Crée une liste, ou modifie [list]. Renvoie son id.
Future<int?> showListEditor(BuildContext context, {FavoriteList? list}) => showDialog<int>(
      context: context,
      builder: (_) => AppScope(controller: AppScope.of(context), child: _ListEditor(list: list)),
    );

class _ListEditor extends StatefulWidget {
  const _ListEditor({this.list});

  final FavoriteList? list;

  @override
  State<_ListEditor> createState() => _ListEditorState();
}

class _ListEditorState extends State<_ListEditor> {
  late final _name = TextEditingController(text: widget.list?.name);
  late String _icon = widget.list?.icon ?? 'star';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(AppController controller) async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final list = widget.list;
    final int id;
    if (list == null) {
      id = await controller.createList(name, _icon);
    } else {
      await controller.updateList(list.id, name, _icon);
      id = list.id;
    }
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final l = context.l10n;
    final palette = Palette.of(context);
    return AlertDialog(
      title: Text(widget.list == null ? l.favNewList : l.favRename),
      content: SizedBox(
        width: 360,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          FieldNavigation(
            child: TextField(
              controller: _name,
              autofocus: !controller.isTelevision,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(controller),
              decoration: InputDecoration(labelText: l.favListName),
            ),
          ),
          const SizedBox(height: AppSpace.m),
          Text(l.favListIcon, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpace.xs),
          Wrap(children: [
            for (final MapEntry(key: key, value: icon) in favoriteIcons.entries)
              IconButton(
                tooltip: key,
                isSelected: key == _icon,
                icon: Icon(icon, color: key == _icon ? palette.accent : palette.textMuted),
                onPressed: () => setState(() => _icon = key),
              ),
          ]),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        FilledButton(onPressed: () => _save(controller), child: Text(l.commonSave)),
      ],
    );
  }
}

/// Ouvre un flux dans le lecteur externe et prévient si cela n'a pas marché.
Future<void> playExternally(BuildContext context, PlayItem item) async {
  final controller = AppScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final message = context.l10n.externalFailed;
  if (!await openExternally(controller.externalPlayer, item)) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Fiche d'un élément : lecture et listes de favoris.
void showItemSheet(BuildContext context, Item item, {required VoidCallback onPlay, Future<PlayItem?> Function()? resolve}) {
  final controller = AppScope.of(context);
  final l = context.l10n;
  final source = controller.sources.where((Source s) => s.id == item.sourceId).firstOrNull;
  // Une série Xtream n'est pas un fichier : ses épisodes se téléchargent un par un.
  final downloadable = item.type == ItemType.movie || (item.type == ItemType.series && source?.kind != SourceKind.xtream);
  final rows = <(String, String)>[
    if (source != null) (l.itemSource, source.name),
    (l.itemCategory, item.categoryName.isEmpty ? l.noCategoryName : item.categoryName),
    if (item.country.isNotEmpty) (l.itemCountry, item.country),
    if (item.extension.isNotEmpty) (l.itemFormat, item.extension.toUpperCase()),
    if (item.rating != null && item.rating! > 0) (l.itemRating, item.rating!.toStringAsFixed(1)),
  ];
  showAppSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext).textTheme;
      return AppScope(
        controller: controller,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Logo(url: item.logo, name: item.name, width: 96, height: item.type == ItemType.live ? 72 : 144),
            const SizedBox(width: AppSpace.l),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name, style: theme.titleLarge),
                const SizedBox(height: AppSpace.s),
                for (final (label, value) in rows)
                  Padding(padding: const EdgeInsets.only(bottom: 2), child: Text('$label : $value', style: theme.bodySmall)),
                const SizedBox(height: AppSpace.m),
                Wrap(spacing: AppSpace.s, runSpacing: AppSpace.xs, children: [
                  FilledButton.icon(
                    autofocus: true,
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      onPlay();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l.playerPlay),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => toggleFavorite(context, item.id),
                    icon: const Icon(Icons.star_border),
                    label: Text(l.favAdd),
                  ),
                  if (downloadable) _SheetDownload(item: item),
                  if (item.type == ItemType.live && controller.epgSources.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        showChannelGuide(context, item);
                      },
                      icon: const Icon(Icons.calendar_view_day_outlined),
                      label: Text(l.guideChannel),
                    ),
                  if (resolve != null && controller.hasExternalPlayer)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final target = await resolve();
                        if (target != null && sheetContext.mounted) await playExternally(sheetContext, target);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(l.externalOpen),
                    ),
                  TextButton(onPressed: () => Navigator.pop(sheetContext), child: Text(l.commonClose)),
                ]),
              ]),
            ),
          ]),
        ),
      );
    },
  );
}

/// La clé d'un élément se lit en base : le bouton attend de la connaître.
class _SheetDownload extends StatelessWidget {
  const _SheetDownload({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: AppScope.of(context).repository.streamInfo(item.id),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return info == null ? const SizedBox.shrink() : ItemDownloadButton(item: item, streamKey: info.stableKey);
        },
      );
}
