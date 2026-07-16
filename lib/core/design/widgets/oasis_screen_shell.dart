import 'package:flutter/material.dart';

import '../../../features/settings/domain/enums/canvas_motion_preference.dart';
import '../../../features/settings/domain/enums/canvas_style_preference.dart';
import '../animations/oasis_animations.dart';
import '../backgrounds/oasis_watercolor_background.dart';
import '../decorations/oasis_breakpoints.dart';
import '../decorations/oasis_surfaces.dart';
import '../spacing/oasis_spacing.dart';
import 'oasis_app_bar.dart';

class OasisScreenShell extends StatelessWidget {
  const OasisScreenShell({
    required this.child,
    this.title,
    this.subtitle,
    this.accent = OasisSurfaces.base,
    this.environment,
    this.appBarActions,
    this.leading,
    this.floatingActionButton,
    this.motionOverride,
    this.disableAnimations = false,
    this.scrollController,
    this.scrollable = true,
    this.padding,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Color accent;
  final CanvasStylePreference? environment;
  final List<Widget>? appBarActions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final CanvasMotionPreference? motionOverride;
  final bool disableAnimations;
  final ScrollController? scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return OasisWatercolorBackground(
      accent: accent,
      environment: environment,
      motionOverride: motionOverride,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final band = OasisBreakpoints.bandForWidth(constraints.maxWidth);
            final horizontalPadding = switch (band) {
              OasisBreakpointBand.phone => OasisSpacing.lg,
              OasisBreakpointBand.smallTablet => OasisSpacing.xl,
              OasisBreakpointBand.largeTablet => 40.0,
              OasisBreakpointBand.desktop => 56.0,
            };

            final layoutContent = Padding(
              padding: padding ??
                  EdgeInsets.fromLTRB(horizontalPadding, OasisSpacing.lg,
                      horizontalPadding, OasisSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    OasisAppBar(
                      title: title!,
                      subtitle: subtitle,
                      leading: leading,
                      actions: appBarActions,
                    ),
                    const SizedBox(height: OasisSpacing.md),
                  ],
                  if (scrollable) child else Expanded(child: child),
                ],
              ),
            );

            final body = scrollable
                ? ScrollConfiguration(
                    behavior: const _OasisScrollBehavior(),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      child: layoutContent,
                    ),
                  )
                : layoutContent;

            final finalContent = disableAnimations ? body : OrganicFade(child: body);
            if (floatingActionButton == null) {
              return finalContent;
            }

            return Stack(
              children: [
                Positioned.fill(child: finalContent),
                Positioned(
                  right: OasisSpacing.lg,
                  bottom: OasisSpacing.lg,
                  child: floatingActionButton!,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OasisScrollBehavior extends MaterialScrollBehavior {
  const _OasisScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: ClampingScrollPhysics());
  }
}
