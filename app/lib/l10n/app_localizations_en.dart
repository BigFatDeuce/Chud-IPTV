// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navLive => 'Live';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navMovies => 'Movies';

  @override
  String get navSeries => 'Series';

  @override
  String get navSources => 'Sources';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeBody =>
      'Add a source to get started: an Xtream Codes account or an M3U playlist. The app provides no channels, and everything stays on this device.';

  @override
  String get addSource => 'Add a source';

  @override
  String get allSources => 'All sources';

  @override
  String get allCategories => 'All';

  @override
  String get noCategoryName => 'Uncategorized';

  @override
  String get filterCategories => 'Filter categories';

  @override
  String get emptyList => 'Nothing to show here.';

  @override
  String get emptyWhileImporting =>
      'Import in progress, the catalog will appear as soon as it is ready.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Compact list';

  @override
  String get viewDetailed => 'Detailed list';

  @override
  String get viewGrid => 'Grid';

  @override
  String get searchHint => 'Search';

  @override
  String noResults(String query) {
    return 'No results for “$query”.';
  }

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortSource => 'Source order';

  @override
  String get sortNameAsc => 'Name (A → Z)';

  @override
  String get sortNameDesc => 'Name (Z → A)';

  @override
  String get sortRecent => 'Recently added';

  @override
  String get sortRating => 'Top rated';

  @override
  String get filterLabel => 'Filters';

  @override
  String get filterCountry => 'Country or language';

  @override
  String get filterAllCountries => 'All countries';

  @override
  String get itemSource => 'Source';

  @override
  String get itemCategory => 'Category';

  @override
  String get itemCountry => 'Country or language';

  @override
  String get itemFormat => 'Format';

  @override
  String get itemRating => 'Rating';

  @override
  String get favAdd => 'Add to favorites';

  @override
  String get favRemove => 'Remove from favorites';

  @override
  String get favPickLists => 'Favorite lists';

  @override
  String get favNewList => 'New list';

  @override
  String get favDefaultName => 'Favorites';

  @override
  String get favListName => 'List name';

  @override
  String get favListIcon => 'Icon';

  @override
  String get favRename => 'Edit list';

  @override
  String get favDeleteList => 'Delete list';

  @override
  String favDeleteConfirm(String name) {
    return 'Delete the list “$name”? The channels stay in the catalog.';
  }

  @override
  String get favEmptyLists =>
      'Create your lists: sports, news, kids… The same channel can be in several lists.';

  @override
  String get favEmptyList => 'This list is empty. Add channels with the star.';

  @override
  String get favManage => 'Manage lists';

  @override
  String get favMoveUp => 'Move up';

  @override
  String get favMoveDown => 'Move down';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED automatically gathers your sources\' groups by country, region and theme. The Live tab and your playlists stay as they are.';

  @override
  String get filteredNoGroups => 'No groups to analyze yet. Refresh a source.';

  @override
  String get filteredAnalyze => 'Organize automatically';

  @override
  String get filteredManage => 'Organization';

  @override
  String get filteredReanalyze => 'Run the analysis again and correct';

  @override
  String get filteredRestore => 'Restore the automatic organization';

  @override
  String get filteredRestoreConfirm =>
      'Your manual corrections will be forgotten. You will see the preview before confirming.';

  @override
  String get filteredPreviewTitle => 'Organization preview';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString groups sorted into $nodesString categories';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Since the last analysis: $added new, $removed gone';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count new groups to sort: open the preview';
  }

  @override
  String filteredToCheck(int count) {
    return 'To check ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Unsorted ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Excluded groups ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count groups';
  }

  @override
  String get filteredValidate => 'Confirm this organization';

  @override
  String get filteredAccept => 'Looks right';

  @override
  String get filteredMove => 'Sort into…';

  @override
  String get filteredExclude => 'Exclude from the organization';

  @override
  String get filteredRestoreGroup => 'Bring back';

  @override
  String get filteredNewCategory => 'New category';

  @override
  String get filteredRename => 'Rename';

  @override
  String get filteredMerge => 'Merge into…';

  @override
  String get sourcesTitle => 'IPTV sources';

  @override
  String get refreshAll => 'Refresh all';

  @override
  String get refresh => 'Refresh';

  @override
  String get editSource => 'Edit';

  @override
  String get deleteSource => 'Delete source';

  @override
  String deleteSourceConfirm(String name) {
    return 'Delete “$name” and its whole catalog from this device?';
  }

  @override
  String get sourceEnabled => 'Enabled';

  @override
  String get makeDefault => 'Use as default';

  @override
  String get isDefault => 'Default source';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Online playlist';

  @override
  String get kindM3uFile => 'M3U file';

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

    return '$liveString channels · $moviesString movies · $seriesString series';
  }

  @override
  String get neverRefreshed => 'Never refreshed';

  @override
  String refreshedAt(String date) {
    return 'Refreshed on $date';
  }

  @override
  String expiresAt(String date) {
    return 'Subscription valid until $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count simultaneous streams',
      one: '1 simultaneous stream',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Apply anyway';

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

    return '“$name”: $addedString added, $updatedString changed, $missingString gone.';
  }

  @override
  String get stageConnecting => 'Connecting to the server…';

  @override
  String get stageLive => 'Downloading channels…';

  @override
  String get stageMovies => 'Downloading movies…';

  @override
  String get stageSeries => 'Downloading series…';

  @override
  String get stagePlaylist => 'Downloading the playlist…';

  @override
  String get stageWriting => 'Saving the catalog…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Saving: $countString items…';
  }

  @override
  String get stageQueued => 'Waiting…';

  @override
  String get errorNetwork =>
      'Server unreachable. Check the address and your connection.';

  @override
  String get errorTimeout => 'The server is taking too long to respond.';

  @override
  String get errorCredentials => 'Username or password rejected by the server.';

  @override
  String get errorExpired => 'This subscription has expired.';

  @override
  String get errorNotFound => 'Address not found on this server.';

  @override
  String get errorNotPlaylist => 'This content is not an M3U playlist.';

  @override
  String get errorInvalidData => 'The server sent an unreadable response.';

  @override
  String get errorEmpty => 'The source is empty: the current catalog is kept.';

  @override
  String errorSuspicious(String detail) {
    return 'Unusually small list ($detail): the current catalog is kept.';
  }

  @override
  String get errorFileMissing => 'File not found or unreadable.';

  @override
  String get errorUnknown => 'The refresh failed. The current catalog is kept.';

  @override
  String get formNewTitle => 'New source';

  @override
  String get formEditTitle => 'Edit source';

  @override
  String get formName => 'Name';

  @override
  String get formNameHint => 'E.g. Living room, Subscription 1';

  @override
  String get formServer => 'Server address';

  @override
  String get formUsername => 'Username';

  @override
  String get formPassword => 'Password';

  @override
  String get formShowPassword => 'Show password';

  @override
  String get formPlaylistUrl => 'Playlist address (M3U or M3U8)';

  @override
  String get formFile => 'Playlist file';

  @override
  String get formChooseFile => 'Choose a file';

  @override
  String get formNoFile => 'No file chosen';

  @override
  String get formFileUnavailable => 'No file picker on this device.';

  @override
  String get formRequired => 'Required field';

  @override
  String get formInvalidUrl => 'Invalid address';

  @override
  String get formContentTitle => 'Content to import';

  @override
  String get formContentHint =>
      'Live TV is always imported. Without movies and series, loading is much lighter.';

  @override
  String get formMovies => 'Movies';

  @override
  String get formSeries => 'Series';

  @override
  String get formContentRemoved =>
      'Items already imported, and their favorites, will be removed from this device.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System language';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy =>
      'No account, no telemetry: your sources and data stay on this device.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: search · F5: refresh all · Ctrl+1 to 9: switch tabs';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPrevious => 'Previous';

  @override
  String get playerNext => 'Next';

  @override
  String get playerRefresh => 'Refresh stream';

  @override
  String get playerFullscreen => 'Fullscreen';

  @override
  String get playerExitFullscreen => 'Exit fullscreen';

  @override
  String get playerMute => 'Mute';

  @override
  String get playerUnmute => 'Unmute';

  @override
  String get playerLive => 'LIVE';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Reconnecting… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Signal lost…';

  @override
  String get playerFailedTitle => 'Can\'t play this';

  @override
  String get playerFailedBody =>
      'This stream is not responding. It may be offline, or your subscription may already be playing on another device.';

  @override
  String get playerEndedTitle => 'Playback finished';

  @override
  String get playerBackToList => 'Back to the list';

  @override
  String get externalTitle => 'External player';

  @override
  String get externalOpen => 'Open in the external player';

  @override
  String get externalNone =>
      'No player found. VLC is used automatically if it is installed.';

  @override
  String get externalFailed =>
      'Couldn\'t start the external player. Check its location in the settings.';

  @override
  String get externalDefault => 'Use VLC';

  @override
  String get seriesFailed => 'Couldn\'t load the episodes.';

  @override
  String get seriesEmpty => 'No episodes available.';

  @override
  String seriesSeason(int number) {
    return 'Season $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Episode $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count min';
  }

  @override
  String get navGuide => 'Guide';

  @override
  String get guideTitle => 'TV guide';

  @override
  String get guideScope => 'Channels shown';

  @override
  String get guideAllChannels => 'All channels';

  @override
  String get guideNow => 'Now';

  @override
  String get guideToday => 'Today';

  @override
  String get guideYesterday => 'Yesterday';

  @override
  String get guideTomorrow => 'Tomorrow';

  @override
  String get guideEarlier => '2 hours earlier';

  @override
  String get guideLater => '2 hours later';

  @override
  String get guideEmptyTitle => 'No TV guide yet';

  @override
  String get guideEmptyBody =>
      'Import the guide from your sources, or add an XMLTV address or file in the settings.';

  @override
  String get guideImport => 'Import the guide';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Importing the guide… $countString programs';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Guide updated: $programsString programs, $channelsString channels matched.';
  }

  @override
  String guideFailed(String names) {
    return 'Guide unavailable: $names. The previous guide is kept.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString programs · $date';
  }

  @override
  String get guideNeverRefreshed => 'Never refreshed';

  @override
  String get guideLastFailed => 'The last refresh failed.';

  @override
  String get guideRefresh => 'Refresh the guide';

  @override
  String get guideAddUrl => 'Add an address';

  @override
  String get guideAddFile => 'Add a file';

  @override
  String get guideUrlHint => 'XMLTV guide address';

  @override
  String get guideWatchLive => 'Watch live';

  @override
  String get guideReplay => 'Replay';

  @override
  String get guideReplayOff => 'Replay isn\'t available for this program.';

  @override
  String get guideComing => 'Coming up';

  @override
  String get guideChannel => 'Channel schedule';

  @override
  String get guideLink => 'Match to the guide';

  @override
  String get guideLinkHint => 'Channel name or ID';

  @override
  String get guideNoProgram => 'No programs for this channel.';

  @override
  String get guideNoChannels => 'No channel in this selection has a guide.';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupExport => 'Create a backup';

  @override
  String get backupImport => 'Restore a backup';

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupSecrets => 'Include passwords';

  @override
  String get backupSecretsBody =>
      'The file is then encrypted with your passphrase. Otherwise, passwords and full playlist addresses are left out.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupPassphraseAgain => 'Confirm the passphrase';

  @override
  String get backupPassphraseShort => 'At least 8 characters.';

  @override
  String get backupPassphraseMismatch => 'The two passphrases differ.';

  @override
  String get backupSaved => 'Backup saved.';

  @override
  String get backupFailed => 'Couldn\'t write this file.';

  @override
  String get backupNotOurs => 'This file isn\'t a Chud IPTV backup.';

  @override
  String get backupTooNew =>
      'This backup comes from a newer version of the app.';

  @override
  String get backupDamaged => 'This backup is damaged.';

  @override
  String get backupWrongPassphrase =>
      'Wrong passphrase, or the file was changed.';

  @override
  String get backupConfirmTitle => 'Restore this backup?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Backup from $date. Sources: $sources, lists: $lists, favorites: $favorites. Your current data is kept and added to; only the settings are replaced.';
  }

  @override
  String get backupRestored => 'Restore complete.';

  @override
  String backupIncomplete(int count) {
    return 'Restore complete. Sources to complete: $count. Their password or address wasn\'t in the file.';
  }

  @override
  String get autoTitle => 'Automatic refresh';

  @override
  String get autoOff => 'Off';

  @override
  String autoEvery(int hours) {
    return 'Every $hours h';
  }

  @override
  String get dataTitle => 'Local data';

  @override
  String cacheLine(String size) {
    return 'Logo cache: $size MB';
  }

  @override
  String get cacheClear => 'Clear the cache';

  @override
  String get cacheCleared => 'Cache cleared.';

  @override
  String get wipeButton => 'Erase all data';

  @override
  String get wipeTitle => 'Erase everything?';

  @override
  String get wipeBody =>
      'Sources, favorites, guide, downloads and settings will be removed from this device. This can\'t be undone.';

  @override
  String get wipeConfirm => 'Erase everything';

  @override
  String get updateTitle => 'Updates';

  @override
  String get updateAuto => 'Check automatically';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String get updateChecking => 'Checking…';

  @override
  String get updateLatest => 'You have the latest version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version available';
  }

  @override
  String get updateSee => 'View';

  @override
  String get updateInstall => 'Update';

  @override
  String updateDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateVerifying => 'Verifying the file…';

  @override
  String get updateRestarting => 'Installing: the app will restart.';

  @override
  String get updateConfirmSystem =>
      'Confirm the installation in the system window.';

  @override
  String get updateOpened =>
      'The download opened in your browser: install it, then restart the app.';

  @override
  String get updateCancelled => 'Update cancelled.';

  @override
  String get updateNoChannel =>
      'This build isn\'t linked to an update channel.';

  @override
  String get updateFailedNetwork => 'Couldn\'t reach the update server.';

  @override
  String get updateFailedSignature => 'Invalid signature: update refused.';

  @override
  String get updateFailedIntegrity => 'Corrupted file: nothing was installed.';

  @override
  String get updateFailedInstall => 'The installation failed.';

  @override
  String updateDone(String version) {
    return 'Update to version $version installed.';
  }

  @override
  String updateNotApplied(String version) {
    return 'The update to version $version couldn\'t be installed: the previous version stays in place.';
  }

  @override
  String get navDownloads => 'Downloads';

  @override
  String get downloadAction => 'Download';

  @override
  String get downloadSeason => 'Download the season';

  @override
  String downloadAdded(String title) {
    return 'Added to downloads: $title';
  }

  @override
  String get downloadPlay => 'Play the file';

  @override
  String get downloadEmptyTitle => 'No downloads';

  @override
  String get downloadEmptyBody =>
      'Download a movie from its page, or an episode from its series, to watch it offline.';

  @override
  String get downloadQueued => 'Waiting';

  @override
  String get downloadPaused => 'Paused';

  @override
  String get downloadHeld => 'Waiting for playback to finish';

  @override
  String get downloadPause => 'Pause';

  @override
  String get downloadResume => 'Resume';

  @override
  String get downloadDeleteTitle => 'Delete this download?';

  @override
  String downloadDeleteBody(String title) {
    return '$title will be removed from this device.';
  }

  @override
  String get downloadFolder => 'Downloads folder';

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
      'Connection lost. The file is kept: resuming continues where it stopped.';

  @override
  String get downloadErrorServer =>
      'The server refused. Another stream may be using your connection.';

  @override
  String get downloadErrorFormat =>
      'This content is streamed in segments and can\'t be downloaded.';

  @override
  String get downloadErrorDisk =>
      'Couldn\'t write: not enough disk space, or the folder is unavailable.';

  @override
  String get downloadErrorSource =>
      'The source of this download no longer exists.';

  @override
  String get downloadErrorMissing => 'The file was moved or deleted.';

  @override
  String get downloadFolderChoose => 'Choose a folder';

  @override
  String get downloadFolderReset => 'Default folder';

  @override
  String get downloadFolderApp => 'App folder, removed along with the app';

  @override
  String get downloadFolderHint =>
      'Applies to future downloads. Finished ones stay where they are.';

  @override
  String get favChooseBody =>
      'You don\'t have a list yet. Where do you want to keep this favorite?';

  @override
  String get favGlobal => 'General favorites';

  @override
  String get settingsPhoneTitle => 'Phone playback';

  @override
  String get settingsPip => 'Picture in picture';

  @override
  String get settingsPipBody =>
      'The video keeps playing in a small window when you leave the app. A button appears in the player.';

  @override
  String get settingsRadio => 'Radio mode';

  @override
  String get settingsRadioBody =>
      'Sound keeps playing when the phone is locked or the app is in the background. A button appears in the player.';

  @override
  String get playerPipOn => 'Picture in picture on';

  @override
  String get playerPipOff => 'Picture in picture off';

  @override
  String get playerRadioOn => 'Radio mode on';

  @override
  String get playerRadioOff => 'Radio mode off';

  @override
  String get radioNotificationStop => 'Stop';
}
