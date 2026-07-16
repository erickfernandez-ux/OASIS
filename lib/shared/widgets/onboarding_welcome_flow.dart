import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design_system.dart';
import '../../features/settings/presentation/providers/settings_controller.dart';

class OnboardingWelcomeFlow extends ConsumerStatefulWidget {
  const OnboardingWelcomeFlow({required this.onCompleted, super.key});

  final VoidCallback onCompleted;

  @override
  ConsumerState<OnboardingWelcomeFlow> createState() =>
      _OnboardingWelcomeFlowState();
}

class _OnboardingWelcomeFlowState extends ConsumerState<OnboardingWelcomeFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _page = 0;
  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_page >= 1) return;
    await _pageController.nextPage(
      duration: MotionSpec.onboardingStep,
      curve: MotionSpec.easeInOut,
    );
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Cuéntanos cómo te gustaría que te llamemos.')),
      );
      return;
    }

    setState(() => _saving = true);
    final controller = ref.read(settingsControllerProvider.notifier);
    await controller.setPreferredName(name);
    await controller.completeOnboarding();
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;

    return OasisWatercolorBackground(
      accent: OasisSurfaces.homeAccent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(OasisSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _page = index),
                  children: [
                    _OnboardingPanel(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logos/oasis_logo.png',
                            height: 46,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: OasisSpacing.lg),
                          Text(
                            'Bienvenido a OASIS',
                            style: typography.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: OasisSpacing.sm),
                          Text(
                            'Un espacio para organizar tu vida con calma.',
                            style: typography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    _OnboardingPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Como quieres que te llame OASIS?',
                            style: typography.titleLarge,
                          ),
                          const SizedBox(height: OasisSpacing.md),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: 'Escribe tu nombre',
                            ),
                          ),
                          const SizedBox(height: OasisSpacing.md),
                          Text(
                            'Ese nombre aparecera en Home.',
                            style: typography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: OasisSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving
                      ? null
                      : (_page < 1)
                          ? _nextPage
                          : _finish,
                    child: Text(_page == 0 ? 'Comenzar' : 'Guardar y entrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OasisPrimaryCard(
        padding: const EdgeInsets.all(OasisSpacing.lg),
        child: child,
      ),
    );
  }
}
