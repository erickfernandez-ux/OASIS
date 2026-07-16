import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/spacing/app_spacing.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/typography/app_typography.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/wellbeing_controller.dart';

class WellbeingScreen extends ConsumerStatefulWidget {
  const WellbeingScreen({super.key});

  @override
  ConsumerState<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends ConsumerState<WellbeingScreen>
    with SingleTickerProviderStateMixin {
  final _goalController = TextEditingController(text: '2000');
  final Set<String> _takenMedicationIds = <String>{};
  int _hydrationPulseIndex = -1;
  int _selectedNaturalLightMinutes = 0;
  int _sleepHours = 7;
  int _wakeMoodIndex = 2;

  Timer? _pomodoroTicker;
  int _pomodoroSecondsLeft = 25 * 60;
  late final AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: MotionSpec.breathingCycle,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _goalController.dispose();
    _pomodoroTicker?.cancel();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final state = ref.watch(wellbeingControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.when(
        data: (wellbeingState) =>
            _buildContent(context, wellbeingState, colors, spacing, typography),
        loading: () => const Center(
          child: LoadingIndicator(type: LoadingType.breathingPaper),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WellbeingState wellbeingState,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    final hydrationProgress = wellbeingState.dailyGoalMl == 0
        ? 0.0
        : (wellbeingState.todayWaterMl / wellbeingState.dailyGoalMl)
            .clamp(0.0, 1.0);

    return OasisWatercolorBackground(
      accent: OasisSurfaces.wellbeingAccent,
      backgroundAssetOverride: 'assets/backgrounds/amanecer.webp',
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OasisSectionHeader(
                      title: 'Bienestar',
                      subtitle: 'Pequeños cuidados del cuerpo que sostienen tu día.',
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      'Ritmo suave, cero sobrecarga.',
                      style: typography.label
                          .copyWith(color: colors.semantic.textSecondary),
                    ),
                    SizedBox(height: spacing.xs),
                    const OasisDivider(),
                    SizedBox(height: spacing.md),
                    _buildMedicationCare(
                        wellbeingState, colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildHydrationExperience(
                        wellbeingState, hydrationProgress, colors, spacing),
                    SizedBox(height: spacing.md),
                    _buildPomodoroFocus(wellbeingState, colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildMovementSection(colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildNaturalLightSection(colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildBreathingGuide(colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildSleepSection(colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildBodyGarden(wellbeingState, hydrationProgress, colors, spacing, typography),
                    SizedBox(height: spacing.md),
                    _buildHealthIntegrationsPrep(colors, spacing, typography),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCare(
    WellbeingState wellbeingState,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    final nextMedication = wellbeingState.medications.isNotEmpty
        ? wellbeingState.medications.first
        : null;

    return OasisPrimaryCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.add, color: colors.semantic.primary),
              SizedBox(width: spacing.sm),
              Text('Medicamentos', style: typography.title),
            ],
          ),
          SizedBox(height: spacing.sm),
          if (nextMedication != null)
            Text(
              'Próxima toma: ${nextMedication.name} · ${nextMedication.dosage}',
              style: typography.body,
            )
          else
            const Text('💧 Cuidarte también empieza con pequeños gestos.'),
          SizedBox(height: spacing.sm),
          if (wellbeingState.medications.isEmpty)
            Text(
              'Configura tus medicamentos en Settings > Medicamentos.',
              style: typography.body.copyWith(color: colors.semantic.textSecondary),
            )
          else
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.sm,
              children: wellbeingState.medications.map((medication) {
                final taken = _takenMedicationIds.contains(medication.id);
                return AnimatedContainer(
                  duration: MotionSpec.micro,
                  curve: MotionSpec.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: taken
                        ? colors.semantic.success.withValues(alpha: 0.18)
                        : Colors.transparent,
                  ),
                  child: FilledButton.tonal(
                    onPressed: taken
                        ? null
                        : () async {
                            setState(() => _takenMedicationIds.add(medication.id));
                        // Future feedback cue: haptic wellbeing.medication.markTaken.
                            await ref
                                .read(wellbeingControllerProvider.notifier)
                                .markMedicationTaken(medication.id);
                          },
                    child: Text(
                      taken ? '✓ ${medication.name}' : 'Tomada · ${medication.name}',
                    ),
                  ),
                );
              }).toList(),
            ),
          if (wellbeingState.medicationLog.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Text('Hoy',
                style:
                    typography.label.copyWith(color: colors.semantic.textSecondary)),
            ...wellbeingState.medicationLog.map(
              (entry) => Text(
                '• ${entry.medicationName}',
                style: typography.label
                    .copyWith(color: colors.semantic.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHydrationExperience(
    WellbeingState wellbeingState,
    double progress,
    AppColors colors,
    AppSpacing spacing,
  ) {
    const totalDrops = 8;
    final filledDrops = (progress * totalDrops).round().clamp(0, totalDrops);

    return OasisSurface(
      level: 2,
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Hidratación',
            subtitle: 'Cada vaso nutre tu energía de forma tranquila.',
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Toca la siguiente gota para registrar 250 ml.',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: colors.semantic.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: List.generate(totalDrops, (index) {
              final filled = index < filledDrops;
              final pulse = index == _hydrationPulseIndex;
              return GestureDetector(
                onTap: () async {
                  if (index > filledDrops) return;
                  setState(() => _hydrationPulseIndex = index);
                  // Future feedback cues: haptic wellbeing.water.register and sound water.
                  await ref
                      .read(wellbeingControllerProvider.notifier)
                      .registerWater(250);
                  if (!mounted) return;
                  Future<void>.delayed(MotionSpec.micro, () {
                    if (!mounted) return;
                    setState(() => _hydrationPulseIndex = -1);
                  });
                },
                child: AnimatedScale(
                  duration: MotionSpec.micro,
                  curve: MotionSpec.easeOut,
                  scale: pulse ? 1.08 : 1,
                  child: AnimatedContainer(
                    duration: MotionSpec.micro,
                    curve: MotionSpec.easeOut,
                    width: 28,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: filled
                          ? colors.semantic.info.withValues(alpha: 0.28)
                          : colors.semantic.surface.withValues(alpha: 0.42),
                      border: Border.all(
                        color: filled
                            ? colors.semantic.info.withValues(alpha: 0.46)
                            : colors.semantic.textSecondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: 18,
                      color: filled
                          ? colors.semantic.info
                          : colors.semantic.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: spacing.sm),
          Text(
            '${wellbeingState.todayWaterMl} / ${wellbeingState.dailyGoalMl} ml',
          ),
          if (filledDrops == totalDrops)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: const Text('✨ Objetivo cumplido. Tu cuerpo lo agradece.'),
            ),
          SizedBox(height: spacing.sm),
          TextButton(
            onPressed: _showGoalDialog,
            child: const Text('Configurar meta diaria'),
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroFocus(
    WellbeingState wellbeingState,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    const total = 25 * 60;
    final progress = 1 - (_pomodoroSecondsLeft / total);

    return OasisPrimaryCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Pomodoro',
            subtitle: 'Enfoque amable para sostener tu ritmo.',
          ),
          SizedBox(height: spacing.sm),
          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor:
                        colors.semantic.surface.withValues(alpha: 0.5),
                  ),
                  Center(
                    child: Text(
                      _formatTimer(_pomodoroSecondsLeft),
                      style: typography.displayLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.sm),
          Center(
            child: Text(
              '${(progress * 100).clamp(0, 100).toInt()}% del ciclo completado',
              style:
                  typography.label.copyWith(color: colors.semantic.textSecondary),
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            wellbeingState.pomodoroRunning
                ? 'Respira. Ya comenzaste.'
                : 'Un bloque pequeño también cuenta.',
            style: typography.body.copyWith(color: colors.semantic.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    _startPomodoroTimer();
                    ref.read(wellbeingControllerProvider.notifier).startPomodoro();
                  },
                  child: const Text('Iniciar'),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    _pausePomodoroTimer();
                    ref.read(wellbeingControllerProvider.notifier).pausePomodoro();
                  },
                  child: const Text('Pausar'),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    _finishPomodoroTimer();
                    ref.read(wellbeingControllerProvider.notifier).finishPomodoro();
                  },
                  child: const Text('Cerrar ciclo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovementSection(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return OasisGlassCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Movimiento',
            subtitle: 'Tu cuerpo se beneficia del movimiento cotidiano.',
          ),
          SizedBox(height: spacing.sm),
          Text('Hoy caminaste 1.8 km.', style: typography.body),
          SizedBox(height: spacing.xs),
          Text('Pasos: 3,250 · Tiempo caminando: 28 min · Objetivo: 6,000 pasos',
              style: typography.label.copyWith(color: colors.semantic.textSecondary)),
          SizedBox(height: spacing.sm),
          Text(
            'Próximamente: integración con Google Fit, Apple Health y Health Connect.',
            style: typography.body.copyWith(color: colors.semantic.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNaturalLightSection(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    const options = <(int minutes, String label)>[
      (10, '10 min'),
      (20, '20 min'),
      (30, '30 min'),
      (40, 'Más de 30 min'),
    ];

    return OasisSurface(
      level: 2,
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Luz natural',
            subtitle: 'La luz natural ayuda a mantener rutinas saludables.',
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: options
                .map(
                  (option) => OasisChip(
                    label: option.$2,
                    selected: _selectedNaturalLightMinutes == option.$1,
                    onTap: () =>
                        setState(() => _selectedNaturalLightMinutes = option.$1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingGuide(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return OasisGlassCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const OasisSectionHeader(
            title: 'Respiración',
            subtitle: 'Sigue el pulso visual para regular tu respiración.',
          ),
          SizedBox(height: spacing.sm),
          AnimatedBuilder(
            animation: _breathingController,
            builder: (context, _) {
              final t = _breathingController.value;
              final size = 70 + (34 * t);
              final inhale = t > 0.5;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: MotionSpec.selectionFade,
                    curve: MotionSpec.easeInOut,
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.semantic.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  SizedBox(height: spacing.sm),
                  Text(inhale ? 'Inhalar' : 'Exhalar', style: typography.title),
                ],
              );
            },
          ),
          SizedBox(height: spacing.sm),
          Text(
            'Haz 4 ciclos lentos. Sin forzar.',
            style: typography.label.copyWith(color: colors.semantic.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepSection(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    const wakeEmojis = ['😴', '😌', '🙂', '😣'];

    return OasisSurface(
      level: 2,
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Sueño',
            subtitle: 'Registra cómo dormiste y cómo despertaste.',
          ),
          SizedBox(height: spacing.sm),
          Text('Horas dormidas: $_sleepHours h', style: typography.body),
          Slider(
            value: _sleepHours.toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            onChanged: (value) => setState(() => _sleepHours = value.round()),
          ),
          SizedBox(height: spacing.xs),
          Wrap(
            spacing: spacing.sm,
            children: List.generate(wakeEmojis.length, (index) {
              const wakeLabels = ['Muy cansado', 'Calmo', 'Bien', 'Tenso'];
              final selected = _wakeMoodIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _wakeMoodIndex = index),
                child: AnimatedContainer(
                  duration: MotionSpec.micro,
                  curve: MotionSpec.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.semantic.primary.withValues(alpha: 0.18)
                        : colors.semantic.surface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(wakeEmojis[index], style: const TextStyle(fontSize: 20)),
                      SizedBox(height: spacing.xs),
                      Text(
                        wakeLabels[index],
                        style: typography.label,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyGarden(
    WellbeingState wellbeingState,
    double hydrationProgress,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    final medicationFactor = _takenMedicationIds.isEmpty ? 0.2 : 1.0;
    const movementFactor = 0.6;
    final sleepFactor = (_sleepHours / 8).clamp(0.3, 1.0);
    final lightFactor = _selectedNaturalLightMinutes == 0 ? 0.3 : 1.0;
    final gardenHealth =
        ((hydrationProgress + medicationFactor + movementFactor + sleepFactor + lightFactor) / 5)
            .clamp(0.0, 1.0);

    return OasisPrimaryCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Mi jardín',
            subtitle: 'Una metáfora suave de tu cuidado corporal.',
          ),
          SizedBox(height: spacing.sm),
          Center(
            child: Text(
              gardenHealth > 0.75
                  ? '🌱 🌿 🌼'
                  : gardenHealth > 0.45
                      ? '🌱 🌿'
                      : '🌱',
              style: const TextStyle(fontSize: 34),
            ),
          ),
          SizedBox(height: spacing.xs),
          Text(
            gardenHealth > 0.75
                ? 'Tu jardín está floreciendo hoy.'
                : gardenHealth > 0.45
                    ? 'Tu jardín está creciendo con constancia.'
                    : 'Tu jardín apenas despierta. Un gesto pequeño cuenta.',
            style: typography.body.copyWith(color: colors.semantic.textSecondary),
          ),
          if (wellbeingState.medications.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: Text(
                hydrationProgress == 0
                    ? 'Pequeños cuidados. Grandes diferencias.'
                    : 'Tip: configura medicamentos en Settings > Medicamentos.',
                style: typography.label.copyWith(color: colors.semantic.textSecondary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthIntegrationsPrep(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return OasisSurface(
      level: 2,
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Integraciones de salud',
            subtitle: 'Preparado para sincronizacion futura.',
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: const [
              OasisChip(label: 'Google Fit (proximamente)', selected: false),
              OasisChip(label: 'Apple Health (proximamente)', selected: false),
              OasisChip(label: 'Health Connect (proximamente)', selected: false),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Sincronizacion en preparacion para pasos, sueno e hidratacion.',
            style: typography.label.copyWith(color: colors.semantic.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startPomodoroTimer() {
    _pomodoroTicker?.cancel();
    _pomodoroTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_pomodoroSecondsLeft > 0) {
          _pomodoroSecondsLeft -= 1;
        } else {
          _pomodoroTicker?.cancel();
          // Future feedback cues: haptic wellbeing.pomodoro.finished and sound pomodoro.
          _pomodoroSecondsLeft = 25 * 60;
        }
      });
    });
  }

  void _pausePomodoroTimer() {
    _pomodoroTicker?.cancel();
  }

  void _finishPomodoroTimer() {
    _pomodoroTicker?.cancel();
    setState(() => _pomodoroSecondsLeft = 25 * 60);
  }

  void _showGoalDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AppDialog(
          title: 'Meta diaria',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(_goalController.text);
                if (parsed != null) {
                  ref
                      .read(wellbeingControllerProvider.notifier)
                      .updateDailyGoal(parsed);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
          child: AppTextField(
            controller: _goalController,
            label: 'Objetivo (ml)',
            hint: '2000',
          ),
        );
      },
    );
  }
}
