// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navLive => 'Direct';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navMovies => 'Films';

  @override
  String get navSeries => 'Séries';

  @override
  String get navSources => 'Sources';

  @override
  String get navSettings => 'Réglages';

  @override
  String get navMore => 'Plus';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get welcomeTitle => 'Bienvenue';

  @override
  String get welcomeBody =>
      'Ajoutez une source pour commencer : un compte Xtream Codes ou une playlist M3U. L\'app ne fournit aucune chaîne, tout reste sur cet appareil.';

  @override
  String get addSource => 'Ajouter une source';

  @override
  String get allSources => 'Toutes les sources';

  @override
  String get allCategories => 'Tout';

  @override
  String get noCategoryName => 'Sans catégorie';

  @override
  String get filterCategories => 'Filtrer les catégories';

  @override
  String get emptyList => 'Rien à afficher ici.';

  @override
  String get emptyWhileImporting =>
      'Import en cours, le catalogue apparaîtra dès qu\'il sera prêt.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString éléments',
      one: '1 élément',
      zero: 'Aucun élément',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Liste compacte';

  @override
  String get viewDetailed => 'Liste détaillée';

  @override
  String get viewGrid => 'Grille';

  @override
  String get searchHint => 'Rechercher';

  @override
  String noResults(String query) {
    return 'Aucun résultat pour « $query ».';
  }

  @override
  String get sortLabel => 'Trier';

  @override
  String get sortSource => 'Ordre de la source';

  @override
  String get sortNameAsc => 'Nom (A → Z)';

  @override
  String get sortNameDesc => 'Nom (Z → A)';

  @override
  String get sortRecent => 'Ajouts récents';

  @override
  String get sortRating => 'Mieux notés';

  @override
  String get filterLabel => 'Filtres';

  @override
  String get filterCountry => 'Pays ou langue';

  @override
  String get filterAllCountries => 'Tous les pays';

  @override
  String get itemSource => 'Source';

  @override
  String get itemCategory => 'Catégorie';

  @override
  String get itemCountry => 'Pays ou langue';

  @override
  String get itemFormat => 'Format';

  @override
  String get itemRating => 'Note';

  @override
  String get favAdd => 'Ajouter aux favoris';

  @override
  String get favRemove => 'Retirer des favoris';

  @override
  String get favPickLists => 'Listes de favoris';

  @override
  String get favNewList => 'Nouvelle liste';

  @override
  String get favDefaultName => 'Favoris';

  @override
  String get favListName => 'Nom de la liste';

  @override
  String get favListIcon => 'Icône';

  @override
  String get favRename => 'Modifier la liste';

  @override
  String get favDeleteList => 'Supprimer la liste';

  @override
  String favDeleteConfirm(String name) {
    return 'Supprimer la liste « $name » ? Les chaînes restent dans le catalogue.';
  }

  @override
  String get favEmptyLists =>
      'Créez vos listes : sport, info, enfants… Une même chaîne peut être dans plusieurs listes.';

  @override
  String get favEmptyList =>
      'Cette liste est vide. Ajoutez des chaînes avec l\'étoile.';

  @override
  String get favManage => 'Gérer les listes';

  @override
  String get favMoveUp => 'Monter';

  @override
  String get favMoveDown => 'Descendre';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED regroupe automatiquement les groupes de vos sources par pays, région et thème. L\'onglet Direct et vos playlists ne changent pas.';

  @override
  String get filteredNoGroups =>
      'Aucun groupe à analyser pour le moment. Actualisez une source.';

  @override
  String get filteredAnalyze => 'Organiser automatiquement';

  @override
  String get filteredManage => 'Classement';

  @override
  String get filteredReanalyze => 'Relancer l\'analyse et corriger';

  @override
  String get filteredRestore => 'Restaurer le classement automatique';

  @override
  String get filteredRestoreConfirm =>
      'Vos corrections manuelles seront oubliées. Vous verrez l\'aperçu avant de valider.';

  @override
  String get filteredPreviewTitle => 'Aperçu du classement';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString groupes rangés dans $nodesString catégories';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Depuis la dernière analyse : $added nouveaux, $removed disparus';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count nouveaux groupes à ranger : ouvrir l\'aperçu';
  }

  @override
  String filteredToCheck(int count) {
    return 'À vérifier ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Non classés ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Groupes exclus ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count groupes';
  }

  @override
  String get filteredValidate => 'Valider ce classement';

  @override
  String get filteredAccept => 'C\'est bon';

  @override
  String get filteredMove => 'Ranger dans…';

  @override
  String get filteredExclude => 'Exclure du classement';

  @override
  String get filteredRestoreGroup => 'Réintégrer';

  @override
  String get filteredNewCategory => 'Nouvelle catégorie';

  @override
  String get filteredRename => 'Renommer';

  @override
  String get filteredMerge => 'Fusionner dans…';

  @override
  String get sourcesTitle => 'Sources IPTV';

  @override
  String get refreshAll => 'Tout actualiser';

  @override
  String get refresh => 'Actualiser';

  @override
  String get editSource => 'Modifier';

  @override
  String get deleteSource => 'Supprimer la source';

  @override
  String deleteSourceConfirm(String name) {
    return 'Supprimer « $name » et tout son catalogue de cet appareil ?';
  }

  @override
  String get sourceEnabled => 'Activée';

  @override
  String get makeDefault => 'Utiliser par défaut';

  @override
  String get isDefault => 'Source par défaut';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Playlist en ligne';

  @override
  String get kindM3uFile => 'Fichier M3U';

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

    return '$liveString chaînes · $moviesString films · $seriesString séries';
  }

  @override
  String get neverRefreshed => 'Jamais actualisée';

  @override
  String refreshedAt(String date) {
    return 'Actualisée le $date';
  }

  @override
  String expiresAt(String date) {
    return 'Abonnement valable jusqu\'au $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lectures simultanées',
      one: '1 lecture simultanée',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Appliquer quand même';

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

    return '« $name » : $addedString ajoutés, $updatedString modifiés, $missingString disparus.';
  }

  @override
  String get stageConnecting => 'Connexion au serveur…';

  @override
  String get stageLive => 'Téléchargement des chaînes…';

  @override
  String get stageMovies => 'Téléchargement des films…';

  @override
  String get stageSeries => 'Téléchargement des séries…';

  @override
  String get stagePlaylist => 'Téléchargement de la playlist…';

  @override
  String get stageWriting => 'Enregistrement du catalogue…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Enregistrement : $countString éléments…';
  }

  @override
  String get stageQueued => 'En attente…';

  @override
  String get errorNetwork =>
      'Serveur injoignable. Vérifiez l\'adresse et votre connexion.';

  @override
  String get errorTimeout => 'Le serveur met trop de temps à répondre.';

  @override
  String get errorCredentials =>
      'Identifiant ou mot de passe refusé par le serveur.';

  @override
  String get errorExpired => 'Cet abonnement a expiré.';

  @override
  String get errorNotFound => 'Adresse introuvable sur ce serveur.';

  @override
  String get errorNotPlaylist => 'Ce contenu n\'est pas une playlist M3U.';

  @override
  String get errorInvalidData => 'Le serveur a renvoyé une réponse illisible.';

  @override
  String get errorEmpty =>
      'La source est vide : le catalogue actuel est conservé.';

  @override
  String errorSuspicious(String detail) {
    return 'Liste anormalement réduite ($detail) : le catalogue actuel est conservé.';
  }

  @override
  String get errorFileMissing => 'Fichier introuvable ou illisible.';

  @override
  String get errorUnknown =>
      'L\'actualisation a échoué. Le catalogue actuel est conservé.';

  @override
  String get formNewTitle => 'Nouvelle source';

  @override
  String get formEditTitle => 'Modifier la source';

  @override
  String get formName => 'Nom';

  @override
  String get formNameHint => 'Ex. : Salon, Abonnement 1';

  @override
  String get formServer => 'Adresse du serveur';

  @override
  String get formUsername => 'Nom d\'utilisateur';

  @override
  String get formPassword => 'Mot de passe';

  @override
  String get formShowPassword => 'Afficher le mot de passe';

  @override
  String get formPlaylistUrl => 'Adresse de la playlist (M3U ou M3U8)';

  @override
  String get formFile => 'Fichier de playlist';

  @override
  String get formChooseFile => 'Choisir un fichier';

  @override
  String get formNoFile => 'Aucun fichier choisi';

  @override
  String get formFileUnavailable =>
      'Aucun sélecteur de fichiers sur cet appareil.';

  @override
  String get formRequired => 'Champ obligatoire';

  @override
  String get formInvalidUrl => 'Adresse invalide';

  @override
  String get formContentTitle => 'Contenu à importer';

  @override
  String get formContentHint =>
      'Le direct est toujours importé. Sans films ni séries, le chargement est bien plus léger.';

  @override
  String get formMovies => 'Films';

  @override
  String get formSeries => 'Séries';

  @override
  String get formContentRemoved =>
      'Les éléments déjà importés, et leurs favoris, seront retirés de cet appareil.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get settingsApp => 'Application';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy =>
      'Aucun compte, aucune télémétrie : vos sources et vos données restent sur cet appareil.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F : rechercher · F5 : tout actualiser · Ctrl+1 à 9 : changer d\'onglet';

  @override
  String get playerPlay => 'Lire';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPrevious => 'Précédent';

  @override
  String get playerNext => 'Suivant';

  @override
  String get playerRefresh => 'Rafraîchir le flux';

  @override
  String get playerFullscreen => 'Plein écran';

  @override
  String get playerExitFullscreen => 'Quitter le plein écran';

  @override
  String get playerMute => 'Couper le son';

  @override
  String get playerUnmute => 'Rétablir le son';

  @override
  String get playerLive => 'DIRECT';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Reconnexion… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Signal perdu…';

  @override
  String get playerFailedTitle => 'Lecture impossible';

  @override
  String get playerFailedBody =>
      'Ce flux ne répond pas. Il est peut-être hors ligne, ou votre abonnement lit déjà sur un autre appareil.';

  @override
  String get playerEndedTitle => 'Lecture terminée';

  @override
  String get playerBackToList => 'Retour à la liste';

  @override
  String get externalTitle => 'Lecteur externe';

  @override
  String get externalOpen => 'Ouvrir dans le lecteur externe';

  @override
  String get externalNone =>
      'Aucun lecteur trouvé. VLC est utilisé automatiquement s\'il est installé.';

  @override
  String get externalFailed =>
      'Impossible de lancer le lecteur externe. Vérifiez son emplacement dans les réglages.';

  @override
  String get externalDefault => 'Utiliser VLC';

  @override
  String get seriesFailed => 'Impossible de charger les épisodes.';

  @override
  String get seriesEmpty => 'Aucun épisode disponible.';

  @override
  String seriesSeason(int number) {
    return 'Saison $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Épisode $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count min';
  }

  @override
  String get navGuide => 'Guide';

  @override
  String get guideTitle => 'Guide des programmes';

  @override
  String get guideScope => 'Chaînes affichées';

  @override
  String get guideAllChannels => 'Toutes les chaînes';

  @override
  String get guideNow => 'Maintenant';

  @override
  String get guideToday => 'Aujourd\'hui';

  @override
  String get guideYesterday => 'Hier';

  @override
  String get guideTomorrow => 'Demain';

  @override
  String get guideEarlier => '2 h plus tôt';

  @override
  String get guideLater => '2 h plus tard';

  @override
  String get guideEmptyTitle => 'Aucun guide des programmes';

  @override
  String get guideEmptyBody =>
      'Importez le guide de vos sources, ou ajoutez une adresse ou un fichier XMLTV dans les réglages.';

  @override
  String get guideImport => 'Importer le guide';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Import du guide… $countString programmes';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Guide mis à jour : $programsString programmes, $channelsString chaînes associées.';
  }

  @override
  String guideFailed(String names) {
    return 'Guide indisponible : $names. L\'ancien guide est conservé.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString programmes · $date';
  }

  @override
  String get guideNeverRefreshed => 'Jamais actualisé';

  @override
  String get guideLastFailed => 'La dernière actualisation a échoué.';

  @override
  String get guideRefresh => 'Actualiser le guide';

  @override
  String get guideAddUrl => 'Ajouter une adresse';

  @override
  String get guideAddFile => 'Ajouter un fichier';

  @override
  String get guideUrlHint => 'Adresse du guide XMLTV';

  @override
  String get guideWatchLive => 'Regarder en direct';

  @override
  String get guideReplay => 'Revoir';

  @override
  String get guideReplayOff => 'Replay indisponible pour ce programme.';

  @override
  String get guideComing => 'À venir';

  @override
  String get guideChannel => 'Programme de la chaîne';

  @override
  String get guideLink => 'Associer au guide';

  @override
  String get guideLinkHint => 'Nom ou identifiant de la chaîne';

  @override
  String get guideNoProgram => 'Aucun programme pour cette chaîne.';

  @override
  String get guideNoChannels =>
      'Aucune chaîne de cette sélection n\'a de guide.';

  @override
  String get backupTitle => 'Sauvegarde';

  @override
  String get backupExport => 'Créer une sauvegarde';

  @override
  String get backupImport => 'Restaurer une sauvegarde';

  @override
  String get backupRestore => 'Restaurer';

  @override
  String get backupSecrets => 'Inclure les mots de passe';

  @override
  String get backupSecretsBody =>
      'Le fichier est alors chiffré par votre phrase de passe. Sinon, mots de passe et adresses complètes des playlists n\'y sont pas enregistrés.';

  @override
  String get backupPassphrase => 'Phrase de passe';

  @override
  String get backupPassphraseAgain => 'Confirmer la phrase de passe';

  @override
  String get backupPassphraseShort => 'Au moins 8 caractères.';

  @override
  String get backupPassphraseMismatch => 'Les deux phrases sont différentes.';

  @override
  String get backupSaved => 'Sauvegarde enregistrée.';

  @override
  String get backupFailed => 'Impossible d\'écrire ce fichier.';

  @override
  String get backupNotOurs => 'Ce fichier n\'est pas une sauvegarde Chud IPTV.';

  @override
  String get backupTooNew =>
      'Cette sauvegarde vient d\'une version plus récente de l\'app.';

  @override
  String get backupDamaged => 'Cette sauvegarde est endommagée.';

  @override
  String get backupWrongPassphrase =>
      'Phrase de passe incorrecte, ou fichier modifié.';

  @override
  String get backupConfirmTitle => 'Restaurer cette sauvegarde ?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Sauvegarde du $date. Sources : $sources, listes : $lists, favoris : $favorites. Vos données actuelles sont gardées et complétées ; seuls les réglages sont remplacés.';
  }

  @override
  String get backupRestored => 'Restauration terminée.';

  @override
  String backupIncomplete(int count) {
    return 'Restauration terminée. Sources à compléter : $count. Leur mot de passe ou adresse n\'était pas dans le fichier.';
  }

  @override
  String get autoTitle => 'Actualisation automatique';

  @override
  String get autoOff => 'Désactivée';

  @override
  String autoEvery(int hours) {
    return 'Toutes les $hours h';
  }

  @override
  String get dataTitle => 'Données locales';

  @override
  String cacheLine(String size) {
    return 'Cache des logos : $size Mo';
  }

  @override
  String get cacheClear => 'Vider le cache';

  @override
  String get cacheCleared => 'Cache vidé.';

  @override
  String get wipeButton => 'Effacer toutes les données';

  @override
  String get wipeTitle => 'Tout effacer ?';

  @override
  String get wipeBody =>
      'Sources, favoris, guide, téléchargements et réglages seront supprimés de cet appareil. Cette action est définitive.';

  @override
  String get wipeConfirm => 'Tout effacer';

  @override
  String get updateTitle => 'Mises à jour';

  @override
  String get updateAuto => 'Vérifier automatiquement';

  @override
  String get updateCheck => 'Rechercher une mise à jour';

  @override
  String get updateChecking => 'Recherche en cours…';

  @override
  String get updateLatest => 'Vous avez la dernière version.';

  @override
  String updateAvailable(String version) {
    return 'Version $version disponible';
  }

  @override
  String get updateSee => 'Voir';

  @override
  String get updateInstall => 'Mettre à jour';

  @override
  String updateDownloading(int percent) {
    return 'Téléchargement… $percent %';
  }

  @override
  String get updateVerifying => 'Vérification du fichier…';

  @override
  String get updateRestarting => 'Installation : l\'app va redémarrer.';

  @override
  String get updateConfirmSystem =>
      'Confirmez l\'installation dans la fenêtre du système.';

  @override
  String get updateOpened =>
      'Le téléchargement s\'est ouvert dans votre navigateur : installez-le, puis relancez l\'app.';

  @override
  String get updateCancelled => 'Mise à jour annulée.';

  @override
  String get updateNoChannel =>
      'Cette version n\'est reliée à aucun canal de mise à jour.';

  @override
  String get updateFailedNetwork => 'Serveur de mise à jour injoignable.';

  @override
  String get updateFailedSignature =>
      'Signature invalide : mise à jour refusée.';

  @override
  String get updateFailedIntegrity =>
      'Fichier corrompu : rien n\'a été installé.';

  @override
  String get updateFailedInstall => 'L\'installation a échoué.';

  @override
  String updateDone(String version) {
    return 'Mise à jour vers la version $version installée.';
  }

  @override
  String updateNotApplied(String version) {
    return 'La mise à jour vers la version $version n\'a pas pu s\'installer : l\'ancienne version reste en place.';
  }

  @override
  String get navDownloads => 'Téléchargements';

  @override
  String get downloadAction => 'Télécharger';

  @override
  String get downloadSeason => 'Télécharger la saison';

  @override
  String downloadAdded(String title) {
    return 'Ajouté aux téléchargements : $title';
  }

  @override
  String get downloadPlay => 'Lire le fichier';

  @override
  String get downloadEmptyTitle => 'Aucun téléchargement';

  @override
  String get downloadEmptyBody =>
      'Téléchargez un film depuis sa fiche, ou un épisode depuis sa série, pour le regarder sans connexion.';

  @override
  String get downloadQueued => 'En attente';

  @override
  String get downloadPaused => 'En pause';

  @override
  String get downloadHeld => 'En attente de la fin de la lecture';

  @override
  String get downloadPause => 'Mettre en pause';

  @override
  String get downloadResume => 'Reprendre';

  @override
  String get downloadDeleteTitle => 'Supprimer ce téléchargement ?';

  @override
  String downloadDeleteBody(String title) {
    return '$title sera retiré de cet appareil.';
  }

  @override
  String get downloadFolder => 'Dossier des téléchargements';

  @override
  String downloadSizeMb(String size) {
    return '$size Mo';
  }

  @override
  String downloadSizeGb(String size) {
    return '$size Go';
  }

  @override
  String get downloadErrorNetwork =>
      'Connexion perdue. Le fichier est gardé : la reprise continue où elle s\'est arrêtée.';

  @override
  String get downloadErrorServer =>
      'Le serveur a refusé. Une autre lecture utilise peut-être votre connexion.';

  @override
  String get downloadErrorFormat =>
      'Ce contenu est diffusé par morceaux et ne peut pas être téléchargé.';

  @override
  String get downloadErrorDisk =>
      'Écriture impossible : espace disque insuffisant ou dossier inaccessible.';

  @override
  String get downloadErrorSource =>
      'La source de ce téléchargement n\'existe plus.';

  @override
  String get downloadErrorMissing => 'Le fichier a été déplacé ou supprimé.';

  @override
  String get downloadFolderChoose => 'Choisir un dossier';

  @override
  String get downloadFolderReset => 'Dossier par défaut';

  @override
  String get downloadFolderApp => 'Dossier de l\'app, supprimé avec elle';

  @override
  String get downloadFolderHint =>
      'Vaut pour les prochains téléchargements. Ceux déjà terminés restent où ils sont.';

  @override
  String get favChooseBody =>
      'Vous n\'avez pas encore de liste. Où voulez-vous ranger ce favori ?';

  @override
  String get favGlobal => 'Favoris généraux';

  @override
  String get settingsPhoneTitle => 'Lecture sur téléphone';

  @override
  String get settingsPip => 'Image dans l\'image';

  @override
  String get settingsPipBody =>
      'La vidéo continue dans une petite fenêtre quand vous quittez l\'app. Un bouton apparaît dans le lecteur.';

  @override
  String get settingsRadio => 'Mode radio';

  @override
  String get settingsRadioBody =>
      'Le son continue quand le téléphone est verrouillé ou l\'app en arrière-plan. Un bouton apparaît dans le lecteur.';

  @override
  String get playerPipOn => 'Image dans l\'image activée';

  @override
  String get playerPipOff => 'Image dans l\'image désactivée';

  @override
  String get playerRadioOn => 'Mode radio activé';

  @override
  String get playerRadioOff => 'Mode radio désactivé';

  @override
  String get radioNotificationStop => 'Arrêter';
}
