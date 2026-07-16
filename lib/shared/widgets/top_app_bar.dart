import 'package:flutter/material.dart';
import '../../core/theme/theme_extensions.dart';

/// Minimalist Japandi AppBar.
/// Supports title, custom leading, and actions.
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final double? elevation;

  const TopAppBar({
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.elevation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: typography.title.copyWith(color: colors.component.appBarForeground),
            )
          : null,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      elevation: elevation ?? 0,
      backgroundColor: colors.component.appBarBackground,
      foregroundColor: colors.component.appBarForeground,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
