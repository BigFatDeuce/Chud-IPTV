import 'dart:io';

import 'package:chud_iptv/app_controller.dart';
import 'package:chud_iptv/app_scope.dart';
import 'package:chud_iptv/data/repository.dart';
import 'package:chud_iptv/data/settings.dart';
import 'package:chud_iptv/import/importer.dart';
import 'package:chud_iptv/l10n/app_localizations.dart';
import 'package:chud_iptv/main.dart';
import 'package:chud_iptv/models/catalog.dart';
import 'package:chud_iptv/models/download.dart';
import 'package:chud_iptv/models/source.dart';
import 'package:chud_iptv/screens/source_form.dart';
import 'package:chud_iptv/screens/sources_screen.dart';
import 'package:chud_iptv/theme/app_theme.dart';
import 'package:chud_iptv/theme/tokens.dart';
import 'package:chud_iptv/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faux dépôt : tout est en mémoire, sans isolat, pour rester dans le temps simulé des tests.
class FakeRepository implements Repository {
  @override
  Future<List<EpgSource>> epgSources() async => const [];

  @override
  Future<List<Download>> downloads() async => const [];

  @override
  Future<int> addEpgSource(String name, String url, {String path = '', int? sourceId}) async => 1;

  @override
  Future<void> relinkGuide() async {}

  @override
  Future<void> resolvePending() async {}

  FakeRepository(this.items, {this.list = const []});

  final List<Item> items;
  List<Source> list;
  Source? added;
  final createdLists = <String>[];
  final favorites = <int>[];

  @override
  Future<int> createFavoriteList(String name, String icon) async {
    createdLists.add(name);
    return createdLists.length;
  }

  @override
  Future<void> addToFavoriteList(int listId, int itemId) async => favorites.add(itemId);

  @override
  Future<List<Source>> sources() async => list;
  @override
  Future<Map<String, String>> settings() async => const {};
  @override
  Future<void> saveSetting(String key, String value) async {}
  @override
  Future<int> addSource(Source s) async {
    added = s;
    list = [...list, Source(id: 1, name: s.name, kind: s.kind, url: s.url, withMovies: s.withMovies, withSeries: s.withSeries, isDefault: true)];
    return 1;
  }

  @override
  Future<List<Category>> categories(ItemType type, int? sourceId) async => [
        Category(id: 1, sourceId: 1, type: type, remoteId: '1', name: 'France', itemCount: items.length),
        Category(id: 2, sourceId: 1, type: type, remoteId: '2', name: 'Sport', itemCount: 0),
      ];
  @override
  Future<int> count(BrowseQuery q) async => items.length;
  @override
  Future<List<Item>> page(BrowseQuery q, int offset, int limit) async => items.skip(offset).take(limit).toList();
  @override
  Future<StreamInfo?> streamInfo(int itemId) async => null;
  @override
  Future<List<FavoriteList>> favoriteLists() async => const [];
  @override
  Future<Map<int, Set<int>>> favoriteMemberships() async => const {};
  @override
  Future<String?> loadSetting(String key) async => null;
  @override
  Future<Map<int, String>> dominantCountries() async => const {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Item item(int i, [ItemType type = ItemType.live]) => Item(
      id: i,
      sourceId: 1,
      type: type,
      name: 'Chaîne $i avec un nom assez long pour déborder sur un petit écran de téléphone',
      logo: '',
      categoryName: 'France',
      country: 'FR',
      rating: null,
      extension: '',
    );

const source = Source(id: 1, name: 'Abonnement', kind: SourceKind.xtream, url: 'http://x.example', isDefault: true, liveCount: 3, movieCount: 2, seriesCount: 1);

Future<AppController> pumpApp(WidgetTester tester, Repository repository, {Size size = const Size(390, 800), String lang = 'fr'}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controller = AppController(
    repository: repository,
    dbPath: '',
    tempDir: Directory.systemTemp.path,
    playlistsDir: Directory.systemTemp.path,
    runner: (_, _) async => const ImportReport(),
  );
  await controller.start();
  controller.settings = controller.settings.copyWith(language: () => lang);
  await tester.pumpWidget(ChudApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  tearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);

  testWidgets('premier lancement : accueil et bouton ciblé', (tester) async {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    await pumpApp(tester, FakeRepository(const []));
    expect(find.text('Ajouter une source'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<FilledButton>(), isNotNull,
        reason: 'la télécommande a besoin d\'un point de départ');
  });

  testWidgets('au doigt, rien n\'est ciblé d\'office', (tester) async {
    await pumpApp(tester, FakeRepository(const []));
    expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<FilledButton>(), isNull);
  });

  group('les tailles d\'écran ne provoquent aucun débordement', () {
    for (final (name, size) in [('petit téléphone', Size(320, 568)), ('téléphone', Size(390, 800)), ('TV', Size(960, 540)), ('PC', Size(1400, 900))]) {
      for (final lang in const ['fr', 'en', 'es', 'pt', 'de', 'it', 'ru', 'tr', 'id', 'vi']) {
        testWidgets('$name en $lang', (tester) async {
          final repository = FakeRepository([for (var i = 0; i < 400; i++) item(i)], list: const [source]);
          final c = await pumpApp(tester, repository, size: size, lang: lang);
          for (final mode in ViewMode.values) {
            c.setView(ItemType.live, mode);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        });
      }
    }
  });

  testWidgets('la liste ne construit que ce qui est visible', (tester) async {
    await pumpApp(tester, FakeRepository([for (var i = 0; i < 100000; i++) item(i)], list: const [source]));
    final rows = find.byType(FocusTile).evaluate().length;
    expect(rows, lessThan(40));
  });

  testWidgets('sans films ni séries, les onglets disparaissent', (tester) async {
    const noVod = Source(id: 1, name: 'A', kind: SourceKind.xtream, isDefault: true, withMovies: false, withSeries: false);
    await pumpApp(tester, FakeRepository(const [], list: const [noVod]), size: const Size(1200, 800));
    expect(find.text('FILMS'), findsNothing);
    expect(find.text('SÉRIES'), findsNothing);
    expect(find.text('DIRECT'), findsOneWidget);
    expect(find.text('FAVORIS'), findsOneWidget);
    expect(find.text('FILTERED'), findsOneWidget);
  });

  group('raccourcis clavier', () {
    testWidgets('Ctrl+F place le curseur dans la recherche', (tester) async {
      await pumpApp(tester, FakeRepository([for (var i = 0; i < 5; i++) item(i)], list: const [source]), size: const Size(1200, 800));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      final focused = FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<TextField>();
      expect(focused?.decoration?.hintText, 'Rechercher');
    });

    testWidgets('Ctrl+chiffre change d\'onglet', (tester) async {
      await pumpApp(tester, FakeRepository(const [], list: const [source]), size: const Size(1200, 800));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Nouvelle liste'), findsOneWidget);
    });
  });

  testWidgets('guide sans programme : proposition d import, sans fausse grille', (tester) async {
    await pumpApp(tester, FakeRepository(const [], list: const [source]), size: const Size(1200, 800));
    await tester.tap(find.text('GUIDE'));
    await tester.pumpAndSettle();
    expect(find.text('Importer le guide'), findsOneWidget);
  });

  testWidgets('feuille du bas : la dernière ligne reste au-dessus de la barre Android', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(
      // Au-dessus du Navigator : c'est ce que voit une feuille, comme avec la vraie barre d'Android.
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(padding: const EdgeInsets.only(bottom: 48), viewPadding: const EdgeInsets.only(bottom: 48)),
        child: child!,
      ),
      home: Builder(builder: (c) {
        context = c;
        return const Scaffold();
      }),
    ));
    showAppSheet<void>(context: context, builder: (_) => const SizedBox(height: 60, key: ValueKey('ligne')));
    await tester.pumpAndSettle();
    final screen = tester.getRect(find.byType(Scaffold).first).bottom;
    expect(tester.getBottomLeft(find.byKey(const ValueKey('ligne'))).dy, lessThanOrEqualTo(screen - 48));
  });

  group('premier favori', () {
    Future<FakeRepository> open(WidgetTester tester) async {
      final repository = FakeRepository([item(7)], list: const [source]);
      await pumpApp(tester, repository, size: const Size(1200, 800));
      await tester.tap(find.byIcon(Icons.star_border).first);
      await tester.pumpAndSettle();
      return repository;
    }

    testWidgets('rien n\'est ajouté sans que l\'utilisateur choisisse', (tester) async {
      final repository = await open(tester);
      expect(find.text('Favoris généraux'), findsOneWidget);
      expect(find.text('Nouvelle liste'), findsOneWidget);
      expect(repository.favorites, isEmpty);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repository.createdLists, isEmpty);
      expect(repository.favorites, isEmpty);
    });

    testWidgets('favoris généraux', (tester) async {
      final repository = await open(tester);
      await tester.tap(find.text('Favoris généraux'));
      await tester.pumpAndSettle();
      expect(repository.createdLists, ['Favoris']);
      expect(repository.favorites, [7]);
    });

    testWidgets('nouvelle liste, nommée par l\'utilisateur', (tester) async {
      final repository = await open(tester);
      await tester.tap(find.text('Nouvelle liste'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Sport');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(repository.createdLists, ['Sport']);
      expect(repository.favorites, [7]);
    });

    testWidgets('nouvelle liste abandonnée : aucun favori', (tester) async {
      final repository = await open(tester);
      await tester.tap(find.text('Nouvelle liste'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(repository.favorites, isEmpty);
    });
  });

  group('télécommande', () {
    testWidgets('la ligne ciblée se voit, et l\'action part au bouton central', (tester) async {
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      await pumpApp(tester, FakeRepository([for (var i = 0; i < 20; i++) item(i)], list: const [source]), size: const Size(960, 540));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(find.byKey(FocusTile.highlightKey), findsOneWidget, reason: 'un seul élément porte le cadre');

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.text('France'), findsWidgets);
    });

    testWidgets('on peut quitter un champ de texte avec les flèches', (tester) async {
      tester.view.physicalSize = const Size(960, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Palette.night),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fr'),
        home: Builder(builder: (context) {
          return const Scaffold(body: FieldNavigation(child: Column(children: [TextField(key: Key('a')), TextField(key: Key('b'))])));
        }),
      ));
      await tester.tap(find.byKey(const Key('a')));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      final focused = tester.widget<EditableText>(find.descendant(of: find.byKey(const Key('b')), matching: find.byType(EditableText)));
      expect(focused.focusNode.hasFocus, isTrue);
    });
  });

  group('formulaire', () {
    Future<(FakeRepository, AppController)> open(WidgetTester tester) async {
      final repository = FakeRepository(const []);
      final c = await pumpApp(tester, repository, size: const Size(800, 1000));
      await tester.tap(find.text('Ajouter une source'));
      await tester.pumpAndSettle();
      return (repository, c);
    }

    testWidgets('champs obligatoires', (tester) async {
      final (repository, _) = await open(tester);
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Champ obligatoire'), findsNWidgets(3));
      expect(repository.added, isNull);
    });

    testWidgets('adresse invalide refusée', (tester) async {
      final (repository, _) = await open(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Adresse du serveur'), 'ftp://x');
      await tester.enterText(find.widgetWithText(TextFormField, "Nom d'utilisateur"), 'a');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), 'b');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      expect(find.text('Adresse invalide'), findsOneWidget);
      expect(repository.added, isNull);
    });

    testWidgets('ajout : films désactivés et nom déduit de l\'adresse', (tester) async {
      final (repository, _) = await open(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Adresse du serveur'), 'exemple.tv:8080/');
      await tester.enterText(find.widgetWithText(TextFormField, "Nom d'utilisateur"), 'alice');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), 'secret');
      await tester.tap(find.widgetWithText(SwitchListTile, 'Films'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();
      final added = repository.added!;
      expect(added.url, 'http://exemple.tv:8080');
      expect(added.name, 'exemple.tv');
      expect(added.withMovies, isFalse);
      expect(added.withSeries, isTrue);
      expect(find.byType(SourceForm), findsNothing);
    });

    testWidgets('mot de passe masqué par défaut', (tester) async {
      await open(tester);
      final field = tester.widget<EditableText>(find.descendant(of: find.widgetWithText(TextFormField, 'Mot de passe'), matching: find.byType(EditableText)));
      expect(field.obscureText, isTrue);
    });
  });

  group('fiche source', () {
    Widget card(Source s, AppController c, {Size size = const Size(390, 800)}) => AppScope(
          controller: c,
          child: MaterialApp(
            theme: buildAppTheme(Palette.night),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Scaffold(body: SingleChildScrollView(child: SourceCard(source: s))),
          ),
        );

    Future<AppController> controller() async {
      final c = AppController(repository: FakeRepository(const []), dbPath: '', tempDir: '', playlistsDir: '');
      await c.start();
      return c;
    }

    testWidgets('affiche compteurs et état', (tester) async {
      await tester.pumpWidget(card(source, await controller()));
      expect(find.textContaining('3 chaînes'), findsOneWidget);
      expect(find.text('Jamais actualisée'), findsOneWidget);
    });

    testWidgets('liste suspecte : message clair et choix d\'appliquer', (tester) async {
      const s = Source(id: 1, name: 'A', kind: SourceKind.xtream, error: ImportError.suspicious, errorDetail: '1200 → 30');
      await tester.pumpWidget(card(s, await controller()));
      expect(find.textContaining('1200 → 30'), findsOneWidget);
      expect(find.text('Appliquer quand même'), findsOneWidget);
    });

    testWidgets('erreur ordinaire : réessayer, sans forcer', (tester) async {
      const s = Source(id: 1, name: 'A', kind: SourceKind.xtream, error: ImportError.credentials);
      await tester.pumpWidget(card(s, await controller()));
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Appliquer quand même'), findsNothing);
    });
  });
}
