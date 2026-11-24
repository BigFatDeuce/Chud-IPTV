import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../filtered/classifier.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import '../widgets/panel.dart';
import 'filtered_screen.dart';

/// Aperçu du classement : ce que l'analyse propose, ce qui reste à vérifier, et les corrections.
/// Rien n'est enregistré avant « Valider ».
class FilteredReviewScreen extends StatefulWidget {
  const FilteredReviewScreen({super.key, this.restore = false});

  /// Repart du classement automatique, sans les corrections enregistrées.
  final bool restore;

  @override
  State<FilteredReviewScreen> createState() => _FilteredReviewScreenState();
}

class _FilteredReviewScreenState extends State<FilteredReviewScreen> {
  List<GroupRef>? _groups;
  FilteredEdits _edits = FilteredEdits();
  FilteredTree? _tree;
  Set<String> _previous = const {};
  final _open = <String>{};
  var _customCounter = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_groups == null) _load();
  }

  Future<void> _load() async {
    final c = AppScope.of(context);
    final (groups, _) = await loadGroups(c);
    final editsText = widget.restore ? null : await c.repository.loadSetting(editsSetting);
    final treeText = await c.repository.loadSetting(treeSetting);
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _edits = FilteredEdits.fromJson(editsText);
      _previous = treeText == null || treeText.isEmpty ? const {} : FilteredTree.fromJson(treeText).analyzed;
      _rebuild();
    });
  }

  void _rebuild() => _tree = buildTree(_groups!, _edits);

  void _edit(VoidCallback change) => setState(() {
        change();
        _rebuild();
      });

  GroupRef _group(String key) => _groups!.firstWhere((g) => g.key == key);

  List<String> _placements(String group) => [for (final n in _tree!.nodes) if (n.groups.contains(group)) n.key];

  String _labelOf(String key) => _tree!.nodes.where((n) => n.key == key).firstOrNull?.label ?? key;

  Future<void> _save() async {
    final c = AppScope.of(context);
    await c.repository.saveSetting(editsSetting, _edits.toJson());
    await c.repository.saveSetting(treeSetting, _tree!.toJson());
    if (mounted) Navigator.pop(context, true);
  }

  /// Valide la place proposée : le groupe ne sera plus signalé.
  void _accept(String group) => _edit(() => _edits.assigned[group] = _placements(group));

  Future<String?> _askName(String title, {String? initial}) {
    final field = TextEditingController(text: initial);
    final l = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: FieldNavigation(
          child: TextField(
            controller: field,
            autofocus: true,
            onSubmitted: (v) => Navigator.pop(dialogContext, v),
            decoration: InputDecoration(labelText: l.formName),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, field.text), child: Text(l.commonSave)),
        ],
      ),
    );
  }

  Future<String?> _newCategory({String? parent}) async {
    final name = await _askName(context.l10n.filteredNewCategory);
    if (name == null || name.trim().isEmpty) return null;
    final key = 'custom:${DateTime.now().millisecondsSinceEpoch}-${_customCounter++}';
    _edit(() => _edits.custom[key] = CustomNode(name.trim(), parent));
    return key;
  }

  /// Ranger un groupe : dans une ou plusieurs catégories, à la place du classement automatique.
  Future<void> _move(String group) async {
    final current = _placements(group).toSet();
    final chosen = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _NodePicker(
        title: context.l10n.filteredMove,
        nodes: _tree!.nodes,
        selected: current,
        multiple: true,
        onNew: () => _newCategory(),
      ),
    );
    if (chosen != null) _edit(() => _edits.assigned[group] = chosen.toList());
  }

  Future<void> _merge(FilteredNode node) async {
    final chosen = await showDialog<Set<String>>(
      context: context,
      builder: (_) => _NodePicker(
        title: context.l10n.filteredMerge,
        nodes: _tree!.nodes.where((n) => n.key != node.key).toList(),
        selected: const {},
        multiple: false,
      ),
    );
    if (chosen == null || chosen.isEmpty) return;
    _edit(() => _edits.merged[node.key] = chosen.first);
  }

  Future<void> _rename(FilteredNode node) async {
    final name = await _askName(context.l10n.filteredRename, initial: node.label);
    if (name == null || name.trim().isEmpty) return;
    _edit(() => _edits.renamed[node.key] = name.trim());
  }

  /// À la télécommande, le premier bouton de la page reçoit le focus : il faut un point de départ.
  bool _startPending = false;

  bool _takeStart() {
    final start = _startPending;
    _startPending = false;
    return start;
  }

  Widget _groupRow(String key, {bool check = false}) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final group = _group(key);
    final places = _placements(key).map(_labelOf).join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(group.name.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyMedium),
            if (places.isNotEmpty) Text(places, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodySmall),
          ]),
        ),
        if (check) IconButton(autofocus: _takeStart(), tooltip: l.filteredAccept, icon: const Icon(Icons.check), onPressed: () => _accept(key)),
        IconButton(autofocus: _takeStart(), tooltip: l.filteredMove, icon: const Icon(Icons.drive_file_move_outline), onPressed: () => _move(key)),
        IconButton(tooltip: l.filteredExclude, icon: const Icon(Icons.block), onPressed: () => _edit(() => _edits.excluded.add(key))),
      ]),
    );
  }

  Widget _nodePanel(FilteredNode node, int depth) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final tree = _tree!;
    final open = _open.contains(node.key);
    final count = tree.groupsUnder(node.key).length;
    return Padding(
      padding: EdgeInsets.only(left: depth * AppSpace.l),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: FocusTile(
              autofocus: _takeStart(),
              onTap: () => setState(() => open ? _open.remove(node.key) : _open.add(node.key)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.s, horizontal: AppSpace.xs),
                child: Row(children: [
                  Icon(open ? Icons.expand_more : Icons.chevron_right, size: 18, color: palette.textMuted),
                  const SizedBox(width: AppSpace.xs),
                  Expanded(child: Text(node.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.titleMedium)),
                  Text(l.filteredGroupsCount(count), style: theme.labelSmall?.copyWith(color: palette.textFaint)),
                ]),
              ),
            ),
          ),
          IconButton(tooltip: l.filteredRename, icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _rename(node)),
          IconButton(tooltip: l.filteredMerge, icon: const Icon(Icons.call_merge, size: 18), onPressed: () => _merge(node)),
        ]),
        if (open) ...[
          for (final child in tree.childrenOf(node.key)) _nodePanel(child, 1),
          for (final g in node.groups) Padding(padding: const EdgeInsets.only(left: AppSpace.xl), child: _groupRow(g)),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final tree = _tree;
    final groups = _groups;

    // À la télécommande, un bouton flottant posé sur la liste n'est jamais atteint : « Valider » passe
    // dans la barre du haut, au-dessus de la liste.
    final keys = usesKeyNavigation;
    _startPending = keys;
    Widget body;
    if (tree == null || groups == null) {
      body = Center(child: CircularProgressIndicator(color: palette.accent));
    } else {
      final classified = tree.nodes.expand((n) => n.groups).toSet().length;
      final added = _previous.isEmpty ? 0 : tree.analyzed.difference(_previous).length;
      final removed = _previous.isEmpty ? 0 : _previous.difference(tree.analyzed).length;
      body = ListView(padding: const EdgeInsets.all(AppSpace.l), children: [
        Text(l.filteredSummary(classified, tree.nodes.length), style: theme.titleMedium),
        if (added > 0 || removed > 0) Text(l.filteredDelta(added, removed), style: theme.bodySmall),
        const SizedBox(height: AppSpace.m),
        if (tree.uncertain.isNotEmpty) ...[
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l.filteredToCheck(tree.uncertain.length), style: theme.titleMedium),
              const SizedBox(height: AppSpace.xs),
              for (final g in tree.uncertain) _groupRow(g, check: true),
            ]),
          ),
          const SizedBox(height: AppSpace.m),
        ],
        if (tree.unclassified.isNotEmpty) ...[
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l.filteredUnclassified(tree.unclassified.length), style: theme.titleMedium),
              const SizedBox(height: AppSpace.xs),
              for (final g in tree.unclassified) _groupRow(g),
            ]),
          ),
          const SizedBox(height: AppSpace.m),
        ],
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final node in tree.childrenOf(null)) _nodePanel(node, 0),
          ]),
        ),
        if (_edits.excluded.isNotEmpty) ...[
          const SizedBox(height: AppSpace.m),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(l.filteredExcluded(_edits.excluded.length), style: theme.titleMedium),
              for (final key in _edits.excluded.toList())
                Row(children: [
                  Expanded(child: Text(groups.where((g) => g.key == key).firstOrNull?.name.trim() ?? key, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.bodyMedium)),
                  TextButton(onPressed: () => _edit(() => _edits.excluded.remove(key)), child: Text(l.filteredRestoreGroup)),
                ]),
            ]),
          ),
        ],
        const SizedBox(height: 72),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.tabBar,
        surfaceTintColor: Colors.transparent,
        title: Text(l.filteredPreviewTitle, style: theme.titleLarge),
        actions: [
          IconButton(tooltip: l.filteredNewCategory, icon: const Icon(Icons.create_new_folder_outlined), onPressed: tree == null ? null : _newCategory),
          if (keys && tree != null) ...[
            const SizedBox(width: AppSpace.s),
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: Text(l.filteredValidate)),
          ],
          const SizedBox(width: AppSpace.s),
        ],
      ),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 820), child: body)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: tree == null || keys
          ? null
          : FloatingActionButton.extended(
              backgroundColor: palette.accent,
              foregroundColor: palette.onAccent,
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(l.filteredValidate),
            ),
    );
  }
}

/// Choix d'une ou plusieurs catégories.
class _NodePicker extends StatefulWidget {
  const _NodePicker({required this.title, required this.nodes, required this.selected, required this.multiple, this.onNew});

  final String title;
  final List<FilteredNode> nodes;
  final Set<String> selected;
  final bool multiple;
  final Future<String?> Function()? onNew;

  @override
  State<_NodePicker> createState() => _NodePickerState();
}

class _NodePickerState extends State<_NodePicker> {
  late final _chosen = {...widget.selected};
  final _labels = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final parents = {for (final n in widget.nodes) n.key: n};
    // À la télécommande, la première ligne est ciblée d'office : sans point de départ, rien ne montre où l'on est.
    var start = usesKeyNavigation;
    bool takeStart() {
      final first = start;
      start = false;
      return first;
    }

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpace.m),
      content: SizedBox(
        width: 400,
        height: 460,
        child: ListView(children: [
          if (widget.onNew != null)
            ListTile(
              autofocus: takeStart(),
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l.filteredNewCategory),
              onTap: () async {
                final key = await widget.onNew!();
                if (key != null) setState(() => _chosen.add(key));
              },
            ),
          for (final key in _chosen.where((k) => !parents.containsKey(k)))
            CheckboxListTile(
              value: true,
              title: Text(_labels[key] ?? l.filteredNewCategory),
              onChanged: (_) => setState(() => _chosen.remove(key)),
            ),
          for (final node in widget.nodes)
            widget.multiple
                ? CheckboxListTile(
                    autofocus: takeStart(),
                    dense: true,
                    value: _chosen.contains(node.key),
                    title: Text(node.label, style: theme.bodyMedium),
                    subtitle: node.parent == null ? null : Text(parents[node.parent]?.label ?? '', style: theme.bodySmall),
                    onChanged: (v) => setState(() => v == true ? _chosen.add(node.key) : _chosen.remove(node.key)),
                  )
                : ListTile(
                    autofocus: takeStart(),
                    dense: true,
                    title: Text(node.label, style: theme.bodyMedium),
                    subtitle: node.parent == null ? null : Text(parents[node.parent]?.label ?? '', style: theme.bodySmall),
                    onTap: () => Navigator.pop(context, {node.key}),
                  ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.commonCancel)),
        if (widget.multiple) FilledButton(onPressed: () => Navigator.pop(context, _chosen), child: Text(l.commonSave)),
      ],
    );
  }
}
