import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../import/xtream.dart';
import '../models/format.dart';
import '../models/source.dart';
import '../theme/tokens.dart';
import '../widgets/panel.dart';

/// Ouvre le formulaire d'ajout, ou de modification si [source] est donnée.
Future<void> openSourceForm(BuildContext context, {Source? source}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SourceForm(source: source)));

class SourceForm extends StatefulWidget {
  const SourceForm({super.key, this.source});

  final Source? source;

  @override
  State<SourceForm> createState() => _SourceFormState();
}

class _SourceFormState extends State<SourceForm> {
  final _form = GlobalKey<FormState>();
  late SourceKind _kind = widget.source?.kind ?? SourceKind.xtream;
  late final _name = TextEditingController(text: widget.source?.name);
  late final _url = TextEditingController(text: widget.source?.url);
  late final _username = TextEditingController(text: widget.source?.username);
  late final _password = TextEditingController(text: widget.source?.password);
  late bool _movies = widget.source?.withMovies ?? true;
  late bool _series = widget.source?.withSeries ?? true;
  bool _showPassword = false;
  String? _filePath;
  bool _fileMissing = false;

  bool get _editing => widget.source != null;

  @override
  void initState() {
    super.initState();
    if (_kind == SourceKind.m3uFile) _filePath = widget.source?.url;
    // À la télécommande, il faut un point de départ. Pas de champ : le clavier s'ouvrirait seul.
    if (Platform.isAndroid && usesKeyNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).nextFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _url, _username, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'M3U',
            extensions: ['m3u', 'm3u8', 'txt'],
            mimeTypes: ['audio/x-mpegurl', 'application/x-mpegurl', 'text/plain'],
          ),
        ],
      );
      if (file == null) return;
      setState(() {
        _filePath = file.path;
        _fileMissing = false;
        if (_name.text.isEmpty) _name.text = file.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
      });
    } catch (_) {
      // Android TV n'a pas toujours d'application de fichiers.
      messenger.showSnackBar(SnackBar(content: Text(l.formFileUnavailable)));
    }
  }

  String? _required(String? v) => v == null || v.trim().isEmpty ? context.l10n.formRequired : null;

  String? _validUrl(String? v) {
    final missing = _required(v);
    if (missing != null) return missing;
    final value = _kind == SourceKind.xtream ? normalizeServer(v!) : v!.trim();
    final uri = Uri.tryParse(value);
    final ok = uri != null && uri.host.isNotEmpty && (uri.scheme == 'http' || uri.scheme == 'https');
    return ok ? null : context.l10n.formInvalidUrl;
  }

  String _defaultName() {
    final value = _kind == SourceKind.m3uFile ? (_filePath ?? '') : _url.text;
    final host = Uri.tryParse(value.contains('://') ? value : 'http://$value')?.host ?? '';
    return host.isEmpty ? sourceKindText(_kind, context.l10n) : host;
  }

  Future<void> _save() async {
    final fileChosen = _kind != SourceKind.m3uFile || _filePath != null;
    setState(() => _fileMissing = !fileChosen);
    if (!_form.currentState!.validate() || !fileChosen) return;

    final controller = AppScope.of(context);
    final name = _name.text.trim().isEmpty ? _defaultName() : _name.text.trim();
    final url = switch (_kind) {
      SourceKind.xtream => normalizeServer(_url.text),
      SourceKind.m3uUrl => _url.text.trim(),
      SourceKind.m3uFile => _filePath!,
    };
    final original = widget.source;
    if (original == null) {
      await controller.addSource(
        Source(
          name: name,
          kind: _kind,
          url: url,
          username: _kind == SourceKind.xtream ? _username.text.trim() : '',
          password: _kind == SourceKind.xtream ? _password.text : '',
          withMovies: _movies,
          withSeries: _series,
        ),
      );
    } else {
      final changedContent =
          url != original.url ||
          _username.text.trim() != original.username ||
          _password.text != original.password ||
          (_movies && !original.withMovies) ||
          (_series && !original.withSeries);
      await controller.updateSource(
        original.copyWith(
          name: name,
          url: url,
          username: _username.text.trim(),
          password: _password.text,
          withMovies: _movies,
          withSeries: _series,
        ),
        refreshAfter: changedContent,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context).textTheme;
    final palette = Palette.of(context);
    final original = widget.source;
    final removing = original != null && ((original.withMovies && !_movies) || (original.withSeries && !_series));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.tabBar,
        surfaceTintColor: Colors.transparent,
        title: Text(_editing ? l.formEditTitle : l.formNewTitle, style: theme.titleLarge),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _form,
            child: FieldNavigation(
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.l),
                children: [
                  if (!_editing) ...[
                    SegmentedButton<SourceKind>(
                      segments: [
                        for (final kind in SourceKind.values)
                          ButtonSegment(
                            value: kind,
                            label: Text(sourceKindText(kind, l), maxLines: 2, textAlign: TextAlign.center),
                          ),
                      ],
                      selected: {_kind},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) => setState(() => _kind = s.first),
                    ),
                    const SizedBox(height: AppSpace.l),
                  ],
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l.formName, hintText: l.formNameHint),
                  ),
                  const SizedBox(height: AppSpace.m),
                  if (_kind == SourceKind.xtream) ...[
                    TextFormField(
                      controller: _url,
                      validator: _validUrl,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l.formServer, hintText: 'http://example.com:8080'),
                    ),
                    const SizedBox(height: AppSpace.m),
                    TextFormField(
                      controller: _username,
                      validator: _required,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(labelText: l.formUsername),
                    ),
                    const SizedBox(height: AppSpace.m),
                    TextFormField(
                      controller: _password,
                      validator: _required,
                      obscureText: !_showPassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: InputDecoration(
                        labelText: l.formPassword,
                        suffixIcon: IconButton(
                          tooltip: l.formShowPassword,
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                    ),
                  ],
                  if (_kind == SourceKind.m3uUrl)
                    TextFormField(
                      controller: _url,
                      validator: _validUrl,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      decoration: InputDecoration(labelText: l.formPlaylistUrl, hintText: 'https://…/playlist.m3u8'),
                    ),
                  if (_kind == SourceKind.m3uFile) ...[
                    Text(l.formFile, style: theme.labelLarge),
                    const SizedBox(height: AppSpace.s),
                    Row(
                      children: [
                        OutlinedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.folder_open), label: Text(l.formChooseFile)),
                        const SizedBox(width: AppSpace.m),
                        Expanded(
                          child: Text(
                            _filePath ?? (_fileMissing ? l.formRequired : l.formNoFile),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall?.copyWith(color: _fileMissing ? AppColors.error : null),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpace.l),
                  Panel(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.formContentTitle, style: theme.titleMedium),
                        Text(l.formContentHint, style: theme.bodySmall),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l.formMovies, style: theme.bodyMedium),
                          value: _movies,
                          onChanged: (v) => setState(() => _movies = v),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l.formSeries, style: theme.bodyMedium),
                          value: _series,
                          onChanged: (v) => setState(() => _series = v),
                        ),
                        if (removing)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpace.s),
                            child: Text(l.formContentRemoved, style: theme.bodySmall?.copyWith(color: palette.warning)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  FilledButton(onPressed: _save, child: Text(l.commonSave)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
