// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navLive => 'In diretta';

  @override
  String get navFavorites => 'Preferiti';

  @override
  String get navMovies => 'Film';

  @override
  String get navSeries => 'Serie TV';

  @override
  String get navSources => 'Sorgenti';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navMore => 'Altro';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get welcomeTitle => 'Benvenuto';

  @override
  String get welcomeBody =>
      'Aggiungi una sorgente per iniziare: un account Xtream Codes o una playlist M3U. L\'app non fornisce canali e tutto resta su questo dispositivo.';

  @override
  String get addSource => 'Aggiungi sorgente';

  @override
  String get allSources => 'Tutte le sorgenti';

  @override
  String get allCategories => 'Tutto';

  @override
  String get noCategoryName => 'Senza categoria';

  @override
  String get filterCategories => 'Filtra categorie';

  @override
  String get emptyList => 'Niente da mostrare qui.';

  @override
  String get emptyWhileImporting =>
      'Importazione in corso, il catalogo apparirà appena pronto.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementi',
      one: '1 elemento',
      zero: 'Nessun elemento',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Elenco compatto';

  @override
  String get viewDetailed => 'Elenco dettagliato';

  @override
  String get viewGrid => 'Griglia';

  @override
  String get searchHint => 'Cerca';

  @override
  String noResults(String query) {
    return 'Nessun risultato per «$query».';
  }

  @override
  String get sortLabel => 'Ordina';

  @override
  String get sortSource => 'Ordine della sorgente';

  @override
  String get sortNameAsc => 'Nome (A → Z)';

  @override
  String get sortNameDesc => 'Nome (Z → A)';

  @override
  String get sortRecent => 'Aggiunti di recente';

  @override
  String get sortRating => 'Più votati';

  @override
  String get filterLabel => 'Filtri';

  @override
  String get filterCountry => 'Paese o lingua';

  @override
  String get filterAllCountries => 'Tutti i paesi';

  @override
  String get itemSource => 'Sorgente';

  @override
  String get itemCategory => 'Categoria';

  @override
  String get itemCountry => 'Paese o lingua';

  @override
  String get itemFormat => 'Formato';

  @override
  String get itemRating => 'Voto';

  @override
  String get favAdd => 'Aggiungi ai preferiti';

  @override
  String get favRemove => 'Rimuovi dai preferiti';

  @override
  String get favPickLists => 'Elenchi preferiti';

  @override
  String get favNewList => 'Nuovo elenco';

  @override
  String get favDefaultName => 'Preferiti';

  @override
  String get favListName => 'Nome dell\'elenco';

  @override
  String get favListIcon => 'Icona';

  @override
  String get favRename => 'Modifica elenco';

  @override
  String get favDeleteList => 'Elimina elenco';

  @override
  String favDeleteConfirm(String name) {
    return 'Eliminare l\'elenco «$name»? I canali restano nel catalogo.';
  }

  @override
  String get favEmptyLists =>
      'Crea i tuoi elenchi: sport, notizie, bambini… Un canale può stare in più elenchi.';

  @override
  String get favEmptyList =>
      'Questo elenco è vuoto. Aggiungi canali con la stella.';

  @override
  String get favManage => 'Gestisci elenchi';

  @override
  String get favMoveUp => 'Sposta su';

  @override
  String get favMoveDown => 'Sposta giù';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED riunisce automaticamente i gruppi delle tue sorgenti per paese, regione e tema. La scheda In diretta e le playlist non cambiano.';

  @override
  String get filteredNoGroups =>
      'Ancora nessun gruppo da analizzare. Aggiorna una sorgente.';

  @override
  String get filteredAnalyze => 'Organizza automaticamente';

  @override
  String get filteredManage => 'Organizzazione';

  @override
  String get filteredReanalyze => 'Rianalizza e correggi';

  @override
  String get filteredRestore => 'Ripristina l\'organizzazione automatica';

  @override
  String get filteredRestoreConfirm =>
      'Le correzioni manuali andranno perse. Vedrai l\'anteprima prima di confermare.';

  @override
  String get filteredPreviewTitle => 'Anteprima';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString gruppi in $nodesString categorie';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Dall\'ultima analisi: $added nuovi, $removed scomparsi';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count nuovi gruppi da ordinare: apri l\'anteprima';
  }

  @override
  String filteredToCheck(int count) {
    return 'Da controllare ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Non classificati ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Gruppi esclusi ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count gruppi';
  }

  @override
  String get filteredValidate => 'Conferma questa organizzazione';

  @override
  String get filteredAccept => 'Va bene';

  @override
  String get filteredMove => 'Sposta in…';

  @override
  String get filteredExclude => 'Escludi dall\'organizzazione';

  @override
  String get filteredRestoreGroup => 'Reintegra';

  @override
  String get filteredNewCategory => 'Nuova categoria';

  @override
  String get filteredRename => 'Rinomina';

  @override
  String get filteredMerge => 'Unisci a…';

  @override
  String get sourcesTitle => 'Sorgenti IPTV';

  @override
  String get refreshAll => 'Aggiorna tutto';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get editSource => 'Modifica';

  @override
  String get deleteSource => 'Elimina sorgente';

  @override
  String deleteSourceConfirm(String name) {
    return 'Eliminare «$name» e tutto il suo catalogo da questo dispositivo?';
  }

  @override
  String get sourceEnabled => 'Attiva';

  @override
  String get makeDefault => 'Usa come predefinita';

  @override
  String get isDefault => 'Sorgente predefinita';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Playlist online';

  @override
  String get kindM3uFile => 'File M3U';

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

    return '$liveString canali · $moviesString film · $seriesString serie';
  }

  @override
  String get neverRefreshed => 'Mai aggiornata';

  @override
  String refreshedAt(String date) {
    return 'Aggiornata il $date';
  }

  @override
  String expiresAt(String date) {
    return 'Abbonamento valido fino al $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count riproduzioni simultanee',
      one: '1 riproduzione simultanea',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Applica comunque';

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

    return '«$name»: $addedString aggiunti, $updatedString modificati, $missingString scomparsi.';
  }

  @override
  String get stageConnecting => 'Connessione al server…';

  @override
  String get stageLive => 'Download dei canali…';

  @override
  String get stageMovies => 'Download dei film…';

  @override
  String get stageSeries => 'Download delle serie…';

  @override
  String get stagePlaylist => 'Download della playlist…';

  @override
  String get stageWriting => 'Salvataggio del catalogo…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Salvataggio: $countString elementi…';
  }

  @override
  String get stageQueued => 'In attesa…';

  @override
  String get errorNetwork =>
      'Server non raggiungibile. Controlla l\'indirizzo e la connessione.';

  @override
  String get errorTimeout => 'Il server impiega troppo a rispondere.';

  @override
  String get errorCredentials => 'Nome utente o password rifiutati dal server.';

  @override
  String get errorExpired => 'Questo abbonamento è scaduto.';

  @override
  String get errorNotFound => 'Indirizzo non trovato su questo server.';

  @override
  String get errorNotPlaylist => 'Questo contenuto non è una playlist M3U.';

  @override
  String get errorInvalidData =>
      'Il server ha inviato una risposta illeggibile.';

  @override
  String get errorEmpty =>
      'La sorgente è vuota: il catalogo attuale viene mantenuto.';

  @override
  String errorSuspicious(String detail) {
    return 'Elenco insolitamente ridotto ($detail): il catalogo attuale viene mantenuto.';
  }

  @override
  String get errorFileMissing => 'File non trovato o illeggibile.';

  @override
  String get errorUnknown =>
      'Aggiornamento non riuscito. Il catalogo attuale viene mantenuto.';

  @override
  String get formNewTitle => 'Nuova sorgente';

  @override
  String get formEditTitle => 'Modifica sorgente';

  @override
  String get formName => 'Nome';

  @override
  String get formNameHint => 'Es.: Salotto, Abbonamento 1';

  @override
  String get formServer => 'Indirizzo del server';

  @override
  String get formUsername => 'Nome utente';

  @override
  String get formPassword => 'Password';

  @override
  String get formShowPassword => 'Mostra password';

  @override
  String get formPlaylistUrl => 'Indirizzo della playlist (M3U o M3U8)';

  @override
  String get formFile => 'File della playlist';

  @override
  String get formChooseFile => 'Scegli un file';

  @override
  String get formNoFile => 'Nessun file scelto';

  @override
  String get formFileUnavailable =>
      'Nessun selettore di file su questo dispositivo.';

  @override
  String get formRequired => 'Campo obbligatorio';

  @override
  String get formInvalidUrl => 'Indirizzo non valido';

  @override
  String get formContentTitle => 'Contenuti da importare';

  @override
  String get formContentHint =>
      'La diretta viene sempre importata. Senza film e serie il caricamento è molto più leggero.';

  @override
  String get formMovies => 'Film';

  @override
  String get formSeries => 'Serie TV';

  @override
  String get formContentRemoved =>
      'Gli elementi già importati e i loro preferiti saranno rimossi da questo dispositivo.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get settingsPrivacy =>
      'Nessun account, nessuna telemetria: sorgenti e dati restano su questo dispositivo.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: cerca · F5: aggiorna tutto · Ctrl+1-9: cambia scheda';

  @override
  String get playerPlay => 'Riproduci';

  @override
  String get playerPause => 'Pausa';

  @override
  String get playerPrevious => 'Precedente';

  @override
  String get playerNext => 'Successivo';

  @override
  String get playerRefresh => 'Ricarica il flusso';

  @override
  String get playerFullscreen => 'Schermo intero';

  @override
  String get playerExitFullscreen => 'Esci da schermo intero';

  @override
  String get playerMute => 'Disattiva audio';

  @override
  String get playerUnmute => 'Riattiva audio';

  @override
  String get playerLive => 'IN DIRETTA';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Riconnessione… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Segnale perso…';

  @override
  String get playerFailedTitle => 'Riproduzione impossibile';

  @override
  String get playerFailedBody =>
      'Questo flusso non risponde. Potrebbe essere offline o l\'abbonamento è già in uso su un altro dispositivo.';

  @override
  String get playerEndedTitle => 'Riproduzione terminata';

  @override
  String get playerBackToList => 'Torna all\'elenco';

  @override
  String get externalTitle => 'Lettore esterno';

  @override
  String get externalOpen => 'Apri nel lettore esterno';

  @override
  String get externalNone =>
      'Nessun lettore trovato. VLC viene usato automaticamente se installato.';

  @override
  String get externalFailed =>
      'Impossibile avviare il lettore esterno. Controlla il percorso nelle impostazioni.';

  @override
  String get externalDefault => 'Usa VLC';

  @override
  String get seriesFailed => 'Impossibile caricare gli episodi.';

  @override
  String get seriesEmpty => 'Nessun episodio disponibile.';

  @override
  String seriesSeason(int number) {
    return 'Stagione $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Episodio $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count min';
  }

  @override
  String get navGuide => 'Guida';

  @override
  String get guideTitle => 'Guida TV';

  @override
  String get guideScope => 'Canali mostrati';

  @override
  String get guideAllChannels => 'Tutti i canali';

  @override
  String get guideNow => 'Adesso';

  @override
  String get guideToday => 'Oggi';

  @override
  String get guideYesterday => 'Ieri';

  @override
  String get guideTomorrow => 'Domani';

  @override
  String get guideEarlier => '2 ore prima';

  @override
  String get guideLater => '2 ore dopo';

  @override
  String get guideEmptyTitle => 'Nessuna guida TV';

  @override
  String get guideEmptyBody =>
      'Importa la guida dalle tue sorgenti oppure aggiungi un indirizzo o un file XMLTV nelle impostazioni.';

  @override
  String get guideImport => 'Importa la guida';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Importazione della guida… $countString programmi';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Guida aggiornata: $programsString programmi, $channelsString canali associati.';
  }

  @override
  String guideFailed(String names) {
    return 'Guida non disponibile: $names. Quella precedente viene mantenuta.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString programmi · $date';
  }

  @override
  String get guideNeverRefreshed => 'Mai aggiornata';

  @override
  String get guideLastFailed => 'L\'ultimo aggiornamento non è riuscito.';

  @override
  String get guideRefresh => 'Aggiorna la guida';

  @override
  String get guideAddUrl => 'Aggiungi un indirizzo';

  @override
  String get guideAddFile => 'Aggiungi un file';

  @override
  String get guideUrlHint => 'Indirizzo della guida XMLTV';

  @override
  String get guideWatchLive => 'Guarda in diretta';

  @override
  String get guideReplay => 'Rivedi';

  @override
  String get guideReplayOff => 'Replay non disponibile per questo programma.';

  @override
  String get guideComing => 'In arrivo';

  @override
  String get guideChannel => 'Palinsesto del canale';

  @override
  String get guideLink => 'Associa alla guida';

  @override
  String get guideLinkHint => 'Nome o identificativo del canale';

  @override
  String get guideNoProgram => 'Nessun programma per questo canale.';

  @override
  String get guideNoChannels =>
      'Nessun canale di questa selezione ha una guida.';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupExport => 'Crea un backup';

  @override
  String get backupImport => 'Ripristina un backup';

  @override
  String get backupRestore => 'Ripristina';

  @override
  String get backupSecrets => 'Includi le password';

  @override
  String get backupSecretsBody =>
      'Il file viene quindi cifrato con la tua passphrase. Altrimenti password e indirizzi completi delle playlist non vengono salvati.';

  @override
  String get backupPassphrase => 'Passphrase';

  @override
  String get backupPassphraseAgain => 'Conferma la passphrase';

  @override
  String get backupPassphraseShort => 'Almeno 8 caratteri.';

  @override
  String get backupPassphraseMismatch => 'Le due passphrase sono diverse.';

  @override
  String get backupSaved => 'Backup salvato.';

  @override
  String get backupFailed => 'Impossibile scrivere questo file.';

  @override
  String get backupNotOurs => 'Questo file non è un backup di Chud IPTV.';

  @override
  String get backupTooNew =>
      'Questo backup proviene da una versione più recente dell\'app.';

  @override
  String get backupDamaged => 'Questo backup è danneggiato.';

  @override
  String get backupWrongPassphrase => 'Passphrase errata o file modificato.';

  @override
  String get backupConfirmTitle => 'Ripristinare questo backup?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Backup del $date. Sorgenti: $sources, elenchi: $lists, preferiti: $favorites. I dati attuali vengono mantenuti e completati; solo le impostazioni vengono sostituite.';
  }

  @override
  String get backupRestored => 'Ripristino completato.';

  @override
  String backupIncomplete(int count) {
    return 'Ripristino completato. Sorgenti da completare: $count. Password o indirizzo non erano nel file.';
  }

  @override
  String get autoTitle => 'Aggiornamento automatico';

  @override
  String get autoOff => 'Disattivato';

  @override
  String autoEvery(int hours) {
    return 'Ogni $hours ore';
  }

  @override
  String get dataTitle => 'Dati locali';

  @override
  String cacheLine(String size) {
    return 'Cache dei loghi: $size MB';
  }

  @override
  String get cacheClear => 'Svuota la cache';

  @override
  String get cacheCleared => 'Cache svuotata.';

  @override
  String get wipeButton => 'Cancella tutti i dati';

  @override
  String get wipeTitle => 'Cancellare tutto?';

  @override
  String get wipeBody =>
      'Sorgenti, preferiti, guida, download e impostazioni verranno rimossi da questo dispositivo. L\'azione è definitiva.';

  @override
  String get wipeConfirm => 'Cancella tutto';

  @override
  String get updateTitle => 'Aggiornamenti';

  @override
  String get updateAuto => 'Controlla automaticamente';

  @override
  String get updateCheck => 'Cerca aggiornamenti';

  @override
  String get updateChecking => 'Ricerca in corso…';

  @override
  String get updateLatest => 'Hai l\'ultima versione.';

  @override
  String updateAvailable(String version) {
    return 'Versione $version disponibile';
  }

  @override
  String get updateSee => 'Vedi';

  @override
  String get updateInstall => 'Aggiorna';

  @override
  String updateDownloading(int percent) {
    return 'Download… $percent%';
  }

  @override
  String get updateVerifying => 'Verifica del file…';

  @override
  String get updateRestarting => 'Installazione: l\'app si riavvierà.';

  @override
  String get updateConfirmSystem =>
      'Conferma l\'installazione nella finestra di sistema.';

  @override
  String get updateOpened =>
      'Il download si è aperto nel browser: installalo, poi riavvia l\'app.';

  @override
  String get updateCancelled => 'Aggiornamento annullato.';

  @override
  String get updateNoChannel =>
      'Questa versione non è collegata a un canale di aggiornamento.';

  @override
  String get updateFailedNetwork =>
      'Server di aggiornamento non raggiungibile.';

  @override
  String get updateFailedSignature =>
      'Firma non valida: aggiornamento rifiutato.';

  @override
  String get updateFailedIntegrity =>
      'File danneggiato: non è stato installato nulla.';

  @override
  String get updateFailedInstall => 'Installazione non riuscita.';

  @override
  String updateDone(String version) {
    return 'Aggiornamento alla versione $version installato.';
  }

  @override
  String updateNotApplied(String version) {
    return 'Impossibile installare l\'aggiornamento alla versione $version: resta la versione precedente.';
  }

  @override
  String get navDownloads => 'Download';

  @override
  String get downloadAction => 'Scarica';

  @override
  String get downloadSeason => 'Scarica la stagione';

  @override
  String downloadAdded(String title) {
    return 'Aggiunto ai download: $title';
  }

  @override
  String get downloadPlay => 'Riproduci il file';

  @override
  String get downloadEmptyTitle => 'Nessun download';

  @override
  String get downloadEmptyBody =>
      'Scarica un film dalla sua scheda, o un episodio dalla sua serie, per guardarlo offline.';

  @override
  String get downloadQueued => 'In attesa';

  @override
  String get downloadPaused => 'In pausa';

  @override
  String get downloadHeld => 'In attesa della fine della riproduzione';

  @override
  String get downloadPause => 'Metti in pausa';

  @override
  String get downloadResume => 'Riprendi';

  @override
  String get downloadDeleteTitle => 'Eliminare questo download?';

  @override
  String downloadDeleteBody(String title) {
    return '$title verrà rimosso da questo dispositivo.';
  }

  @override
  String get downloadFolder => 'Cartella dei download';

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
      'Connessione persa. Il file viene mantenuto: riprende da dove si era fermato.';

  @override
  String get downloadErrorServer =>
      'Il server ha rifiutato. Forse un\'altra riproduzione sta usando la tua connessione.';

  @override
  String get downloadErrorFormat =>
      'Questo contenuto è trasmesso a segmenti e non può essere scaricato.';

  @override
  String get downloadErrorDisk =>
      'Scrittura impossibile: spazio insufficiente o cartella non accessibile.';

  @override
  String get downloadErrorSource =>
      'La sorgente di questo download non esiste più.';

  @override
  String get downloadErrorMissing => 'Il file è stato spostato o eliminato.';

  @override
  String get downloadFolderChoose => 'Scegli una cartella';

  @override
  String get downloadFolderReset => 'Cartella predefinita';

  @override
  String get downloadFolderApp => 'Cartella dell\'app, rimossa con essa';

  @override
  String get downloadFolderHint =>
      'Vale per i prossimi download. Quelli completati restano dove sono.';

  @override
  String get favChooseBody =>
      'Non hai ancora un elenco. Dove vuoi salvare questo preferito?';

  @override
  String get favGlobal => 'Preferiti generali';

  @override
  String get settingsPhoneTitle => 'Riproduzione sul telefono';

  @override
  String get settingsPip => 'Picture in picture';

  @override
  String get settingsPipBody =>
      'Il video continua in una piccola finestra quando esci dall\'app. Nel lettore appare un pulsante.';

  @override
  String get settingsRadio => 'Modalità radio';

  @override
  String get settingsRadioBody =>
      'L\'audio continua con il telefono bloccato o l\'app in background. Nel lettore appare un pulsante.';

  @override
  String get playerPipOn => 'Picture in picture attivo';

  @override
  String get playerPipOff => 'Picture in picture disattivato';

  @override
  String get playerRadioOn => 'Modalità radio attiva';

  @override
  String get playerRadioOff => 'Modalità radio disattivata';

  @override
  String get radioNotificationStop => 'Ferma';
}
