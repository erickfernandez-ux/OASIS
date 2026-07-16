import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../core/design/design_system.dart';
import '../../core/theme/icons/app_icons.dart';
import 'bottom_nav_bar.dart';
import 'top_app_bar.dart';

/// Base scaffold integrating AppBar, bottom navigation, and FAB.
/// Receives StatefulNavigationShell from GoRouter to manage tabs.
class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    required this.navigationShell,
    super.key,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const int _branchCount = 5;

  double _dragDx = 0;
  int _transitionDirection = 1;
  double _bounceOffsetX = 0;
  Timer? _bounceResetTimer;

  @override
  void dispose() {
    _bounceResetTimer?.cancel();
    super.dispose();
  }

  void _onTap(int index) {
    _goToBranch(index);
  }

  void _goToBranch(int index) {
    final current = widget.navigationShell.currentIndex;
    if (index == current || index < 0 || index >= _branchCount) {
      return;
    }

    setState(() {
      _transitionDirection = index > current ? 1 : -1;
    });

    widget.navigationShell.goBranch(index);
  }

  void _triggerEdgeBounce(int direction) {
    _bounceResetTimer?.cancel();
    setState(() {
      _bounceOffsetX = 0.022 * direction;
    });
    _bounceResetTimer = Timer(MotionSpec.moduleNavigation, () {
      if (!mounted) return;
      setState(() {
        _bounceOffsetX = 0;
      });
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final effectiveSwipe =
        _dragDx.abs() > MotionSpec.swipeCommitDistancePx ||
        velocity.abs() > MotionSpec.swipeCommitVelocityPxPerSecond;
    final current = widget.navigationShell.currentIndex;

    if (!effectiveSwipe) {
      setState(() {
        _dragDx = 0;
      });
      return;
    }

    if (_dragDx < 0) {
      if (current >= _branchCount - 1) {
        _triggerEdgeBounce(-1);
      } else {
        _goToBranch(current + 1);
      }
    } else {
      if (current <= 0) {
        _triggerEdgeBounce(1);
      } else {
        _goToBranch(current - 1);
      }
    }

    setState(() {
      _dragDx = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final showCrisisAccess =
        currentIndex == 0 || currentIndex == 1 || currentIndex == 2;
    final indexedBody = AnimatedSwitcher(
      duration: MotionSpec.moduleNavigation,
      switchInCurve: MotionSpec.easeInOut,
      switchOutCurve: MotionSpec.easeInOut,
      transitionBuilder: (child, animation) {
        final key = child.key;
        final keyValue = key is ValueKey<int> ? key.value : null;
        final isIncoming = keyValue == currentIndex;

        final begin =
            isIncoming ? Offset(0.10 * _transitionDirection, 0) : Offset.zero;
        final end =
            isIncoming ? Offset.zero : Offset(-0.10 * _transitionDirection, 0);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: begin, end: end).animate(
              CurvedAnimation(parent: animation, curve: MotionSpec.easeInOut),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<int>(currentIndex),
        child: widget.navigationShell,
      ),
    );

    final gestureBody = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) {
        _dragDx = 0;
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragDx += details.delta.dx;
        });
      },
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: indexedBody,
    );

    final dragLimit = MediaQuery.of(context).size.width * 0.16;
    final dragOffset = _dragDx.clamp(-dragLimit, dragLimit).toDouble();
    final dragFollowingBody = AnimatedSlide(
      duration: MotionSpec.selectionFade,
      curve: MotionSpec.easeOut,
      offset: Offset(_bounceOffsetX, 0),
      child: AnimatedContainer(
        duration: MotionSpec.micro,
        curve: MotionSpec.easeOut,
        transform: Matrix4.translationValues(dragOffset, 0, 0),
        child: gestureBody,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: TopAppBar(
        actions: [
          IconButton(
            tooltip: 'Notas',
            onPressed: () => context.push(RouteConstants.notes),
            icon: const Icon(AppIcons.notes),
          ),
        ],
      ),
      body: OasisWatercolorBackground(
        accent: OasisSurfaces.base,
        child: dragFollowingBody,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: _onTap,
      ),
      floatingActionButton: showCrisisAccess
          ? EmergencyButton(
              tooltip: 'Plan de seguridad',
              onTap: () => context.push(RouteConstants.safetyPlan),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
