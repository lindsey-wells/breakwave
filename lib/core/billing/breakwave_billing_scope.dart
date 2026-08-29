// ------------------------------------------------------------
// Cube23 Collaboration Header
// Project: BreakWave
// File: breakwave_billing_scope.dart
// Purpose: App-tree access to the shared billing composition.
// ------------------------------------------------------------

import 'package:flutter/widgets.dart';

import 'breakwave_billing_composition.dart';

class BreakWaveBillingScope extends InheritedWidget {
  const BreakWaveBillingScope({
    required this.composition,
    required super.child,
    super.key,
  });

  final BreakWaveBillingComposition composition;

  static BreakWaveBillingComposition of(
    BuildContext context,
  ) {
    final BreakWaveBillingScope? scope =
        context.dependOnInheritedWidgetOfExactType<
            BreakWaveBillingScope>();

    if (scope == null) {
      throw FlutterError(
        'BreakWaveBillingScope is missing above this context.',
      );
    }

    return scope.composition;
  }

  @override
  bool updateShouldNotify(BreakWaveBillingScope oldWidget) {
    return !identical(composition, oldWidget.composition);
  }
}
