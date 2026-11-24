import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('vi'),
  ];

  /// No description provided for @navLive.
  ///
  /// In fr, this message translates to:
  /// **'Direct'**
  String get navLive;

  /// No description provided for @navFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navFavorites;

  /// No description provided for @navMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films'**
  String get navMovies;

  /// No description provided for @navSeries.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get navSeries;

  /// No description provided for @navSources.
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get navSources;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une source pour commencer : un compte Xtream Codes ou une playlist M3U. L\'app ne fournit aucune chaîne, tout reste sur cet appareil.'**
  String get welcomeBody;

  /// No description provided for @addSource.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une source'**
  String get addSource;

  /// No description provided for @allSources.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les sources'**
  String get allSources;

  /// No description provided for @allCategories.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get allCategories;

  /// No description provided for @noCategoryName.
  ///
  /// In fr, this message translates to:
  /// **'Sans catégorie'**
  String get noCategoryName;

  /// No description provided for @filterCategories.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer les catégories'**
  String get filterCategories;

  /// No description provided for @emptyList.
  ///
  /// In fr, this message translates to:
  /// **'Rien à afficher ici.'**
  String get emptyList;

  /// No description provided for @emptyWhileImporting.
  ///
  /// In fr, this message translates to:
  /// **'Import en cours, le catalogue apparaîtra dès qu\'il sera prêt.'**
  String get emptyWhileImporting;

  /// No description provided for @itemCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun élément} =1{1 élément} other{{count} éléments}}'**
  String itemCount(int count);

  /// No description provided for @viewCompact.
  ///
  /// In fr, this message translates to:
  /// **'Liste compacte'**
  String get viewCompact;

  /// No description provided for @viewDetailed.
  ///
  /// In fr, this message translates to:
  /// **'Liste détaillée'**
  String get viewDetailed;

  /// No description provided for @viewGrid.
  ///
  /// In fr, this message translates to:
  /// **'Grille'**
  String get viewGrid;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour « {query} ».'**
  String noResults(String query);

  /// No description provided for @sortLabel.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortLabel;

  /// No description provided for @sortSource.
  ///
  /// In fr, this message translates to:
  /// **'Ordre de la source'**
  String get sortSource;

  /// No description provided for @sortNameAsc.
  ///
  /// In fr, this message translates to:
  /// **'Nom (A → Z)'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In fr, this message translates to:
  /// **'Nom (Z → A)'**
  String get sortNameDesc;

  /// No description provided for @sortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Ajouts récents'**
  String get sortRecent;

  /// No description provided for @sortRating.
  ///
  /// In fr, this message translates to:
  /// **'Mieux notés'**
  String get sortRating;

  /// No description provided for @filterLabel.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filterLabel;

  /// No description provided for @filterCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays ou langue'**
  String get filterCountry;

  /// No description provided for @filterAllCountries.
  ///
  /// In fr, this message translates to:
  /// **'Tous les pays'**
  String get filterAllCountries;

  /// No description provided for @itemSource.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get itemSource;

  /// No description provided for @itemCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get itemCategory;

  /// No description provided for @itemCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays ou langue'**
  String get itemCountry;

  /// No description provided for @itemFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get itemFormat;

  /// No description provided for @itemRating.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get itemRating;

  /// No description provided for @favAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get favAdd;

  /// No description provided for @favRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get favRemove;

  /// No description provided for @favPickLists.
  ///
  /// In fr, this message translates to:
  /// **'Listes de favoris'**
  String get favPickLists;

  /// No description provided for @favNewList.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle liste'**
  String get favNewList;

  /// No description provided for @favDefaultName.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favDefaultName;

  /// No description provided for @favListName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la liste'**
  String get favListName;

  /// No description provided for @favListIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get favListIcon;

  /// No description provided for @favRename.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la liste'**
  String get favRename;

  /// No description provided for @favDeleteList.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la liste'**
  String get favDeleteList;

  /// No description provided for @favDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la liste « {name} » ? Les chaînes restent dans le catalogue.'**
  String favDeleteConfirm(String name);

  /// No description provided for @favEmptyLists.
  ///
  /// In fr, this message translates to:
  /// **'Créez vos listes : sport, info, enfants… Une même chaîne peut être dans plusieurs listes.'**
  String get favEmptyLists;

  /// No description provided for @favEmptyList.
  ///
  /// In fr, this message translates to:
  /// **'Cette liste est vide. Ajoutez des chaînes avec l\'étoile.'**
  String get favEmptyList;

  /// No description provided for @favManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les listes'**
  String get favManage;

  /// No description provided for @favMoveUp.
  ///
  /// In fr, this message translates to:
  /// **'Monter'**
  String get favMoveUp;

  /// No description provided for @favMoveDown.
  ///
  /// In fr, this message translates to:
  /// **'Descendre'**
  String get favMoveDown;

  /// No description provided for @favListLine.
  ///
  /// In fr, this message translates to:
  /// **'{name} ({count})'**
  String favListLine(String name, int count);

  /// No description provided for @filteredIntro.
  ///
  /// In fr, this message translates to:
  /// **'FILTERED regroupe automatiquement les groupes de vos sources par pays, région et thème. L\'onglet Direct et vos playlists ne changent pas.'**
  String get filteredIntro;

  /// No description provided for @filteredNoGroups.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe à analyser pour le moment. Actualisez une source.'**
  String get filteredNoGroups;

  /// No description provided for @filteredAnalyze.
  ///
  /// In fr, this message translates to:
  /// **'Organiser automatiquement'**
  String get filteredAnalyze;

  /// No description provided for @filteredManage.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get filteredManage;

  /// No description provided for @filteredReanalyze.
  ///
  /// In fr, this message translates to:
  /// **'Relancer l\'analyse et corriger'**
  String get filteredReanalyze;

  /// No description provided for @filteredRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer le classement automatique'**
  String get filteredRestore;

  /// No description provided for @filteredRestoreConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Vos corrections manuelles seront oubliées. Vous verrez l\'aperçu avant de valider.'**
  String get filteredRestoreConfirm;

  /// No description provided for @filteredPreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du classement'**
  String get filteredPreviewTitle;

  /// No description provided for @filteredSummary.
  ///
  /// In fr, this message translates to:
  /// **'{groups} groupes rangés dans {nodes} catégories'**
  String filteredSummary(int groups, int nodes);

  /// No description provided for @filteredDelta.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la dernière analyse : {added} nouveaux, {removed} disparus'**
  String filteredDelta(int added, int removed);

  /// No description provided for @filteredNewGroups.
  ///
  /// In fr, this message translates to:
  /// **'{count} nouveaux groupes à ranger : ouvrir l\'aperçu'**
  String filteredNewGroups(int count);

  /// No description provided for @filteredToCheck.
  ///
  /// In fr, this message translates to:
  /// **'À vérifier ({count})'**
  String filteredToCheck(int count);

  /// No description provided for @filteredUnclassified.
  ///
  /// In fr, this message translates to:
  /// **'Non classés ({count})'**
  String filteredUnclassified(int count);

  /// No description provided for @filteredExcluded.
  ///
  /// In fr, this message translates to:
  /// **'Groupes exclus ({count})'**
  String filteredExcluded(int count);

  /// No description provided for @filteredGroupsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} groupes'**
  String filteredGroupsCount(int count);

  /// No description provided for @filteredValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider ce classement'**
  String get filteredValidate;

  /// No description provided for @filteredAccept.
  ///
  /// In fr, this message translates to:
  /// **'C\'est bon'**
  String get filteredAccept;

  /// No description provided for @filteredMove.
  ///
  /// In fr, this message translates to:
  /// **'Ranger dans…'**
  String get filteredMove;

  /// No description provided for @filteredExclude.
  ///
  /// In fr, this message translates to:
  /// **'Exclure du classement'**
  String get filteredExclude;

  /// No description provided for @filteredRestoreGroup.
  ///
  /// In fr, this message translates to:
  /// **'Réintégrer'**
  String get filteredRestoreGroup;

  /// No description provided for @filteredNewCategory.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle catégorie'**
  String get filteredNewCategory;

  /// No description provided for @filteredRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get filteredRename;

  /// No description provided for @filteredMerge.
  ///
  /// In fr, this message translates to:
  /// **'Fusionner dans…'**
  String get filteredMerge;

  /// No description provided for @sourcesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sources IPTV'**
  String get sourcesTitle;

  /// No description provided for @refreshAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout actualiser'**
  String get refreshAll;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @editSource.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editSource;

  /// No description provided for @deleteSource.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la source'**
  String get deleteSource;

  /// No description provided for @deleteSourceConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » et tout son catalogue de cet appareil ?'**
  String deleteSourceConfirm(String name);

  /// No description provided for @sourceEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activée'**
  String get sourceEnabled;

  /// No description provided for @makeDefault.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser par défaut'**
  String get makeDefault;

  /// No description provided for @isDefault.
  ///
  /// In fr, this message translates to:
  /// **'Source par défaut'**
  String get isDefault;

  /// No description provided for @kindXtream.
  ///
  /// In fr, this message translates to:
  /// **'Xtream Codes'**
  String get kindXtream;

  /// No description provided for @kindM3uUrl.
  ///
  /// In fr, this message translates to:
  /// **'Playlist en ligne'**
  String get kindM3uUrl;

  /// No description provided for @kindM3uFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier M3U'**
  String get kindM3uFile;

  /// No description provided for @countsLine.
  ///
  /// In fr, this message translates to:
  /// **'{live} chaînes · {movies} films · {series} séries'**
  String countsLine(int live, int movies, int series);

  /// No description provided for @neverRefreshed.
  ///
  /// In fr, this message translates to:
  /// **'Jamais actualisée'**
  String get neverRefreshed;

  /// No description provided for @refreshedAt.
  ///
  /// In fr, this message translates to:
  /// **'Actualisée le {date}'**
  String refreshedAt(String date);

  /// No description provided for @expiresAt.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement valable jusqu\'au {date}'**
  String expiresAt(String date);

  /// No description provided for @maxConnections.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 lecture simultanée} other{{count} lectures simultanées}}'**
  String maxConnections(int count);

  /// No description provided for @applyAnyway.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer quand même'**
  String get applyAnyway;

  /// No description provided for @reportDone.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » : {added} ajoutés, {updated} modifiés, {missing} disparus.'**
  String reportDone(String name, int added, int updated, int missing);

  /// No description provided for @stageConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur…'**
  String get stageConnecting;

  /// No description provided for @stageLive.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des chaînes…'**
  String get stageLive;

  /// No description provided for @stageMovies.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des films…'**
  String get stageMovies;

  /// No description provided for @stageSeries.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement des séries…'**
  String get stageSeries;

  /// No description provided for @stagePlaylist.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement de la playlist…'**
  String get stagePlaylist;

  /// No description provided for @stageWriting.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement du catalogue…'**
  String get stageWriting;

  /// No description provided for @stageWritingCount.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement : {count} éléments…'**
  String stageWritingCount(int count);

  /// No description provided for @stageQueued.
  ///
  /// In fr, this message translates to:
  /// **'En attente…'**
  String get stageQueued;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable. Vérifiez l\'adresse et votre connexion.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur met trop de temps à répondre.'**
  String get errorTimeout;

  /// No description provided for @errorCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe refusé par le serveur.'**
  String get errorCredentials;

  /// No description provided for @errorExpired.
  ///
  /// In fr, this message translates to:
  /// **'Cet abonnement a expiré.'**
  String get errorExpired;

  /// No description provided for @errorNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Adresse introuvable sur ce serveur.'**
  String get errorNotFound;

  /// No description provided for @errorNotPlaylist.
  ///
  /// In fr, this message translates to:
  /// **'Ce contenu n\'est pas une playlist M3U.'**
  String get errorNotPlaylist;

  /// No description provided for @errorInvalidData.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a renvoyé une réponse illisible.'**
  String get errorInvalidData;

  /// No description provided for @errorEmpty.
  ///
  /// In fr, this message translates to:
  /// **'La source est vide : le catalogue actuel est conservé.'**
  String get errorEmpty;

  /// No description provided for @errorSuspicious.
  ///
  /// In fr, this message translates to:
  /// **'Liste anormalement réduite ({detail}) : le catalogue actuel est conservé.'**
  String errorSuspicious(String detail);

  /// No description provided for @errorFileMissing.
  ///
  /// In fr, this message translates to:
  /// **'Fichier introuvable ou illisible.'**
  String get errorFileMissing;

  /// No description provided for @errorUnknown.
  ///
  /// In fr, this message translates to:
  /// **'L\'actualisation a échoué. Le catalogue actuel est conservé.'**
  String get errorUnknown;

  /// No description provided for @formNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle source'**
  String get formNewTitle;

  /// No description provided for @formEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la source'**
  String get formEditTitle;

  /// No description provided for @formName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get formName;

  /// No description provided for @formNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Salon, Abonnement 1'**
  String get formNameHint;

  /// No description provided for @formServer.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du serveur'**
  String get formServer;

  /// No description provided for @formUsername.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get formUsername;

  /// No description provided for @formPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get formPassword;

  /// No description provided for @formShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get formShowPassword;

  /// No description provided for @formPlaylistUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de la playlist (M3U ou M3U8)'**
  String get formPlaylistUrl;

  /// No description provided for @formFile.
  ///
  /// In fr, this message translates to:
  /// **'Fichier de playlist'**
  String get formFile;

  /// No description provided for @formChooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier'**
  String get formChooseFile;

  /// No description provided for @formNoFile.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier choisi'**
  String get formNoFile;

  /// No description provided for @formFileUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sélecteur de fichiers sur cet appareil.'**
  String get formFileUnavailable;

  /// No description provided for @formRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ obligatoire'**
  String get formRequired;

  /// No description provided for @formInvalidUrl.
  ///
  /// In fr, this message translates to:
  /// **'Adresse invalide'**
  String get formInvalidUrl;

  /// No description provided for @formContentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contenu à importer'**
  String get formContentTitle;

  /// No description provided for @formContentHint.
  ///
  /// In fr, this message translates to:
  /// **'Le direct est toujours importé. Sans films ni séries, le chargement est bien plus léger.'**
  String get formContentHint;

  /// No description provided for @formMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films'**
  String get formMovies;

  /// No description provided for @formSeries.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get formSeries;

  /// No description provided for @formContentRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Les éléments déjà importés, et leurs favoris, seront retirés de cet appareil.'**
  String get formContentRemoved;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du système'**
  String get languageSystem;

  /// No description provided for @settingsApp.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get settingsApp;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsPrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte, aucune télémétrie : vos sources et vos données restent sur cet appareil.'**
  String get settingsPrivacy;

  /// No description provided for @settingsShortcuts.
  ///
  /// In fr, this message translates to:
  /// **'Ctrl+F : rechercher · F5 : tout actualiser · Ctrl+1 à 9 : changer d\'onglet'**
  String get settingsShortcuts;

  /// No description provided for @playerPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get playerPlay;

  /// No description provided for @playerPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// No description provided for @playerPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get playerPrevious;

  /// No description provided for @playerNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get playerNext;

  /// No description provided for @playerRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir le flux'**
  String get playerRefresh;

  /// No description provided for @playerFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran'**
  String get playerFullscreen;

  /// No description provided for @playerExitFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le plein écran'**
  String get playerExitFullscreen;

  /// No description provided for @playerMute.
  ///
  /// In fr, this message translates to:
  /// **'Couper le son'**
  String get playerMute;

  /// No description provided for @playerUnmute.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir le son'**
  String get playerUnmute;

  /// No description provided for @playerLive.
  ///
  /// In fr, this message translates to:
  /// **'DIRECT'**
  String get playerLive;

  /// No description provided for @playerReconnecting.
  ///
  /// In fr, this message translates to:
  /// **'Reconnexion… ({attempt}/{total})'**
  String playerReconnecting(int attempt, int total);

  /// No description provided for @playerSignalLost.
  ///
  /// In fr, this message translates to:
  /// **'Signal perdu…'**
  String get playerSignalLost;

  /// No description provided for @playerFailedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture impossible'**
  String get playerFailedTitle;

  /// No description provided for @playerFailedBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce flux ne répond pas. Il est peut-être hors ligne, ou votre abonnement lit déjà sur un autre appareil.'**
  String get playerFailedBody;

  /// No description provided for @playerEndedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture terminée'**
  String get playerEndedTitle;

  /// No description provided for @playerBackToList.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la liste'**
  String get playerBackToList;

  /// No description provided for @externalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecteur externe'**
  String get externalTitle;

  /// No description provided for @externalOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir dans le lecteur externe'**
  String get externalOpen;

  /// No description provided for @externalNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun lecteur trouvé. VLC est utilisé automatiquement s\'il est installé.'**
  String get externalNone;

  /// No description provided for @externalFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lancer le lecteur externe. Vérifiez son emplacement dans les réglages.'**
  String get externalFailed;

  /// No description provided for @externalDefault.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser VLC'**
  String get externalDefault;

  /// No description provided for @seriesFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les épisodes.'**
  String get seriesFailed;

  /// No description provided for @seriesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun épisode disponible.'**
  String get seriesEmpty;

  /// No description provided for @seriesSeason.
  ///
  /// In fr, this message translates to:
  /// **'Saison {number}'**
  String seriesSeason(int number);

  /// No description provided for @seriesEpisode.
  ///
  /// In fr, this message translates to:
  /// **'Épisode {number}'**
  String seriesEpisode(int number);

  /// No description provided for @seriesMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{count} min'**
  String seriesMinutes(int count);

  /// No description provided for @navGuide.
  ///
  /// In fr, this message translates to:
  /// **'Guide'**
  String get navGuide;

  /// No description provided for @guideTitle.
  ///
  /// In fr, this message translates to:
  /// **'Guide des programmes'**
  String get guideTitle;

  /// No description provided for @guideScope.
  ///
  /// In fr, this message translates to:
  /// **'Chaînes affichées'**
  String get guideScope;

  /// No description provided for @guideAllChannels.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les chaînes'**
  String get guideAllChannels;

  /// No description provided for @guideNow.
  ///
  /// In fr, this message translates to:
  /// **'Maintenant'**
  String get guideNow;

  /// No description provided for @guideToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get guideToday;

  /// No description provided for @guideYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get guideYesterday;

  /// No description provided for @guideTomorrow.
  ///
  /// In fr, this message translates to:
  /// **'Demain'**
  String get guideTomorrow;

  /// No description provided for @guideEarlier.
  ///
  /// In fr, this message translates to:
  /// **'2 h plus tôt'**
  String get guideEarlier;

  /// No description provided for @guideLater.
  ///
  /// In fr, this message translates to:
  /// **'2 h plus tard'**
  String get guideLater;

  /// No description provided for @guideEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun guide des programmes'**
  String get guideEmptyTitle;

  /// No description provided for @guideEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Importez le guide de vos sources, ou ajoutez une adresse ou un fichier XMLTV dans les réglages.'**
  String get guideEmptyBody;

  /// No description provided for @guideImport.
  ///
  /// In fr, this message translates to:
  /// **'Importer le guide'**
  String get guideImport;

  /// No description provided for @guideImporting.
  ///
  /// In fr, this message translates to:
  /// **'Import du guide… {count} programmes'**
  String guideImporting(int count);

  /// No description provided for @guideDone.
  ///
  /// In fr, this message translates to:
  /// **'Guide mis à jour : {programs} programmes, {channels} chaînes associées.'**
  String guideDone(int programs, int channels);

  /// No description provided for @guideFailed.
  ///
  /// In fr, this message translates to:
  /// **'Guide indisponible : {names}. L\'ancien guide est conservé.'**
  String guideFailed(String names);

  /// No description provided for @guideSourceLine.
  ///
  /// In fr, this message translates to:
  /// **'{count} programmes · {date}'**
  String guideSourceLine(int count, String date);

  /// No description provided for @guideNeverRefreshed.
  ///
  /// In fr, this message translates to:
  /// **'Jamais actualisé'**
  String get guideNeverRefreshed;

  /// No description provided for @guideLastFailed.
  ///
  /// In fr, this message translates to:
  /// **'La dernière actualisation a échoué.'**
  String get guideLastFailed;

  /// No description provided for @guideRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser le guide'**
  String get guideRefresh;

  /// No description provided for @guideAddUrl.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une adresse'**
  String get guideAddUrl;

  /// No description provided for @guideAddFile.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un fichier'**
  String get guideAddFile;

  /// No description provided for @guideUrlHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du guide XMLTV'**
  String get guideUrlHint;

  /// No description provided for @guideWatchLive.
  ///
  /// In fr, this message translates to:
  /// **'Regarder en direct'**
  String get guideWatchLive;

  /// No description provided for @guideReplay.
  ///
  /// In fr, this message translates to:
  /// **'Revoir'**
  String get guideReplay;

  /// No description provided for @guideReplayOff.
  ///
  /// In fr, this message translates to:
  /// **'Replay indisponible pour ce programme.'**
  String get guideReplayOff;

  /// No description provided for @guideComing.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get guideComing;

  /// No description provided for @guideChannel.
  ///
  /// In fr, this message translates to:
  /// **'Programme de la chaîne'**
  String get guideChannel;

  /// No description provided for @guideLink.
  ///
  /// In fr, this message translates to:
  /// **'Associer au guide'**
  String get guideLink;

  /// No description provided for @guideLinkHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou identifiant de la chaîne'**
  String get guideLinkHint;

  /// No description provided for @guideNoProgram.
  ///
  /// In fr, this message translates to:
  /// **'Aucun programme pour cette chaîne.'**
  String get guideNoProgram;

  /// No description provided for @guideNoChannels.
  ///
  /// In fr, this message translates to:
  /// **'Aucune chaîne de cette sélection n\'a de guide.'**
  String get guideNoChannels;

  /// No description provided for @backupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get backupTitle;

  /// No description provided for @backupExport.
  ///
  /// In fr, this message translates to:
  /// **'Créer une sauvegarde'**
  String get backupExport;

  /// No description provided for @backupImport.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer une sauvegarde'**
  String get backupImport;

  /// No description provided for @backupRestore.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer'**
  String get backupRestore;

  /// No description provided for @backupSecrets.
  ///
  /// In fr, this message translates to:
  /// **'Inclure les mots de passe'**
  String get backupSecrets;

  /// No description provided for @backupSecretsBody.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier est alors chiffré par votre phrase de passe. Sinon, mots de passe et adresses complètes des playlists n\'y sont pas enregistrés.'**
  String get backupSecretsBody;

  /// No description provided for @backupPassphrase.
  ///
  /// In fr, this message translates to:
  /// **'Phrase de passe'**
  String get backupPassphrase;

  /// No description provided for @backupPassphraseAgain.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la phrase de passe'**
  String get backupPassphraseAgain;

  /// No description provided for @backupPassphraseShort.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères.'**
  String get backupPassphraseShort;

  /// No description provided for @backupPassphraseMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux phrases sont différentes.'**
  String get backupPassphraseMismatch;

  /// No description provided for @backupSaved.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde enregistrée.'**
  String get backupSaved;

  /// No description provided for @backupFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'écrire ce fichier.'**
  String get backupFailed;

  /// No description provided for @backupNotOurs.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une sauvegarde Chud IPTV.'**
  String get backupNotOurs;

  /// No description provided for @backupTooNew.
  ///
  /// In fr, this message translates to:
  /// **'Cette sauvegarde vient d\'une version plus récente de l\'app.'**
  String get backupTooNew;

  /// No description provided for @backupDamaged.
  ///
  /// In fr, this message translates to:
  /// **'Cette sauvegarde est endommagée.'**
  String get backupDamaged;

  /// No description provided for @backupWrongPassphrase.
  ///
  /// In fr, this message translates to:
  /// **'Phrase de passe incorrecte, ou fichier modifié.'**
  String get backupWrongPassphrase;

  /// No description provided for @backupConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer cette sauvegarde ?'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde du {date}. Sources : {sources}, listes : {lists}, favoris : {favorites}. Vos données actuelles sont gardées et complétées ; seuls les réglages sont remplacés.'**
  String backupConfirmBody(String date, int sources, int lists, int favorites);

  /// No description provided for @backupRestored.
  ///
  /// In fr, this message translates to:
  /// **'Restauration terminée.'**
  String get backupRestored;

  /// No description provided for @backupIncomplete.
  ///
  /// In fr, this message translates to:
  /// **'Restauration terminée. Sources à compléter : {count}. Leur mot de passe ou adresse n\'était pas dans le fichier.'**
  String backupIncomplete(int count);

  /// No description provided for @autoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actualisation automatique'**
  String get autoTitle;

  /// No description provided for @autoOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivée'**
  String get autoOff;

  /// No description provided for @autoEvery.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les {hours} h'**
  String autoEvery(int hours);

  /// No description provided for @dataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Données locales'**
  String get dataTitle;

  /// No description provided for @cacheLine.
  ///
  /// In fr, this message translates to:
  /// **'Cache des logos : {size} Mo'**
  String cacheLine(String size);

  /// No description provided for @cacheClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider le cache'**
  String get cacheClear;

  /// No description provided for @cacheCleared.
  ///
  /// In fr, this message translates to:
  /// **'Cache vidé.'**
  String get cacheCleared;

  /// No description provided for @wipeButton.
  ///
  /// In fr, this message translates to:
  /// **'Effacer toutes les données'**
  String get wipeButton;

  /// No description provided for @wipeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer ?'**
  String get wipeTitle;

  /// No description provided for @wipeBody.
  ///
  /// In fr, this message translates to:
  /// **'Sources, favoris, guide, téléchargements et réglages seront supprimés de cet appareil. Cette action est définitive.'**
  String get wipeBody;

  /// No description provided for @wipeConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get wipeConfirm;

  /// No description provided for @updateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mises à jour'**
  String get updateTitle;

  /// No description provided for @updateAuto.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier automatiquement'**
  String get updateAuto;

  /// No description provided for @updateCheck.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une mise à jour'**
  String get updateCheck;

  /// No description provided for @updateChecking.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en cours…'**
  String get updateChecking;

  /// No description provided for @updateLatest.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez la dernière version.'**
  String get updateLatest;

  /// No description provided for @updateAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Version {version} disponible'**
  String updateAvailable(String version);

  /// No description provided for @updateSee.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get updateSee;

  /// No description provided for @updateInstall.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get updateInstall;

  /// No description provided for @updateDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement… {percent} %'**
  String updateDownloading(int percent);

  /// No description provided for @updateVerifying.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du fichier…'**
  String get updateVerifying;

  /// No description provided for @updateRestarting.
  ///
  /// In fr, this message translates to:
  /// **'Installation : l\'app va redémarrer.'**
  String get updateRestarting;

  /// No description provided for @updateConfirmSystem.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez l\'installation dans la fenêtre du système.'**
  String get updateConfirmSystem;

  /// No description provided for @updateOpened.
  ///
  /// In fr, this message translates to:
  /// **'Le téléchargement s\'est ouvert dans votre navigateur : installez-le, puis relancez l\'app.'**
  String get updateOpened;

  /// No description provided for @updateCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour annulée.'**
  String get updateCancelled;

  /// No description provided for @updateNoChannel.
  ///
  /// In fr, this message translates to:
  /// **'Cette version n\'est reliée à aucun canal de mise à jour.'**
  String get updateNoChannel;

  /// No description provided for @updateFailedNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Serveur de mise à jour injoignable.'**
  String get updateFailedNetwork;

  /// No description provided for @updateFailedSignature.
  ///
  /// In fr, this message translates to:
  /// **'Signature invalide : mise à jour refusée.'**
  String get updateFailedSignature;

  /// No description provided for @updateFailedIntegrity.
  ///
  /// In fr, this message translates to:
  /// **'Fichier corrompu : rien n\'a été installé.'**
  String get updateFailedIntegrity;

  /// No description provided for @updateFailedInstall.
  ///
  /// In fr, this message translates to:
  /// **'L\'installation a échoué.'**
  String get updateFailedInstall;

  /// No description provided for @updateDone.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour vers la version {version} installée.'**
  String updateDone(String version);

  /// No description provided for @updateNotApplied.
  ///
  /// In fr, this message translates to:
  /// **'La mise à jour vers la version {version} n\'a pas pu s\'installer : l\'ancienne version reste en place.'**
  String updateNotApplied(String version);

  /// No description provided for @navDownloads.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements'**
  String get navDownloads;

  /// No description provided for @downloadAction.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get downloadAction;

  /// No description provided for @downloadSeason.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger la saison'**
  String get downloadSeason;

  /// No description provided for @downloadAdded.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté aux téléchargements : {title}'**
  String downloadAdded(String title);

  /// No description provided for @downloadPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire le fichier'**
  String get downloadPlay;

  /// No description provided for @downloadEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun téléchargement'**
  String get downloadEmptyTitle;

  /// No description provided for @downloadEmptyBody.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargez un film depuis sa fiche, ou un épisode depuis sa série, pour le regarder sans connexion.'**
  String get downloadEmptyBody;

  /// No description provided for @downloadQueued.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get downloadQueued;

  /// No description provided for @downloadPaused.
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get downloadPaused;

  /// No description provided for @downloadHeld.
  ///
  /// In fr, this message translates to:
  /// **'En attente de la fin de la lecture'**
  String get downloadHeld;

  /// No description provided for @downloadPause.
  ///
  /// In fr, this message translates to:
  /// **'Mettre en pause'**
  String get downloadPause;

  /// No description provided for @downloadResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get downloadResume;

  /// No description provided for @downloadDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce téléchargement ?'**
  String get downloadDeleteTitle;

  /// No description provided for @downloadDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'{title} sera retiré de cet appareil.'**
  String downloadDeleteBody(String title);

  /// No description provided for @downloadFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier des téléchargements'**
  String get downloadFolder;

  /// No description provided for @downloadSizeMb.
  ///
  /// In fr, this message translates to:
  /// **'{size} Mo'**
  String downloadSizeMb(String size);

  /// No description provided for @downloadSizeGb.
  ///
  /// In fr, this message translates to:
  /// **'{size} Go'**
  String downloadSizeGb(String size);

  /// No description provided for @downloadErrorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion perdue. Le fichier est gardé : la reprise continue où elle s\'est arrêtée.'**
  String get downloadErrorNetwork;

  /// No description provided for @downloadErrorServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a refusé. Une autre lecture utilise peut-être votre connexion.'**
  String get downloadErrorServer;

  /// No description provided for @downloadErrorFormat.
  ///
  /// In fr, this message translates to:
  /// **'Ce contenu est diffusé par morceaux et ne peut pas être téléchargé.'**
  String get downloadErrorFormat;

  /// No description provided for @downloadErrorDisk.
  ///
  /// In fr, this message translates to:
  /// **'Écriture impossible : espace disque insuffisant ou dossier inaccessible.'**
  String get downloadErrorDisk;

  /// No description provided for @downloadErrorSource.
  ///
  /// In fr, this message translates to:
  /// **'La source de ce téléchargement n\'existe plus.'**
  String get downloadErrorSource;

  /// No description provided for @downloadErrorMissing.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier a été déplacé ou supprimé.'**
  String get downloadErrorMissing;

  /// No description provided for @downloadFolderChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un dossier'**
  String get downloadFolderChoose;

  /// No description provided for @downloadFolderReset.
  ///
  /// In fr, this message translates to:
  /// **'Dossier par défaut'**
  String get downloadFolderReset;

  /// No description provided for @downloadFolderApp.
  ///
  /// In fr, this message translates to:
  /// **'Dossier de l\'app, supprimé avec elle'**
  String get downloadFolderApp;

  /// No description provided for @downloadFolderHint.
  ///
  /// In fr, this message translates to:
  /// **'Vaut pour les prochains téléchargements. Ceux déjà terminés restent où ils sont.'**
  String get downloadFolderHint;

  /// No description provided for @favChooseBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore de liste. Où voulez-vous ranger ce favori ?'**
  String get favChooseBody;

  /// No description provided for @favGlobal.
  ///
  /// In fr, this message translates to:
  /// **'Favoris généraux'**
  String get favGlobal;

  /// No description provided for @settingsPhoneTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture sur téléphone'**
  String get settingsPhoneTitle;

  /// No description provided for @settingsPip.
  ///
  /// In fr, this message translates to:
  /// **'Image dans l\'image'**
  String get settingsPip;

  /// No description provided for @settingsPipBody.
  ///
  /// In fr, this message translates to:
  /// **'La vidéo continue dans une petite fenêtre quand vous quittez l\'app. Un bouton apparaît dans le lecteur.'**
  String get settingsPipBody;

  /// No description provided for @settingsRadio.
  ///
  /// In fr, this message translates to:
  /// **'Mode radio'**
  String get settingsRadio;

  /// No description provided for @settingsRadioBody.
  ///
  /// In fr, this message translates to:
  /// **'Le son continue quand le téléphone est verrouillé ou l\'app en arrière-plan. Un bouton apparaît dans le lecteur.'**
  String get settingsRadioBody;

  /// No description provided for @playerPipOn.
  ///
  /// In fr, this message translates to:
  /// **'Image dans l\'image activée'**
  String get playerPipOn;

  /// No description provided for @playerPipOff.
  ///
  /// In fr, this message translates to:
  /// **'Image dans l\'image désactivée'**
  String get playerPipOff;

  /// No description provided for @playerRadioOn.
  ///
  /// In fr, this message translates to:
  /// **'Mode radio activé'**
  String get playerRadioOn;

  /// No description provided for @playerRadioOff.
  ///
  /// In fr, this message translates to:
  /// **'Mode radio désactivé'**
  String get playerRadioOff;

  /// No description provided for @radioNotificationStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get radioNotificationStop;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'pt',
    'ru',
    'tr',
    'vi',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
