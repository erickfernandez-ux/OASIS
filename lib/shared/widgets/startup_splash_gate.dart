import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design_system.dart';
import '../../features/settings/presentation/providers/settings_controller.dart';
import 'onboarding_welcome_flow.dart';

class StartupSplashGate extends ConsumerStatefulWidget {
  const StartupSplashGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<StartupSplashGate> createState() => _StartupSplashGateState();
}

class _StartupSplashGateState extends ConsumerState<StartupSplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _showApp = false;
  bool _onboardingDismissed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: MotionSpec.splashFade,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: MotionSpec.easeInOut,
    );

    _fadeController.forward();
    _scheduleDismiss();
  }

  Future<void> _scheduleDismiss() async {
    await Future<void>.delayed(MotionSpec.splashHold);
    if (!mounted) return;
    setState(() => _showApp = true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final requiresOnboarding =
        settings.valueOrNull?.onboardingCompleted == false;

    return AnimatedSwitcher(
      duration: MotionSpec.splashSwitch,
      switchInCurve: MotionSpec.easeOut,
      switchOutCurve: MotionSpec.easeOut,
      child: !_showApp
          ? OasisWatercolorBackground(
              key: const ValueKey<String>('splash'),
              accent: OasisSurfaces.homeAccent,
              child: SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Image.asset(
                      'assets/logos/oasis_logo.png',
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            )
          : (requiresOnboarding && !_onboardingDismissed)
              ? OnboardingWelcomeFlow(
                  key: const ValueKey<String>('onboarding'),
                  onCompleted: () {
                    if (!mounted) return;
                    setState(() => _onboardingDismissed = true);
                  },
                )
              : KeyedSubtree(
                  key: const ValueKey<String>('app'),
                  child: widget.child,
                ),
    );
  }
}
