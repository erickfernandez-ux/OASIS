import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Consistent visual separator.
class AppDivider extends StatelessWidget {
  final double? height;
  final double? indent;
  final double? endIndent;

  const AppDivider({
    this.height,
    this.indent,
    this.endIndent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Divider(
      color: colors.semantic.divider,
      height: height ?? 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
