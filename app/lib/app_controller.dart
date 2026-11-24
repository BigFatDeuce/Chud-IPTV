import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'backup/backup.dart';
import 'data/repository.dart';
import 'data/settings.dart';
import 'downloads/device_folder.dart';
import 'downloads/download_manager.dart';
import 'downloads/downloader.dart';
import 'epg/epg_import.dart';
import 'import/entry.dart';
import 'import/importer.dart';
import 'import/xtream.dart';
import 'models/catalog.dart';
import 'models/source.dart';
import 'player/external.dart';
import 'player/media_kit_engine.dart';
import 'player/phone_playback.dart';
import 'player/playback.dart';
import 'screens/player_screen.dart';
import 'updates/updater.dart';
import 'widgets/logo.dart';

/// Lance un import ; remplacé dans les tests.
typedef ImportRunner = Future<ImportReport> Function(ImportRequest, void Function(ImportProgress));

/// Lance l'import du guide ; remplacé dans les tests.
typedef GuideRunner = Future<EpgReport> Function(String dbPath, String tempDir, List<EpgJob> jobs, void Function(int) onProgress);

/// Fin d'actualisation signalée à l'écran (message court).
class ImportOutcome {
  const ImportOutcome(this.source, this.report, this.failure);

  final Source source;
  final ImportReport? report;
  final ImportFailure? failure;
}

/// Ce que fait une source en ce moment : rien, attend son tour, ou s'actualise. Une seule source est
/// en cours à la fois ; l'état se lit par `AppController.activityOf`, jamais par ses champs.
enum SourceActivity { idle, queued, importing }

/// État de l'app : sources, réglages et actualisations en cours.
class AppController extends ChangeNotifier {
  AppController({
    required this.repository,
    required this.dbPath,
    required this.tempDir,
    required this.playlistsDir,
    ImportRunner? runner,
    GuideRunner? guideRunner,
    EngineFactory? engineFactory,
    FullscreenSwitch? fullscreenSwitch,
    this.isTelevision = false,
    this.phone,
    this.scheduled = false,
    Updater? updater,
    this.downloadsDir = '',
    DownloadRunner? downloadRunner,
  })  : _runner = runner ?? importInIsolate,
        _guideRunner = guideRunner ?? importEpgInIsolate,
        engineFactory = engineFactory ?? MediaKitEngine.create,
        fullscreenSwitch = fullscreenSwitch ?? nativeFullscreen,
        updater = updater ?? Updater() {
    downloads = DownloadManager(
      repository: repository,
      sourceOf: (id) => sources.where((s) => s.id == id).firstOrNull,
      folder: () => downloadFolder,
      exportFolder: () => isDocument(settings.downloadDir) ? settings.downloadDir : null,
      documents: Platform.isAndroid ? const AndroidDocuments() : null,
      runner: downloadRunner,
    );
  }

  final Repository repository;
  final String dbPath;
  final String tempDir;

  /// Copies des playlists ajoutées depuis un fichier local.
  final String playlistsDir;
  final ImportRunner _runner;
  final GuideRunner _guideRunner;
  final EngineFactory engineFactory;
  final FullscreenSwitch fullscreenSwitch;
  final Updater updater;
  late final DownloadManager downloads;

  /// Dossier des téléchargements par défaut sur cet appareil.
  final String downloadsDir;

  String get downloadFolder {
    if (settings.downloadDir.isNotEmpty && !isDocument(settings.downloadDir)) return settings.downloadDir;
    return downloadsDir.isNotEmpty ? downloadsDir : tempDir;
  }

  /// Android TV : toujours en plein écran, sans tactile.
  final bool isTelevision;

  /// Présent seulement sur un téléphone.
  final PhonePlayback? phone;

  /// Actualisations automatiques actives : pas dans les tests.
  final bool scheduled;

  List<Source> sources = const [];
  Settings settings = const Settings();
  String appVersion = '';
  bool ready = false;

  /// Augmente à chaque changement du catalogue : les listes affichées se rechargent.
  int catalogVersion = 0;

  /// Source en cours d'actualisation et son avancement.
  int? importingId;
  ImportProgress? importProgress;

  List<FavoriteList> favoriteLists = const [];

  /// Pour chaque élément en favori, les listes qui le contiennent.
  Map<int, Set<int>> favoriteMemberships = const {};

  /// Augmente à chaque changement des favoris : la liste affichée se recharge.
  int favoritesVersion = 0;

  /// Sources qui attendent leur tour : les imports passent un par un.
  final queued = <int>[];
  final _forced = <int>{};
  bool _draining = false;

  final _outcomes = StreamController<ImportOutcome>.broadcast();
  Stream<ImportOutcome> get outcomes => _outcomes.stream;

  List<EpgSource> epgSources = const [];
  bool guideBusy = false;

  /// Programmes écrits pendant l'import du guide.
  int guideProgress = 0;

  /// Augmente à chaque changement du guide : la grille se recharge.
  int guideVersion = 0;

  final _guideReports = StreamController<EpgReport>.broadcast();
  Stream<EpgReport> get guideReports => _guideReports.stream;

  Future<void> start() async {
    settings = Settings.fromMap(await repository.settings());
    sources = await repository.sources();
    await _loadFavorites();
    epgSources = await repository.epgSources();
    await downloads.start();
    ready = true;
    notifyListeners();
    updater.onRestart = _restartFor;
    unawaited(_loadVersion());
    unawaited(detectExternalPlayer());
    if (scheduled) {
      _firstCheck = Timer(_startDelay, checkSchedules);
      _schedule = Timer.periodic(_checkEvery, (_) => checkSchedules());
    }
  }

  static const _startDelay = Duration(seconds: 20);
  static const _checkEvery = Duration(minutes: 15);
  Timer? _firstCheck;
  Timer? _schedule;
  DateTime? _guideTriedAt;
  DateTime? _updateCheckedAt;
  static const _updateEveryHours = 24;

  /// Lance ce qui a dépassé son intervalle. Une source en échec attend le prochain : on ne
  /// martèle pas un serveur, et une liste locale n'a rien à relire.
  void checkSchedules() {
    final now = DateTime.now();
    bool due(DateTime? last, int hours) => last == null || now.difference(last).inHours >= hours;
    DateTime? latest(DateTime? a, DateTime? b) => a == null || (b != null && b.isAfter(a)) ? b : a;
    if (settings.sourceHours > 0) {
      for (final s in sources) {
        if (s.enabled && s.kind != SourceKind.m3uFile && !isBusy(s.id) && due(latest(s.refreshedAt, s.errorAt), settings.sourceHours)) refresh(s.id);
      }
    }
    if (settings.autoUpdates && due(_updateCheckedAt, _updateEveryHours)) {
      _updateCheckedAt = now;
      unawaited(updater.check(appVersion, quiet: true));
    }
    if (settings.guideHours > 0 && !guideBusy && !busy && epgSources.isNotEmpty) {
      final oldest = epgSources.map((g) => g.refreshedAt).reduce((a, b) => a == null || b == null ? null : (a.isBefore(b) ? a : b));
      if (due(latest(oldest, _guideTriedAt), settings.guideHours)) {
        _guideTriedAt = now;
        unawaited(refreshGuides());
      }
    }
  }

  Future<void> _loadVersion() async {
    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
      await _checkLastUpdate();
      notifyListeners();
    } catch (_) {
      // Sans version connue, le réglage n'affiche simplement rien.
    }
  }

  static const _expectedVersion = 'update.expected';

  /// Après un redémarrage demandé par une mise à jour : la version réellement lancée dit si elle a
  /// marché. Un remplacement raté ne doit jamais passer pour un succès.
  Future<void> _checkLastUpdate() async {
    final expected = await repository.loadSetting(_expectedVersion);
    if (expected == null || expected.isEmpty) return;
    await repository.saveSetting(_expectedVersion, '');
    _updateResults.add((expected, appVersion == expected));
  }

  final _updateResults = StreamController<(String, bool)>.broadcast(sync: false);

  /// Résultat de la dernière mise à jour : version attendue, réussite.
  Stream<(String, bool)> get updateResults => _updateResults.stream;

  Future<void> _restartFor(String version) async {
    await repository.saveSetting(_expectedVersion, version);
    exit(0);
  }

  Source? get defaultSource => sources.where((s) => s.isDefault && s.enabled).firstOrNull;

  /// Vrai si au moins une source active importe ce type de contenu.
  bool offers(ItemType type) => sources.any((s) {
        if (!s.enabled) return false;
        return switch (type) {
          ItemType.live => true,
          ItemType.movie => s.withMovies,
          ItemType.series => s.withSeries,
        };
      });

  SourceActivity activityOf(int sourceId) {
    if (importingId == sourceId) return SourceActivity.importing;
    return queued.contains(sourceId) ? SourceActivity.queued : SourceActivity.idle;
  }

  bool isBusy(int sourceId) => activityOf(sourceId) != SourceActivity.idle;
  bool get busy => importingId != null || queued.isNotEmpty;

  Future<void> reloadSources() async {
    sources = await repository.sources();
    notifyListeners();
  }

  /// Ajoute une source et lance son premier import. Une source injoignable reste dans la liste
  /// avec son erreur, pour être corrigée sans tout ressaisir.
  Future<void> addSource(Source source) async {
    final id = await repository.addSource(source);
    if (source.kind == SourceKind.m3uFile) await _keepPlaylistCopy(id, source.url);
    await reloadSources();
    refresh(id);
  }

  Future<void> updateSource(Source source, {required bool refreshAfter}) async {
    await repository.updateSource(source);
    if (source.kind == SourceKind.m3uFile) await _keepPlaylistCopy(source.id, source.url);
    await _loadFavorites();
    catalogVersion++;
    await reloadSources();
    if (refreshAfter) refresh(source.id);
  }

  Future<void> deleteSource(Source source) async {
    await repository.deleteSource(source.id);
    await _loadFavorites();
    final copy = File(_copyPath(source.id));
    if (copy.existsSync()) await copy.delete();
    catalogVersion++;
    await reloadSources();
  }

  Future<void> setDefault(Source source) async {
    await repository.setDefaultSource(source.id);
    catalogVersion++;
    await reloadSources();
  }

  Future<void> setEnabled(Source source, bool enabled) async {
    await repository.updateSource(source.copyWith(enabled: enabled));
    catalogVersion++;
    await reloadSources();
  }

  String _copyPath(int id) => '$playlistsDir/$id.m3u';

  Future<void> _keepPlaylistCopy(int id, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    await Directory(playlistsDir).create(recursive: true);
    await file.copy(_copyPath(id));
  }

  /// Met une source dans la file d'actualisation. [force] applique une liste jugée suspecte.
  void refresh(int id, {bool force = false}) {
    if (force) _forced.add(id);
    if (!isBusy(id)) queued.add(id);
    notifyListeners();
    unawaited(_drain());
  }

  void refreshAll() {
    for (final s in sources) {
      if (s.enabled && !isBusy(s.id)) queued.add(s.id);
    }
    notifyListeners();
    unawaited(_drain());
  }

  /// Vide la file, une source à la fois. Quoi qu'il arrive à un import, la source redevient libre et
  /// la suivante a son tour : une file restée « en cours » griserait les sources jusqu'au redémarrage.
  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (queued.isNotEmpty) {
        final id = queued.removeAt(0);
        final force = _forced.remove(id);
        final source = sources.where((s) => s.id == id).firstOrNull;
        if (source == null) continue;
        importingId = id;
        importProgress = null;
        notifyListeners();
        final request = ImportRequest(dbPath: dbPath, tempDir: tempDir, source: source, playlistCopy: _copyPath(id), force: force);
        ImportReport? report;
        ImportFailure? failure;
        try {
          report = await _runner(request, (p) {
            importProgress = p;
            notifyListeners();
          });
        } on ImportFailure catch (e) {
          failure = e;
        } catch (_) {
          // L'import n'a même pas pu démarrer (isolat refusé) : un échec comme un autre.
          failure = const ImportFailure(ImportError.unknown);
        } finally {
          importingId = null;
          importProgress = null;
        }
        if (report != null) catalogVersion++;
        await reloadSources();
        final updated = sources.where((s) => s.id == id).firstOrNull ?? source;
        _outcomes.add(ImportOutcome(updated, report, failure));
        if (report != null) await _afterCatalogImport(updated);
      }
    } finally {
      _draining = false;
      // Une erreur après l'import (base illisible) remonte, mais ne laisse personne dans la file.
      if (queued.isNotEmpty) unawaited(_drain());
    }
  }

  /// Une nouvelle source amène son guide ; sinon, seules les nouvelles chaînes sont à rattacher.
  Future<void> _afterCatalogImport(Source source) async {
    await repository.resolvePending();
    await _loadFavorites();
    await _syncGuideSources();
    final guide = epgSources.where((g) => g.sourceId == source.id).firstOrNull;
    if (guide != null && guide.refreshedAt == null) {
      unawaited(refreshGuides());
    } else if (epgSources.isNotEmpty) {
      await repository.relinkGuide();
    }
  }

  /// Chaque source qui annonce un guide en a une entrée : `xmltv.php` pour Xtream, `url-tvg` pour une playlist.
  Future<void> _syncGuideSources() async {
    for (final source in sources) {
      if (source.kind == SourceKind.xtream || source.epgUrl.isNotEmpty) {
        await repository.addEpgSource(source.name, '', sourceId: source.id);
      }
    }
    epgSources = await repository.epgSources();
    notifyListeners();
  }

  /// Le mot de passe d'un compte n'est jamais recopié : l'adresse se construit au moment de l'import.
  String _guideAddress(EpgSource guide) {
    if (guide.sourceId == null) return guide.url;
    final source = sources.where((s) => s.id == guide.sourceId && s.enabled).firstOrNull;
    if (source == null) return '';
    return source.kind == SourceKind.xtream ? xtreamGuideUrl(source) : source.epgUrl.split(',').first.trim();
  }

  Future<void> refreshGuides() async {
    if (guideBusy) return;
    guideBusy = true;
    guideProgress = 0;
    notifyListeners();
    EpgReport report;
    try {
      await _syncGuideSources();
      final jobs = <EpgJob>[
        for (final guide in epgSources)
          if (guide.path.isNotEmpty || _guideAddress(guide).isNotEmpty) EpgJob(id: guide.id, name: guide.name, url: _guideAddress(guide), path: guide.path),
      ];
      try {
        report = await _guideRunner(dbPath, tempDir, jobs, (count) {
          guideProgress = count;
          notifyListeners();
        });
      } catch (_) {
        // L'import n'a même pas pu démarrer : aucun guide n'a été lu, les anciens restent en place.
        report = EpgReport(failed: [for (final job in jobs) job.name]);
      }
    } finally {
      // Quoi qu'il arrive : un guide resté « en cours » ne pourrait plus jamais être actualisé.
      guideBusy = false;
      notifyListeners();
    }
    await _guideChanged();
    _guideReports.add(report);
  }

  Future<void> _guideChanged() async {
    epgSources = await repository.epgSources();
    guideVersion++;
    catalogVersion++;
    notifyListeners();
  }

  Future<void> addGuideUrl(String url) async {
    await repository.addEpgSource(Uri.parse(url).host, url);
    epgSources = await repository.epgSources();
    await refreshGuides();
  }

  /// Le fichier est recopié : le guide reste lisible si l'original est déplacé.
  Future<void> addGuideFile(String path, String name) async {
    await Directory(playlistsDir).create(recursive: true);
    final copy = '$playlistsDir/guide-${DateTime.now().millisecondsSinceEpoch}.xml';
    await File(path).copy(copy);
    await repository.addEpgSource(name, '', path: copy);
    epgSources = await repository.epgSources();
    await refreshGuides();
  }

  Future<void> deleteGuide(EpgSource guide) async {
    await repository.deleteEpgSource(guide.id);
    if (guide.path.isNotEmpty && File(guide.path).existsSync()) await File(guide.path).delete();
    await repository.relinkGuide();
    await _guideChanged();
  }

  Future<void> linkToGuide(int itemId, String channel) async {
    await repository.linkToGuide(itemId, channel);
    await _guideChanged();
  }

  /// Écrit la sauvegarde à côté de sa destination, puis la met en place : un échec ne laisse
  /// jamais un fichier tronqué à la place d'une ancienne sauvegarde.
  Future<void> exportBackup(String path, {String? passphrase}) async {
    final data = await repository.exportBackup(secrets: passphrase != null);
    final text = await encodeBackup(data, appVersion, passphrase: passphrase);
    final partial = File('$path.part');
    await partial.writeAsString(text, flush: true);
    await partial.rename(path);
  }

  Future<RestoreReport> restoreBackup(Map<String, dynamic> data) async {
    final report = await repository.restoreBackup(data);
    settings = Settings.fromMap(await repository.settings());
    await _reloadEverything();
    report.toRefresh.forEach(refresh);
    return report;
  }

  Future<void> _reloadEverything() async {
    await _loadFavorites();
    sources = await repository.sources();
    epgSources = await repository.epgSources();
    guideVersion++;
    catalogVersion++;
    notifyListeners();
  }

  Future<int> cacheSize() => LogoCache.size();

  Future<void> clearCache() async {
    await LogoCache.clear();
    PaintingBinding.instance.imageCache.clear();
  }

  /// Remet l'app dans son état de premier lancement.
  Future<void> wipeAll() async {
    await downloads.clear();
    await repository.wipe();
    final copies = Directory(playlistsDir);
    if (copies.existsSync()) await copies.delete(recursive: true);
    await clearCache();
    settings = const Settings();
    await _reloadEverything();
  }

  Future<void> _loadFavorites() async {
    favoriteLists = await repository.favoriteLists();
    favoriteMemberships = await repository.favoriteMemberships();
    favoritesVersion++;
  }

  Future<void> _favoritesChanged() async {
    await _loadFavorites();
    notifyListeners();
  }

  bool isFavorite(int itemId) => favoriteMemberships.containsKey(itemId);
  bool isInList(int listId, int itemId) => favoriteMemberships[itemId]?.contains(listId) ?? false;

  Future<int> createList(String name, String icon) async {
    final id = await repository.createFavoriteList(name, icon);
    await _favoritesChanged();
    return id;
  }

  Future<void> updateList(int id, String name, String icon) async {
    await repository.updateFavoriteList(id, name, icon);
    await _favoritesChanged();
  }

  Future<void> deleteList(int id) async {
    await repository.deleteFavoriteList(id);
    await _favoritesChanged();
  }

  Future<void> reorderLists(List<int> ids) async {
    await repository.reorderFavoriteLists(ids);
    await _favoritesChanged();
  }

  Future<void> setInList(int listId, int itemId, bool member) async {
    if (member) {
      await repository.addToFavoriteList(listId, itemId);
    } else {
      await repository.removeFromFavoriteList(listId, itemId);
    }
    await _favoritesChanged();
  }

  Future<void> reorderItems(int listId, List<int> itemIds) async {
    await repository.reorderFavoriteItems(listId, itemIds);
    await _favoritesChanged();
  }

  /// Lecteur externe détecté (VLC), proposé tant que l'utilisateur n'en a pas choisi un.
  String? detectedPlayer;

  /// Le lecteur qui sera utilisé, ou vide s'il n'y en a aucun.
  String get externalPlayer => settings.externalPlayer.isNotEmpty ? settings.externalPlayer : detectedPlayer ?? '';

  bool get hasExternalPlayer => systemChoosesPlayer || externalPlayer.isNotEmpty;

  Future<void> detectExternalPlayer() async {
    try {
      detectedPlayer = await detectVlc();
      notifyListeners();
    } on Exception {
      // Aucun lecteur externe n'est obligatoire.
    }
  }

  void updateSettings(Settings next) {
    settings = next;
    notifyListeners();
    for (final e in next.toMap().entries) {
      unawaited(repository.saveSetting(e.key, e.value));
    }
  }

  void setView(ItemType type, ViewMode mode) => updateSettings(settings.copyWith(views: {...settings.views, type: mode}));

  @override
  void dispose() {
    unawaited(_outcomes.close());
    unawaited(_guideReports.close());
    unawaited(_updateResults.close());
    downloads.dispose();
    _firstCheck?.cancel();
    _schedule?.cancel();
    super.dispose();
  }
}
