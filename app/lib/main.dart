import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

import 'app_controller.dart';
import 'app_scope.dart';
import 'data/repository.dart';
import 'epg/epg_import.dart';
import 'l10n/app_localizations.dart';
import 'models/catalog.dart';
import 'models/format.dart';
import 'player/phone_playback.dart';
import 'screens/browse_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/filtered_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sources_screen.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'updates/updater.dart';
import 'widgets/app_shell.dart';
import 'widgets/catalog_view.dart';
import 'widgets/logo.dart';

/// Compilation d'essai (`--dart-define=CHUD_DATA_DIR=...`) : données à part, pour ne jamais
/// toucher à celles de l'app installée sur la machine.
const testDataDir = String.fromEnvironment('CHUD_DATA_DIR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final television = Platform.isAndroid && await const MethodChannel('chud_iptv/device').invokeMethod<bool>('isTelevision') == true;
  // Sur Android, une télécommande laisse Flutter en mode tactile, où le focus reste invisible.
  if (television) FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  final support = testDataDir.isEmpty ? await getApplicationSupportDirectory() : Directory(testDataDir);
  final cache = testDataDir.isEmpty ? await getApplicationCacheDirectory() : Directory('$testDataDir/cache');
  await support.create(recursive: true);
  await cache.create(recursive: true);
  final dbPath = '${support.path}${Platform.pathSeparator}chud.db';
  final sep = Platform.pathSeparator;
  final String downloadsDir;
  if (testDataDir.isNotEmpty) {
    downloadsDir = '$testDataDir${sep}downloads';
  } else if (Platform.isAndroid) {
    // Dossier propre à l'app : pas d'autorisation à demander, mais il part avec elle à la désinstallation.
    downloadsDir = '${(await getExternalStorageDirectory())?.path ?? support.path}${sep}Downloads';
  } else {
    downloadsDir = '${(await getDownloadsDirectory())?.path ?? support.path}${sep}Chud IPTV';
  }
  final phone = Platform.isAndroid ? await AndroidPhonePlayback.create() : null;
  final controller = AppController(
    repository: await Repository.open(dbPath),
    dbPath: dbPath,
    tempDir: cache.path,
    playlistsDir: '${support.path}${Platform.pathSeparator}playlists',
    isTelevision: television,
    phone: phone,
    scheduled: true,
    downloadsDir: downloadsDir,
  );
  LogoCache.init('${cache.path}${Platform.pathSeparator}logos');
  runApp(ChudApp(controller: controller));
  await controller.start();
}

class ChudApp extends StatelessWidget {
  const ChudApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final s = controller.settings;
        return AppScope(
          controller: controller,
          child: MaterialApp(
            title: 'Chud IPTV',
            debugShowCheckedModeBanner: false,
            themeMode: s.themeMode,
            theme: buildAppTheme(Palette.day),
            darkTheme: buildAppTheme(Palette.night),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: s.language == null || s.language!.isEmpty ? null : Locale(s.language!),
            home: Home(controller: controller),
          ),
        );
      },
    );
  }
}

/// Écran principal. Chaque section garde sa position quand on en change.
class Home extends StatefulWidget {
  const Home({super.key, required this.controller});

  final AppController controller;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AppSection _section = AppSection.live;
  final _visited = <AppSection>{AppSection.live};
  final _catalogs = {
    for (final s in const [AppSection.live, AppSection.filtered, AppSection.movies, AppSection.series]) s: GlobalKey<CatalogViewState>(),
  };

  @override
  void initState() {
    super.initState();
    widget.controller.outcomes.listen(_showOutcome);
    widget.controller.guideReports.listen(_showGuideReport);
    widget.controller.updateResults.listen(_showUpdateResult);
    widget.controller.updater.addListener(_announceUpdate);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    widget.controller.updater.removeListener(_announceUpdate);
    super.dispose();
  }

  /// Raccourcis du PC. Branchés sur le clavier et non sur le focus : ils doivent marcher au
  /// démarrage ou après un clic dans le vide, quand rien n'est ciblé. Inactifs dès qu'un autre
  /// écran (lecteur, formulaire) est par-dessus.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !(ModalRoute.of(context)?.isCurrent ?? false)) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.f5) {
      widget.controller.refreshAll();
      return true;
    }
    if (!HardwareKeyboard.instance.isControlPressed) return false;
    if (key == LogicalKeyboardKey.keyF) {
      _catalogs[_section]?.currentState?.focusSearch();
      return true;
    }
    final index = key.keyId - LogicalKeyboardKey.digit1.keyId;
    final available = _available();
    if (index < 0 || index >= available.length) return false;
    _select(available[index]);
    return true;
  }

  void _showOutcome(ImportOutcome outcome) {
    if (!mounted) return;
    final l = context.l10n;
    final report = outcome.report;
    final failure = outcome.failure;
    final text = report != null
        ? l.reportDone(
            outcome.source.name,
            report.live.added + report.movies.added + report.series.added,
            report.live.updated + report.movies.updated + report.series.updated,
            report.live.missing + report.movies.missing + report.series.missing,
          )
        : importErrorText(failure!.kind, failure.detail, l);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _showUpdateResult((String, bool) result) {
    if (!mounted) return;
    final (version, done) = result;
    final l = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 10),
      content: Text(done ? l.updateDone(version) : l.updateNotApplied(version)),
    ));
  }

  String? _announced;

  /// Une nouvelle version se signale une fois, sans interrompre ce qui est en cours.
  void _announceUpdate() {
    final release = widget.controller.updater.release;
    if (!mounted || release == null || widget.controller.updater.stage != UpdateStage.available || _announced == release.version) return;
    _announced = release.version;
    final l = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l.updateAvailable(release.version)),
      persist: false,
      action: SnackBarAction(label: l.updateSee, onPressed: () => _select(AppSection.settings)),
    ));
  }

  void _showGuideReport(EpgReport report) {
    if (!mounted) return;
    final l = context.l10n;
    final text = report.failed.isEmpty ? l.guideDone(report.programs, report.linked) : l.guideFailed(report.failed.join(', '));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  List<AppSection> _available() => [
        AppSection.live,
        if (widget.controller.sources.isNotEmpty) ...[AppSection.filtered, AppSection.guide],
        AppSection.favorites,
        if (widget.controller.offers(ItemType.movie)) AppSection.movies,
        if (widget.controller.offers(ItemType.series)) AppSection.series,
        if (widget.controller.sources.isNotEmpty || widget.controller.downloads.entries.isNotEmpty) AppSection.downloads,
        AppSection.sources,
        AppSection.settings,
      ];

  void _select(AppSection section) => setState(() {
        _section = section;
        _visited.add(section);
      });

  Widget _page(AppSection section) => switch (section) {
        AppSection.live => BrowseScreen(type: ItemType.live, catalogKey: _catalogs[section]),
        AppSection.filtered => FilteredScreen(catalogKey: _catalogs[section]),
        AppSection.guide => const GuideScreen(),
        AppSection.favorites => const FavoritesScreen(),
        AppSection.movies => BrowseScreen(type: ItemType.movie, catalogKey: _catalogs[section]),
        AppSection.series => BrowseScreen(type: ItemType.series, catalogKey: _catalogs[section]),
        AppSection.downloads => const DownloadsScreen(),
        AppSection.sources => const SourcesScreen(),
        AppSection.settings => const SettingsScreen(),
      };

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final palette = Palette.of(context);
    if (!controller.ready) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: palette.accent)));
    }
    final available = _available();
    // Films et séries désactivés sur toutes les sources : on revient au direct.
    final section = available.contains(_section) ? _section : AppSection.live;
    return PopScope(
      canPop: section == AppSection.live,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(AppSection.live);
      },
      // Le dégradé passe derrière le Scaffold : devant, il cacherait survol et focus, dessinés sur sa surface.
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.background, palette.backgroundDeep],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppShell(
            sections: available,
            selected: section,
            onSelect: _select,
            body: IndexedStack(
              index: available.indexOf(section),
              children: [
                for (final s in available)
                  _visited.contains(s) ? KeyedSubtree(key: ValueKey(s), child: _page(s)) : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
