// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navLive => 'Live';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navMovies => 'Filme';

  @override
  String get navSeries => 'Serien';

  @override
  String get navSources => 'Quellen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navMore => 'Mehr';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get welcomeTitle => 'Willkommen';

  @override
  String get welcomeBody =>
      'Füge eine Quelle hinzu: ein Xtream-Codes-Konto oder eine M3U-Playlist. Die App enthält keine Sender, alles bleibt auf diesem Gerät.';

  @override
  String get addSource => 'Quelle hinzufügen';

  @override
  String get allSources => 'Alle Quellen';

  @override
  String get allCategories => 'Alle';

  @override
  String get noCategoryName => 'Ohne Kategorie';

  @override
  String get filterCategories => 'Kategorien filtern';

  @override
  String get emptyList => 'Hier gibt es nichts anzuzeigen.';

  @override
  String get emptyWhileImporting =>
      'Import läuft, der Katalog erscheint, sobald er bereit ist.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Einträge',
      one: '1 Eintrag',
      zero: 'Keine Einträge',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Kompakte Liste';

  @override
  String get viewDetailed => 'Detailliste';

  @override
  String get viewGrid => 'Raster';

  @override
  String get searchHint => 'Suchen';

  @override
  String noResults(String query) {
    return 'Keine Ergebnisse für „$query“.';
  }

  @override
  String get sortLabel => 'Sortieren';

  @override
  String get sortSource => 'Reihenfolge der Quelle';

  @override
  String get sortNameAsc => 'Name (A → Z)';

  @override
  String get sortNameDesc => 'Name (Z → A)';

  @override
  String get sortRecent => 'Zuletzt hinzugefügt';

  @override
  String get sortRating => 'Am besten bewertet';

  @override
  String get filterLabel => 'Filter';

  @override
  String get filterCountry => 'Land oder Sprache';

  @override
  String get filterAllCountries => 'Alle Länder';

  @override
  String get itemSource => 'Quelle';

  @override
  String get itemCategory => 'Kategorie';

  @override
  String get itemCountry => 'Land oder Sprache';

  @override
  String get itemFormat => 'Format';

  @override
  String get itemRating => 'Bewertung';

  @override
  String get favAdd => 'Zu Favoriten hinzufügen';

  @override
  String get favRemove => 'Aus Favoriten entfernen';

  @override
  String get favPickLists => 'Favoritenlisten';

  @override
  String get favNewList => 'Neue Liste';

  @override
  String get favDefaultName => 'Favoriten';

  @override
  String get favListName => 'Name der Liste';

  @override
  String get favListIcon => 'Symbol';

  @override
  String get favRename => 'Liste bearbeiten';

  @override
  String get favDeleteList => 'Liste löschen';

  @override
  String favDeleteConfirm(String name) {
    return 'Liste „$name“ löschen? Die Sender bleiben im Katalog.';
  }

  @override
  String get favEmptyLists =>
      'Erstelle deine Listen: Sport, Nachrichten, Kinder… Ein Sender kann in mehreren Listen sein.';

  @override
  String get favEmptyList =>
      'Diese Liste ist leer. Füge Sender mit dem Stern hinzu.';

  @override
  String get favManage => 'Listen verwalten';

  @override
  String get favMoveUp => 'Nach oben';

  @override
  String get favMoveDown => 'Nach unten';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED ordnet die Gruppen deiner Quellen automatisch nach Land, Region und Thema. Der Live-Tab und deine Playlists bleiben unverändert.';

  @override
  String get filteredNoGroups =>
      'Noch keine Gruppen zum Analysieren. Aktualisiere eine Quelle.';

  @override
  String get filteredAnalyze => 'Automatisch ordnen';

  @override
  String get filteredManage => 'Ordnung';

  @override
  String get filteredReanalyze => 'Erneut analysieren und korrigieren';

  @override
  String get filteredRestore => 'Automatische Ordnung wiederherstellen';

  @override
  String get filteredRestoreConfirm =>
      'Deine manuellen Korrekturen gehen verloren. Vor dem Bestätigen siehst du die Vorschau.';

  @override
  String get filteredPreviewTitle => 'Vorschau der Ordnung';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString Gruppen in $nodesString Kategorien';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Seit der letzten Analyse: $added neu, $removed entfallen';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count neue Gruppen einzuordnen: Vorschau öffnen';
  }

  @override
  String filteredToCheck(int count) {
    return 'Zu prüfen ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Nicht eingeordnet ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Ausgeschlossene Gruppen ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count Gruppen';
  }

  @override
  String get filteredValidate => 'Diese Ordnung bestätigen';

  @override
  String get filteredAccept => 'Passt';

  @override
  String get filteredMove => 'Einordnen in…';

  @override
  String get filteredExclude => 'Aus der Ordnung ausschließen';

  @override
  String get filteredRestoreGroup => 'Wieder aufnehmen';

  @override
  String get filteredNewCategory => 'Neue Kategorie';

  @override
  String get filteredRename => 'Umbenennen';

  @override
  String get filteredMerge => 'Zusammenführen mit…';

  @override
  String get sourcesTitle => 'IPTV-Quellen';

  @override
  String get refreshAll => 'Alle aktualisieren';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get editSource => 'Bearbeiten';

  @override
  String get deleteSource => 'Quelle löschen';

  @override
  String deleteSourceConfirm(String name) {
    return '„$name“ und den gesamten Katalog von diesem Gerät löschen?';
  }

  @override
  String get sourceEnabled => 'Aktiv';

  @override
  String get makeDefault => 'Als Standard verwenden';

  @override
  String get isDefault => 'Standardquelle';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Online-Playlist';

  @override
  String get kindM3uFile => 'M3U-Datei';

  @override
  String countsLine(int live, int movies, int series) {
    final intl.NumberFormat liveNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String liveString = liveNumberFormat.format(live);
    final intl.NumberFormat moviesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String moviesString = moviesNumberFormat.format(movies);
    final intl.NumberFormat seriesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String seriesString = seriesNumberFormat.format(series);

    return '$liveString Sender · $moviesString Filme · $seriesString Serien';
  }

  @override
  String get neverRefreshed => 'Nie aktualisiert';

  @override
  String refreshedAt(String date) {
    return 'Aktualisiert am $date';
  }

  @override
  String expiresAt(String date) {
    return 'Abonnement gültig bis $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gleichzeitige Streams',
      one: '1 gleichzeitiger Stream',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Trotzdem anwenden';

  @override
  String reportDone(String name, int added, int updated, int missing) {
    final intl.NumberFormat addedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String addedString = addedNumberFormat.format(added);
    final intl.NumberFormat updatedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String updatedString = updatedNumberFormat.format(updated);
    final intl.NumberFormat missingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String missingString = missingNumberFormat.format(missing);

    return '„$name“: $addedString neu, $updatedString geändert, $missingString entfallen.';
  }

  @override
  String get stageConnecting => 'Verbindung zum Server…';

  @override
  String get stageLive => 'Sender werden geladen…';

  @override
  String get stageMovies => 'Filme werden geladen…';

  @override
  String get stageSeries => 'Serien werden geladen…';

  @override
  String get stagePlaylist => 'Playlist wird geladen…';

  @override
  String get stageWriting => 'Katalog wird gespeichert…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Speichern: $countString Einträge…';
  }

  @override
  String get stageQueued => 'Wartet…';

  @override
  String get errorNetwork =>
      'Server nicht erreichbar. Prüfe Adresse und Verbindung.';

  @override
  String get errorTimeout => 'Der Server antwortet zu langsam.';

  @override
  String get errorCredentials =>
      'Benutzername oder Passwort vom Server abgelehnt.';

  @override
  String get errorExpired => 'Dieses Abonnement ist abgelaufen.';

  @override
  String get errorNotFound => 'Adresse auf diesem Server nicht gefunden.';

  @override
  String get errorNotPlaylist => 'Dieser Inhalt ist keine M3U-Playlist.';

  @override
  String get errorInvalidData =>
      'Der Server hat eine unlesbare Antwort gesendet.';

  @override
  String get errorEmpty =>
      'Die Quelle ist leer: Der aktuelle Katalog bleibt erhalten.';

  @override
  String errorSuspicious(String detail) {
    return 'Ungewöhnlich kleine Liste ($detail): Der aktuelle Katalog bleibt erhalten.';
  }

  @override
  String get errorFileMissing => 'Datei nicht gefunden oder nicht lesbar.';

  @override
  String get errorUnknown =>
      'Aktualisierung fehlgeschlagen. Der aktuelle Katalog bleibt erhalten.';

  @override
  String get formNewTitle => 'Neue Quelle';

  @override
  String get formEditTitle => 'Quelle bearbeiten';

  @override
  String get formName => 'Name';

  @override
  String get formNameHint => 'Z. B. Wohnzimmer, Abo 1';

  @override
  String get formServer => 'Serveradresse';

  @override
  String get formUsername => 'Benutzername';

  @override
  String get formPassword => 'Passwort';

  @override
  String get formShowPassword => 'Passwort anzeigen';

  @override
  String get formPlaylistUrl => 'Playlist-Adresse (M3U oder M3U8)';

  @override
  String get formFile => 'Playlist-Datei';

  @override
  String get formChooseFile => 'Datei auswählen';

  @override
  String get formNoFile => 'Keine Datei ausgewählt';

  @override
  String get formFileUnavailable => 'Keine Dateiauswahl auf diesem Gerät.';

  @override
  String get formRequired => 'Pflichtfeld';

  @override
  String get formInvalidUrl => 'Ungültige Adresse';

  @override
  String get formContentTitle => 'Zu importierende Inhalte';

  @override
  String get formContentHint =>
      'Live-TV wird immer importiert. Ohne Filme und Serien lädt es deutlich schneller.';

  @override
  String get formMovies => 'Filme';

  @override
  String get formSeries => 'Serien';

  @override
  String get formContentRemoved =>
      'Bereits importierte Einträge und ihre Favoriten werden von diesem Gerät entfernt.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy =>
      'Kein Konto, keine Telemetrie: Quellen und Daten bleiben auf diesem Gerät.';

  @override
  String get settingsShortcuts =>
      'Strg+F: suchen · F5: alle aktualisieren · Strg+1 bis 9: Tab wechseln';

  @override
  String get playerPlay => 'Abspielen';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPrevious => 'Zurück';

  @override
  String get playerNext => 'Weiter';

  @override
  String get playerRefresh => 'Stream neu laden';

  @override
  String get playerFullscreen => 'Vollbild';

  @override
  String get playerExitFullscreen => 'Vollbild beenden';

  @override
  String get playerMute => 'Stumm';

  @override
  String get playerUnmute => 'Ton an';

  @override
  String get playerLive => 'LIVE';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Verbinde neu… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Signal verloren…';

  @override
  String get playerFailedTitle => 'Wiedergabe nicht möglich';

  @override
  String get playerFailedBody =>
      'Dieser Stream antwortet nicht. Er ist vielleicht offline, oder dein Abo läuft bereits auf einem anderen Gerät.';

  @override
  String get playerEndedTitle => 'Wiedergabe beendet';

  @override
  String get playerBackToList => 'Zurück zur Liste';

  @override
  String get externalTitle => 'Externer Player';

  @override
  String get externalOpen => 'Im externen Player öffnen';

  @override
  String get externalNone =>
      'Kein Player gefunden. VLC wird automatisch verwendet, wenn es installiert ist.';

  @override
  String get externalFailed =>
      'Externer Player konnte nicht gestartet werden. Prüfe den Pfad in den Einstellungen.';

  @override
  String get externalDefault => 'VLC verwenden';

  @override
  String get seriesFailed => 'Episoden konnten nicht geladen werden.';

  @override
  String get seriesEmpty => 'Keine Episoden verfügbar.';

  @override
  String seriesSeason(int number) {
    return 'Staffel $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Episode $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count Min.';
  }

  @override
  String get navGuide => 'TV-Guide';

  @override
  String get guideTitle => 'Programmführer';

  @override
  String get guideScope => 'Angezeigte Sender';

  @override
  String get guideAllChannels => 'Alle Sender';

  @override
  String get guideNow => 'Jetzt';

  @override
  String get guideToday => 'Heute';

  @override
  String get guideYesterday => 'Gestern';

  @override
  String get guideTomorrow => 'Morgen';

  @override
  String get guideEarlier => '2 Std. früher';

  @override
  String get guideLater => '2 Std. später';

  @override
  String get guideEmptyTitle => 'Noch kein Programmführer';

  @override
  String get guideEmptyBody =>
      'Importieren Sie den Programmführer Ihrer Quellen oder fügen Sie in den Einstellungen eine XMLTV-Adresse oder -Datei hinzu.';

  @override
  String get guideImport => 'Programmführer importieren';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Programmführer wird importiert… $countString Sendungen';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Programmführer aktualisiert: $programsString Sendungen, $channelsString Sender zugeordnet.';
  }

  @override
  String guideFailed(String names) {
    return 'Programmführer nicht verfügbar: $names. Der bisherige bleibt erhalten.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString Sendungen · $date';
  }

  @override
  String get guideNeverRefreshed => 'Noch nie aktualisiert';

  @override
  String get guideLastFailed => 'Die letzte Aktualisierung ist fehlgeschlagen.';

  @override
  String get guideRefresh => 'Programmführer aktualisieren';

  @override
  String get guideAddUrl => 'Adresse hinzufügen';

  @override
  String get guideAddFile => 'Datei hinzufügen';

  @override
  String get guideUrlHint => 'Adresse des XMLTV-Programmführers';

  @override
  String get guideWatchLive => 'Live ansehen';

  @override
  String get guideReplay => 'Erneut ansehen';

  @override
  String get guideReplayOff =>
      'Für diese Sendung ist keine Wiederholung verfügbar.';

  @override
  String get guideComing => 'Demnächst';

  @override
  String get guideChannel => 'Senderprogramm';

  @override
  String get guideLink => 'Dem Programmführer zuordnen';

  @override
  String get guideLinkHint => 'Sendername oder Kennung';

  @override
  String get guideNoProgram => 'Keine Sendungen für diesen Sender.';

  @override
  String get guideNoChannels =>
      'Kein Sender dieser Auswahl hat einen Programmführer.';

  @override
  String get backupTitle => 'Sicherung';

  @override
  String get backupExport => 'Sicherung erstellen';

  @override
  String get backupImport => 'Sicherung wiederherstellen';

  @override
  String get backupRestore => 'Wiederherstellen';

  @override
  String get backupSecrets => 'Passwörter einschließen';

  @override
  String get backupSecretsBody =>
      'Die Datei wird dann mit Ihrer Passphrase verschlüsselt. Andernfalls werden Passwörter und vollständige Playlist-Adressen nicht gespeichert.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupPassphraseAgain => 'Passphrase bestätigen';

  @override
  String get backupPassphraseShort => 'Mindestens 8 Zeichen.';

  @override
  String get backupPassphraseMismatch =>
      'Die beiden Passphrasen stimmen nicht überein.';

  @override
  String get backupSaved => 'Sicherung gespeichert.';

  @override
  String get backupFailed => 'Diese Datei konnte nicht geschrieben werden.';

  @override
  String get backupNotOurs => 'Diese Datei ist keine Chud-IPTV-Sicherung.';

  @override
  String get backupTooNew =>
      'Diese Sicherung stammt aus einer neueren App-Version.';

  @override
  String get backupDamaged => 'Diese Sicherung ist beschädigt.';

  @override
  String get backupWrongPassphrase =>
      'Falsche Passphrase oder geänderte Datei.';

  @override
  String get backupConfirmTitle => 'Diese Sicherung wiederherstellen?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Sicherung vom $date. Quellen: $sources, Listen: $lists, Favoriten: $favorites. Ihre aktuellen Daten bleiben erhalten und werden ergänzt; nur die Einstellungen werden ersetzt.';
  }

  @override
  String get backupRestored => 'Wiederherstellung abgeschlossen.';

  @override
  String backupIncomplete(int count) {
    return 'Wiederherstellung abgeschlossen. Zu ergänzende Quellen: $count. Passwort oder Adresse war nicht in der Datei.';
  }

  @override
  String get autoTitle => 'Automatische Aktualisierung';

  @override
  String get autoOff => 'Aus';

  @override
  String autoEvery(int hours) {
    return 'Alle $hours Std.';
  }

  @override
  String get dataTitle => 'Lokale Daten';

  @override
  String cacheLine(String size) {
    return 'Logo-Cache: $size MB';
  }

  @override
  String get cacheClear => 'Cache leeren';

  @override
  String get cacheCleared => 'Cache geleert.';

  @override
  String get wipeButton => 'Alle Daten löschen';

  @override
  String get wipeTitle => 'Alles löschen?';

  @override
  String get wipeBody =>
      'Quellen, Favoriten, Programmführer, Downloads und Einstellungen werden von diesem Gerät entfernt. Das lässt sich nicht rückgängig machen.';

  @override
  String get wipeConfirm => 'Alles löschen';

  @override
  String get updateTitle => 'Updates';

  @override
  String get updateAuto => 'Automatisch prüfen';

  @override
  String get updateCheck => 'Nach Updates suchen';

  @override
  String get updateChecking => 'Wird geprüft…';

  @override
  String get updateLatest => 'Sie haben die neueste Version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version verfügbar';
  }

  @override
  String get updateSee => 'Ansehen';

  @override
  String get updateInstall => 'Aktualisieren';

  @override
  String updateDownloading(int percent) {
    return 'Wird geladen… $percent %';
  }

  @override
  String get updateVerifying => 'Datei wird geprüft…';

  @override
  String get updateRestarting => 'Installation: Die App startet neu.';

  @override
  String get updateConfirmSystem =>
      'Bestätigen Sie die Installation im Systemfenster.';

  @override
  String get updateOpened =>
      'Der Download wurde im Browser geöffnet: Installieren Sie ihn und starten Sie die App neu.';

  @override
  String get updateCancelled => 'Update abgebrochen.';

  @override
  String get updateNoChannel =>
      'Diese Version ist mit keinem Update-Kanal verbunden.';

  @override
  String get updateFailedNetwork => 'Update-Server nicht erreichbar.';

  @override
  String get updateFailedSignature => 'Ungültige Signatur: Update abgelehnt.';

  @override
  String get updateFailedIntegrity =>
      'Beschädigte Datei: Es wurde nichts installiert.';

  @override
  String get updateFailedInstall => 'Die Installation ist fehlgeschlagen.';

  @override
  String updateDone(String version) {
    return 'Update auf Version $version installiert.';
  }

  @override
  String updateNotApplied(String version) {
    return 'Das Update auf Version $version konnte nicht installiert werden: Die bisherige Version bleibt erhalten.';
  }

  @override
  String get navDownloads => 'Downloads';

  @override
  String get downloadAction => 'Herunterladen';

  @override
  String get downloadSeason => 'Staffel herunterladen';

  @override
  String downloadAdded(String title) {
    return 'Zu den Downloads hinzugefügt: $title';
  }

  @override
  String get downloadPlay => 'Datei abspielen';

  @override
  String get downloadEmptyTitle => 'Keine Downloads';

  @override
  String get downloadEmptyBody =>
      'Laden Sie einen Film über seine Seite oder eine Episode über ihre Serie herunter, um sie offline anzusehen.';

  @override
  String get downloadQueued => 'Wartet';

  @override
  String get downloadPaused => 'Pausiert';

  @override
  String get downloadHeld => 'Wartet auf das Ende der Wiedergabe';

  @override
  String get downloadPause => 'Pausieren';

  @override
  String get downloadResume => 'Fortsetzen';

  @override
  String get downloadDeleteTitle => 'Diesen Download löschen?';

  @override
  String downloadDeleteBody(String title) {
    return '$title wird von diesem Gerät entfernt.';
  }

  @override
  String get downloadFolder => 'Download-Ordner';

  @override
  String downloadSizeMb(String size) {
    return '$size MB';
  }

  @override
  String downloadSizeGb(String size) {
    return '$size GB';
  }

  @override
  String get downloadErrorNetwork =>
      'Verbindung verloren. Die Datei bleibt erhalten und wird an derselben Stelle fortgesetzt.';

  @override
  String get downloadErrorServer =>
      'Der Server hat abgelehnt. Vielleicht nutzt eine andere Wiedergabe Ihre Verbindung.';

  @override
  String get downloadErrorFormat =>
      'Dieser Inhalt wird segmentiert gestreamt und kann nicht heruntergeladen werden.';

  @override
  String get downloadErrorDisk =>
      'Schreiben nicht möglich: zu wenig Speicher oder Ordner nicht erreichbar.';

  @override
  String get downloadErrorSource =>
      'Die Quelle dieses Downloads existiert nicht mehr.';

  @override
  String get downloadErrorMissing =>
      'Die Datei wurde verschoben oder gelöscht.';

  @override
  String get downloadFolderChoose => 'Ordner wählen';

  @override
  String get downloadFolderReset => 'Standardordner';

  @override
  String get downloadFolderApp => 'App-Ordner, wird mit der App entfernt';

  @override
  String get downloadFolderHint =>
      'Gilt für künftige Downloads. Fertige bleiben, wo sie sind.';

  @override
  String get favChooseBody =>
      'Sie haben noch keine Liste. Wo möchten Sie diesen Favoriten speichern?';

  @override
  String get favGlobal => 'Allgemeine Favoriten';

  @override
  String get settingsPhoneTitle => 'Wiedergabe auf dem Telefon';

  @override
  String get settingsPip => 'Bild im Bild';

  @override
  String get settingsPipBody =>
      'Das Video läuft in einem kleinen Fenster weiter, wenn Sie die App verlassen. Im Player erscheint eine Schaltfläche.';

  @override
  String get settingsRadio => 'Radiomodus';

  @override
  String get settingsRadioBody =>
      'Der Ton läuft weiter, wenn das Telefon gesperrt oder die App im Hintergrund ist. Im Player erscheint eine Schaltfläche.';

  @override
  String get playerPipOn => 'Bild im Bild an';

  @override
  String get playerPipOff => 'Bild im Bild aus';

  @override
  String get playerRadioOn => 'Radiomodus an';

  @override
  String get playerRadioOff => 'Radiomodus aus';

  @override
  String get radioNotificationStop => 'Stoppen';
}
