import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Base dialog wrapper for consistent modal presentation.
class AppDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AppDialog({
    required this.title,
    required this.child,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = context.appRadius;
    final typography = context.appTypography;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: radius.large),
      backgroundColor: colors.semantic.surface,
      titlePadding: EdgeInsets.all(context.appSpacing.md),
      contentPadding: EdgeInsets.fromLTRB(context.appSpacing.md, 0, context.appSpacing.md, context.appSpacing.md),
      title: Text(title, style: typography.title.copyWith(color: colors.semantic.textPrimary)),
      content: child,
      actions: actions,
    );
  }
}
