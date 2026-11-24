import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/format.dart';
import '../theme/tokens.dart';

/// Coins coupés en biseau (haut droit, bas gauche) : la signature visuelle des panneaux.
ShapeBorder panelShape({required Color side, double cut = 12, double width = 1}) => BeveledRectangleBorder(
      side: BorderSide(color: side, width: width),
      borderRadius: BorderRadius.only(topRight: Radius.circular(cut), bottomLeft: Radius.circular(cut)),
    );

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(AppSpace.l), this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return DecoratedBox(
      decoration: ShapeDecoration(color: color ?? palette.panel, shape: panelShape(side: palette.line)),
      // Surface Material transparente : listes, interrupteurs et effets de toucher se dessinent sur le panneau.
      child: Material(type: MaterialType.transparency, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Titre de section en capitales italiques, précédé d'un trait oblique de couleur.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Row(
      children: [
        Transform(
          transform: Matrix4.skewX(-0.35),
          child: Container(width: 5, height: 18, color: palette.accent),
        ),
        const SizedBox(width: AppSpace.m),
        Expanded(
          child: Text(
            text.upperIn(Localizations.localeOf(context).languageCode),
            style: Theme.of(context).textTheme.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Élément cliquable au doigt, à la souris ou à la télécommande. Le cadre de focus reste bien
/// visible à trois mètres d'un téléviseur, sans dépendre du survol.
class FocusTile extends StatefulWidget {
  const FocusTile({super.key, required this.onTap, required this.child, this.autofocus = false, this.selected = false, this.onLongPress, this.focusNode});

  /// Porté par l'élément actuellement ciblé.
  static const highlightKey = ValueKey('focus-highlight');

  final VoidCallback onTap;

  /// Appui long ou clic droit.
  final VoidCallback? onLongPress;
  final Widget child;
  final bool autofocus;
  final bool selected;
  final FocusNode? focusNode;

  @override
  State<FocusTile> createState() => _FocusTileState();
}

class _FocusTileState extends State<FocusTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final highlighted = _focused && usesKeyNavigation;
    return InkWell(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onSecondaryTap: widget.onLongPress,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: DecoratedBox(
        key: highlighted ? FocusTile.highlightKey : null,
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(border: highlighted ? Border.all(color: palette.accent, width: 2) : null),
        child: ColoredBox(
          color: highlighted
              ? palette.accent.withValues(alpha: 0.22)
              : (widget.selected ? palette.accent.withValues(alpha: 0.14) : Colors.transparent),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Vrai au clavier et à la télécommande : c'est là qu'il faut un point de départ pour le focus.
/// Au doigt, un élément ciblé d'office n'a pas de sens.
bool get usesKeyNavigation => FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

/// Laisse les flèches haut et bas quitter un champ de texte, où Flutter les réserve au curseur :
/// sans cela, la télécommande ne pourrait plus sortir du premier champ atteint.
class FieldNavigation extends StatelessWidget {
  const FieldNavigation({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down, ignoreTextFields: false),
          SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up, ignoreTextFields: false),
        },
        child: child,
      );
}

/// Message centré, éventuellement avec une action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.title, required this.message, this.action});

  final String? title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Panel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[SectionTitle(title!), const SizedBox(height: AppSpace.m)],
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                if (action != null) ...[const SizedBox(height: AppSpace.l), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feuille du bas. `useSafeArea` de Flutter protège le haut et les côtés, pas le bas : sans ce
/// `SafeArea`, la barre de navigation d'Android recouvre la dernière ligne.
Future<T?> showAppSheet<T>({required BuildContext context, required WidgetBuilder builder, bool isScrollControlled = false}) => showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: isScrollControlled,
      builder: (sheetContext) => SafeArea(top: false, child: builder(sheetContext)),
    );
