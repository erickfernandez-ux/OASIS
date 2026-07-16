import 'package:flutter/material.dart';

import '../spacing/oasis_spacing.dart';

class OasisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OasisAppBar({
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 86,
      leading: leading,
      actions: actions,
      titleSpacing: OasisSpacing.md,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(86);
}
