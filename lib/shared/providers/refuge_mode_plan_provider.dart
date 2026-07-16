import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preparation-only structure for the future Refuge Mode.
///
/// Refuge Mode is intentionally not implemented yet.
/// This provider defines the architecture contract for when it is enabled:
/// - Hide secondary metrics.
/// - Hide administrative actions.
/// - Keep only essential content.
/// - Increase background prominence.
/// - Expand breathing space in layout.
class RefugeModePlan {
  const RefugeModePlan({
    required this.hideSecondaryMetrics,
    required this.hideAdministrativeActions,
    required this.emphasizeBackground,
    required this.increaseBreathingSpace,
  });

  final bool hideSecondaryMetrics;
  final bool hideAdministrativeActions;
  final bool emphasizeBackground;
  final bool increaseBreathingSpace;

  static const RefugeModePlan inactive = RefugeModePlan(
    hideSecondaryMetrics: false,
    hideAdministrativeActions: false,
    emphasizeBackground: false,
    increaseBreathingSpace: false,
  );

  static const RefugeModePlan activePreset = RefugeModePlan(
    hideSecondaryMetrics: true,
    hideAdministrativeActions: true,
    emphasizeBackground: true,
    increaseBreathingSpace: true,
  );
}

final refugeModePlanProvider = Provider<RefugeModePlan>((ref) {
  // Preparation only: keep inactive until Experience 18 implementation.
  return RefugeModePlan.inactive;
});
