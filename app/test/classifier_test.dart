import 'dart:convert';
import 'dart:io';

import 'package:chud_iptv/filtered/classifier.dart';
import 'package:flutter_test/flutter_test.dart';

List<GroupRef> refs(Iterable<String> names) => [
      for (final (i, n) in names.indexed) GroupRef(key: '1:$i', name: n, itemCount: 10),
    ];

void main() {
  group('analyse d\'un groupe', () {
    test('pays, région et thème', () {
      final a = analyzeGroup('EU | FRANCE SPORTS ');
      expect(a.place?.code, 'FR');
      expect(a.region, 'EU');
      expect(a.themes, {'SPORTS'});
      expect(a.uncertain, isFalse);
    });

    test('variantes d\'écriture et abréviations', () {
      for (final (name, code) in [
        ('UNITED KINGDOM GENERAL', 'GB'), ('UK NEWS', 'GB'), ('Deutschland Sport', 'DE'), ('ITALIA CINEMA', 'IT'), ('España Deportes', 'ES'),
        ('FRENCH MOVIES', 'FR'), ('USA GENERAL', 'US'), ('United States News', 'US'),
      ]) {
        expect(analyzeGroup(name).place?.code, code, reason: name);
      }
    });

    test('préfixes délimités', () {
      expect(analyzeGroup('FR | Cinéma').place?.code, 'FR');
      expect(analyzeGroup('[DE] Filme').place?.code, 'DE');
      expect(analyzeGroup('US: Local').place?.code, 'US');
    });

    test('fautes de frappe des fournisseurs', () {
      expect(analyzeGroup('EU | GERMANY ENTERTANMENT').themes, {'ENTERTAINMENT'});
      expect(analyzeGroup('EU | ROMANIA ENTARTENMANT').themes, {'ENTERTAINMENT'});
      expect(analyzeGroup('EU | POLAND DOCUMENTRIES').themes, {'DOCUMENTARIES'});
      expect(analyzeGroup('AS | THAILLAND').place?.code, 'TH');
      expect(analyzeGroup('24/7 | MALASIA').place?.code, 'MY');
    });

    test('AR en préfixe, c\'est le monde arabe, pas l\'Argentine', () {
      expect(analyzeGroup('AR | KIDS').region, 'ARABIC');
      expect(analyzeGroup('AR | EGYPT').place?.code, 'EG');
      expect(analyzeGroup('AM | ARGENTINA ').place?.code, 'ARG');
    });

    test('pas de correspondance hasardeuse', () {
      expect(analyzeGroup('Euronews HD').region, isNull, reason: 'EU dans un mot');
      expect(analyzeGroup('Eurosport').region, isNull);
      expect(analyzeGroup('IT Crowd').place, isNull, reason: 'IT sans préfixe délimité');
      expect(analyzeGroup('Canada Dry').place?.code, 'CA', reason: 'le mot entier reste un pays');
      expect(analyzeGroup('Divers es').place, isNull);
      expect(analyzeGroup('it | test').place, isNull, reason: 'les codes ne valent qu\'en majuscules');
      expect(analyzeGroup('France 24').themes, isEmpty);
    });

    test('groupe incompréhensible : signalé, pas deviné', () {
      final a = analyzeGroup('Accout Information');
      expect(a.understood, isTrue, reason: 'information : actualités');
      final b = analyzeGroup('VIP | SHAHID');
      expect(b.understood, isFalse);
      expect(b.uncertain, isTrue);
    });

    test('deux pays cités : le premier, à vérifier', () {
      final a = analyzeGroup('EU | UK INDIA CHANNELS');
      expect(a.place?.code, 'GB');
      expect(a.uncertain, isTrue);
    });

    test('les chaînes du groupe ne contredisent jamais la région annoncée', () {
      final a = analyzeGroup('AR | CHRISTIAN', dominant: 'CR');
      expect(a.place, isNull);
      expect(a.region, 'ARABIC');
      expect(analyzeGroup('AR | ROTANA', dominant: 'EG').place?.code, 'EG');
    });

    test('espace insécable dans un nom', () {
      expect(analyzeGroup('EU |\u00a0SPAIN DOCUMENTARY').place?.code, 'ES');
    });

    test('une langue citée n\'est pas un second pays', () {
      final a = analyzeGroup('AM | CANADA FRANÇAIS SPORT');
      expect(a.place?.code, 'CA');
      expect(a.uncertain, isFalse);
      expect(analyzeGroup('EU | EXYU CROATIA').place?.code, 'HR');
    });

    test('les chaînes du groupe peuvent aider, sans certitude', () {
      final a = analyzeGroup('VIP | SHAHID', dominant: 'FR');
      expect(a.place?.code, 'FR');
      expect(a.uncertain, isTrue);
    });
  });

  group('classement', () {
    test('la hiérarchie demandée', () {
      final tree = buildTree(
        refs(['FRANCE SPORT', 'FRANCE CINEMA', 'FRANCE NEWS', 'FRANCE 4K', 'FRANCE KIDS', 'GERMANY SPORTS', 'USA NEWS', 'CANADA KIDS']),
        FilteredEdits(),
      );
      final eu = tree.nodes.firstWhere((n) => n.key == 'region:EU');
      expect(eu.label, 'EU');
      expect(tree.childrenOf('region:EU').map((n) => n.label), ['FRANCE', 'GERMANY']);
      expect(tree.childrenOf('region:NA').map((n) => n.label), ['CANADA', 'USA']);
      expect(tree.groupsUnder('place:FR'), hasLength(5));
      expect(tree.groupsUnder('region:EU'), hasLength(6));
      expect(tree.nodes.firstWhere((n) => n.key == 'theme:SPORTS').groups, hasLength(2));
      expect(tree.nodes.map((n) => n.parent), contains(null));
    });

    test('un groupe peut être à plusieurs endroits, sans doublon de chaîne', () {
      final tree = buildTree(refs(['FRANCE SPORT']), FilteredEdits());
      expect(tree.groupsUnder('place:FR'), {'1:0'});
      expect(tree.groupsUnder('theme:SPORTS'), {'1:0'});
    });

    test('plusieurs sources se rejoignent', () {
      final tree = buildTree(
        const [GroupRef(key: '1:a', name: 'FR | Sport', itemCount: 1), GroupRef(key: '2:b', name: 'FRANCE SPORTS', itemCount: 1)],
        FilteredEdits(),
      );
      expect(tree.nodes.firstWhere((n) => n.key == 'place:FR').groups, ['1:a', '2:b']);
    });

    test('les inconnus ne sont pas casés au hasard', () {
      final tree = buildTree(refs(['VIP | SHAHID', 'FRANCE SPORT']), FilteredEdits());
      expect(tree.unclassified, ['1:0']);
      expect(tree.groupsUnder('place:FR'), {'1:1'});
    });
  });

  group('corrections de l\'utilisateur', () {
    final groups = refs(['FRANCE SPORT', 'FRANCE NEWS', 'VIP | SHAHID', 'GERMANY SPORT']);

    test('exclure un groupe', () {
      final tree = buildTree(groups, FilteredEdits(excluded: {'1:0'}));
      expect(tree.groupsUnder('place:FR'), {'1:1'});
    });

    test('ranger un groupe à la main, y compris un inconnu', () {
      final tree = buildTree(groups, FilteredEdits(assigned: {'1:2': ['theme:MOVIES']}));
      expect(tree.groupsUnder('theme:MOVIES'), {'1:2'});
      expect(tree.unclassified, isEmpty);
    });

    test('le choix manuel remplace le classement automatique', () {
      final tree = buildTree(groups, FilteredEdits(assigned: {'1:0': ['place:DE']}));
      expect(tree.groupsUnder('place:FR'), {'1:1'});
      expect(tree.groupsUnder('place:DE'), containsAll(['1:0', '1:3']));
      expect(tree.groupsUnder('theme:SPORTS'), {'1:3'});
    });

    test('renommer', () {
      final tree = buildTree(groups, FilteredEdits(renamed: {'place:FR': 'Chez moi'}));
      expect(tree.nodes.firstWhere((n) => n.key == 'place:FR').label, 'Chez moi');
    });

    test('fusionner', () {
      final tree = buildTree(groups, FilteredEdits(merged: {'place:DE': 'place:FR'}));
      expect(tree.nodes.where((n) => n.key == 'place:DE'), isEmpty);
      expect(tree.groupsUnder('place:FR'), containsAll(['1:0', '1:1', '1:3']));
    });

    test('catégorie personnelle', () {
      final tree = buildTree(
        groups,
        FilteredEdits(custom: {'custom:1': const CustomNode('Séparé', null)}, assigned: {'1:1': ['custom:1']}),
      );
      expect(tree.groupsUnder('custom:1'), {'1:1'});
      expect(tree.groupsUnder('place:FR'), {'1:0'});
    });

    test('les corrections survivent à une nouvelle analyse avec de nouveaux groupes', () {
      final edits = FilteredEdits(renamed: {'place:FR': 'Hexagone'}, excluded: {'1:1'});
      final after = buildTree([...groups, const GroupRef(key: '1:9', name: 'FRANCE KIDS', itemCount: 3)], edits);
      final france = after.nodes.firstWhere((n) => n.key == 'place:FR');
      expect(france.label, 'Hexagone');
      expect(france.groups, ['1:0', '1:9']);
    });

    test('les corrections se sauvegardent', () {
      final edits = FilteredEdits(
        excluded: {'a'},
        assigned: {'b': ['theme:NEWS']},
        renamed: {'c': 'd'},
        merged: {'e': 'f'},
        custom: {'g': const CustomNode('h', 'i')},
      );
      final back = FilteredEdits.fromJson(edits.toJson());
      expect(back.excluded, {'a'});
      expect(back.assigned['b'], ['theme:NEWS']);
      expect(back.renamed['c'], 'd');
      expect(back.merged['e'], 'f');
      expect(back.custom['g']!.parent, 'i');
    });

    test('le classement se sauvegarde', () {
      final tree = buildTree(groups, FilteredEdits());
      final back = FilteredTree.fromJson(tree.toJson());
      expect(back.nodes.map((n) => n.key), tree.nodes.map((n) => n.key));
      expect(back.analyzed, tree.analyzed);
    });
  });

  group('les 436 vrais groupes d\'un abonnement', () {
    final names = (jsonDecode(File('test/fixtures/live_groups.json').readAsStringSync()) as List).cast<String>();
    final groups = refs(names);
    final tree = buildTree(groups, FilteredEdits());
    final nameOf = {for (final g in groups) g.key: g.name};

    test('la très grande majorité est comprise', () {
      expect(tree.unclassified.length, lessThan(names.length * 0.03), reason: tree.unclassified.map((k) => nameOf[k]).join(' ; '));
      final classified = tree.nodes.expand((n) => n.groups).toSet();
      expect(classified.length, greaterThan(names.length * 0.97));
    });

    test('la France rassemble tous ses groupes', () {
      final france = tree.groupsUnder('place:FR').map((k) => nameOf[k]!).toList();
      expect(france.where((n) => n.contains('EU | FRANCE')), hasLength(19));
      expect(france, contains('24/7 | FRENCH'));
      expect(france, isNot(contains('EU | SPAIN GENERALE')));
    });

    test('régions cohérentes', () {
      expect(tree.childrenOf('region:EU').map((n) => n.label), containsAll(['FRANCE', 'GERMANY', 'ITALY', 'SPAIN', 'UNITED KINGDOM']));
      expect(tree.childrenOf('region:NA').map((n) => n.label), ['CANADA', 'USA']);
      expect(tree.childrenOf('region:LATAM').map((n) => n.label), containsAll(['BRAZIL', 'MEXICO', 'ARGENTINA']));
      expect(tree.childrenOf('region:ARABIC').map((n) => n.label), containsAll(['EGYPT', 'MOROCCO', 'SAUDI ARABIA']));
      expect(tree.childrenOf('region:AF').map((n) => n.label), containsAll(['SENEGAL', 'NIGERIA']));
      expect(tree.childrenOf('region:AS').map((n) => n.label), containsAll(['INDIA', 'JAPAN']));
      expect(tree.childrenOf('region:OC').map((n) => n.label), containsAll(['AUSTRALIA', 'NEW ZEALAND']));
    });

    test('les sports viennent de partout', () {
      final sports = tree.groupsUnder('theme:SPORTS').map((k) => nameOf[k]!).toList();
      expect(sports, containsAll(['EU | FRANCE SPORTS ', 'AM | USA NFL', 'AR | BEIN SPORTS', 'EU | TURK SPOR', 'EU | PORTUGAL DESPORTO', 'BAB | CRICKET']));
    });

    test('aucun pays absurde', () {
      expect(tree.groupsUnder('place:ARG').map((k) => nameOf[k]), ['AM | ARGENTINA ']);
      expect(tree.groupsUnder('place:CA').every((k) => nameOf[k]!.contains('CANADA')), isTrue);
      expect(tree.groupsUnder('place:IT').every((k) => nameOf[k]!.contains('ITALY')), isTrue);
    });

    test('rapport', () {
      // ignore: avoid_print
      print('${tree.nodes.length} catégories, ${tree.uncertain.length} à vérifier : ${tree.uncertain.map((k) => nameOf[k]).join(' ; ')}');
      // ignore: avoid_print
      print('Non classés : ${tree.unclassified.map((k) => nameOf[k]).join(' ; ')}');
      // ignore: avoid_print
      print('Régions seules : ${tree.nodes.where((n) => n.key.startsWith('region:')).map((n) => '${n.label}: ${n.groups.map((k) => nameOf[k]).join(', ')}').join('\n')}');
    });
  });
}
