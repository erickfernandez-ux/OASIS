import 'package:flutter/material.dart';
import 'component_colors.dart';
import 'semantic_colors.dart';

/// Aggregator of all color systems.
/// Exposed as a single ThemeExtension to simplify BuildContext access.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final SemanticColors semantic;
  final ComponentColors component;

  const AppColors({
    required this.semantic,
    required this.component,
  });

  static AppColors get light => AppColors(
        semantic: SemanticColors.light(),
        component: ComponentColors.light(),
      );

  static AppColors get dark => AppColors(
        semantic: SemanticColors.dark(),
        component: ComponentColors.dark(),
      );

  static AppColors get highContrastLight => AppColors(
        semantic: SemanticColors.highContrastLight(),
        component: ComponentColors.light(),
      );

  static AppColors get highContrastDark => AppColors(
        semantic: SemanticColors.highContrastDark(),
        component: ComponentColors.dark(),
      );

  @override
  AppColors copyWith({SemanticColors? semantic, ComponentColors? component}) {
    return AppColors(
      semantic: semantic ?? this.semantic,
      component: component ?? this.component,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      semantic: semantic.lerp(other.semantic, t),
      component: component.lerp(other.component, t),
    );
  }
}
