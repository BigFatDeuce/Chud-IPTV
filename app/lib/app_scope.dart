import 'package:flutter/widgets.dart';

import 'app_controller.dart';

/// Rend le contrôleur de l'app accessible à tous les écrans (et aux panneaux ouverts par-dessus).
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({super.key, required AppController controller, required super.child}) : super(notifier: controller);

  static AppController of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
