import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/format.dart';
import '../theme/tokens.dart';
import 'panel.dart';

enum AppSection { live, filtered, guide, favorites, movies, series, downloads, sources, settings }

String sectionLabel(AppSection s, AppLocalizations l) => switch (s) {
      AppSection.live => l.navLive,
      AppSection.filtered => 'FILTERED',
      AppSection.guide => l.navGuide,
      AppSection.favorites => l.navFavorites,
      AppSection.movies => l.navMovies,
      AppSection.series => l.navSeries,
      AppSection.downloads => l.navDownloads,
      AppSection.sources => l.navSources,
      AppSection.settings => l.navSettings,
    };

IconData sectionIcon(AppSection s) => switch (s) {
      AppSection.live => Icons.live_tv,
      AppSection.filtered => Icons.auto_awesome,
      AppSection.guide => Icons.calendar_view_day_outlined,
      AppSection.favorites => Icons.star_border,
      AppSection.movies => Icons.movie_outlined,
      AppSection.series => Icons.video_library_outlined,
      AppSection.downloads => Icons.download_outlined,
      AppSection.sources => Icons.dns_outlined,
      AppSection.settings => Icons.tune,
    };

/// Navigation : onglets en haut sur PC et TV, barre en bas sur téléphone.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.sections, required this.selected, required this.onSelect, required this.body});

  final List<AppSection> sections;
  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;
    final palette = Palette.of(context);
    final l = context.l10n;

    if (wide) {
      return Column(children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          decoration: BoxDecoration(
            color: palette.tabBar,
            border: Border(bottom: BorderSide(color: palette.line)),
          ),
          child: Row(children: [
            const Wordmark(),
            const SizedBox(width: AppSpace.xxl),
            // Défile si les libellés sont trop longs pour la largeur de la fenêtre.
            Expanded(
              child: FocusTraversalGroup(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (final s in sections)
                      _TopTab(label: sectionLabel(s, l), selected: s == selected, onTap: () => onSelect(s)),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        Expanded(child: body),
      ]);
    }

    // Sur téléphone, cinq entrées au plus : le reste passe par « Plus ».
    final primary = sections.length <= 5 ? sections : sections.sublist(0, 4);
    final overflow = sections.length <= 5 ? const <AppSection>[] : sections.sublist(4);
    final inOverflow = overflow.contains(selected);

    Future<void> openMore() async {
      final chosen = await showAppSheet<AppSection>(
        context: context,
        builder: (sheetContext) => Column(mainAxisSize: MainAxisSize.min, children: [
          for (final s in overflow)
            ListTile(
              leading: Icon(sectionIcon(s)),
              title: Text(sectionLabel(s, l)),
              selected: s == selected,
              onTap: () => Navigator.pop(sheetContext, s),
            ),
        ]),
      );
      if (chosen != null) onSelect(chosen);
    }

    return Column(children: [
      SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.s, AppSpace.s, AppSpace.s),
          child: const Row(children: [Wordmark()]),
        ),
      ),
      Expanded(child: body),
      // Placée à la main en bas de l'écran (et non par Scaffold) : sans ce retrait, la barre ajoute
      // au-dessus de ses icônes la marge de la barre d'état, qui ne la concerne pas.
      MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: NavigationBar(
          selectedIndex: inOverflow ? primary.length : primary.indexOf(selected),
          onDestinationSelected: (i) => i < primary.length ? onSelect(primary[i]) : openMore(),
          height: 56,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            for (final s in primary) NavigationDestination(icon: Icon(sectionIcon(s)), label: sectionLabel(s, l)),
            if (overflow.isNotEmpty) NavigationDestination(icon: const Icon(Icons.menu), label: l.navMore),
          ],
        ),
      ),
    ]);
  }
}

/// Logo typographique.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final base = TextStyle(
      fontFamily: 'Barlow Condensed',
      fontWeight: FontWeight.w800,
      fontStyle: FontStyle.italic,
      fontSize: 24,
      height: 1,
      color: palette.brand,
    );
    return Semantics(
      label: 'Chud IPTV',
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Transform(
          transform: Matrix4.skewX(-0.35),
          child: Container(width: 6, height: 22, color: palette.accent),
        ),
        const SizedBox(width: 8),
        Text('CHUD', style: base),
        const SizedBox(width: 4),
        Text('IPTV', style: base),
      ]),
    );
  }
}

class _TopTab extends StatefulWidget {
  const _TopTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TopTab> createState() => _TopTabState();
}

class _TopTabState extends State<_TopTab> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final style = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontStyle: FontStyle.italic,
          letterSpacing: 1,
          color: widget.selected || _focused ? palette.text : palette.textMuted,
        );
    return InkWell(
      onTap: widget.onTap,
      onFocusChange: (f) => setState(() => _focused = f),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.m),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.label.upperIn(Localizations.localeOf(context).languageCode), style: style),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: AppMotion.normal,
            curve: AppMotion.curve,
            height: 3,
            width: widget.selected || _focused ? 28 : 0,
            transform: Matrix4.skewX(-0.5),
            color: _focused ? AppColors.live : palette.accent,
          ),
        ]),
      ),
    );
  }
}
