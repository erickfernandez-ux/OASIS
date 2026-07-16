import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../shared/providers/app_message_system_provider.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../settings/presentation/providers/settings_controller.dart';
import '../../application/services/journal_pdf_export_service.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/enums/journal_emotion.dart';
import '../providers/journal_controller.dart';
import '../providers/journal_pdf_export_provider.dart';
import '../widgets/emotion_selector.dart';
import '../widgets/journal_timeline.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _happenedController = TextEditingController();
  final _bestPartController = TextEditingController();
  final _hardestPartController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _learnedController = TextEditingController();

  JournalEmotion? _selectedEmotion;
  final Set<String> _secondaryEmotions = <String>{};

  double _intensity = 5;
  double _energy = 5;
  double _sleepHours = 7;
  double _anxiety = 5;
  double _irritability = 4;
  double _pain = 3;
  double _stress = 5;

  bool _selfCareWater = false;
  bool _selfCareFood = false;
  bool _selfCareMovement = false;
  bool _selfCareRest = false;
  bool _happenedExpanded = false;
  bool _bestPartExpanded = false;
  bool _hardestPartExpanded = false;
  bool _gratitudeExpanded = false;
  bool _learningExpanded = false;
  bool _isExportingPdf = false;
  JournalPdfExportResult? _lastExportResult;

  JournalEntry? _editingEntry;

  // Reserved for a future second emotion without changing the data shape now.

  @override
  void dispose() {
    _happenedController.dispose();
    _bestPartController.dispose();
    _hardestPartController.dispose();
    _gratitudeController.dispose();
    _learnedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalControllerProvider);

    return OasisScreenShell(
      title: 'Diario',
      subtitle: 'Tu diario emocional para entenderte con amabilidad.',
      accent: OasisSurfaces.journalAccent,
      appBarActions: [
        IconButton(
          tooltip: _lastExportResult == null
              ? 'Exportar ultimos 30 dias'
              : 'Compartir ultimo PDF',
          onPressed: _isExportingPdf
              ? null
              : () {
                  final entries = state.valueOrNull;
                  if (entries == null) {
                    return;
                  }
                  if (_lastExportResult != null) {
                    _shareLatestPdf(context);
                    return;
                  }
                  _exportLast30Days(context, entries);
                },
          icon: Icon(
            _lastExportResult == null ? AppIcons.share : AppIcons.forward,
          ),
        ),
      ],
      child: state.when(
        data: (entries) => _buildBody(context, entries),
        loading: () => const Padding(
          padding: EdgeInsets.only(top: OasisSpacing.xl),
          child: Center(
            child: LoadingIndicator(type: LoadingType.breathingPaper),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.only(top: OasisSpacing.xl),
          child: Text(error.toString()),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<JournalEntry> entries) {
    final typography = context.appTypography;
    final insights = _buildInsights(entries);
    final calmMessage =
        ref.watch(appMessageSystemProvider).calmMessageFor(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OasisCard(
          padding: const EdgeInsets.all(OasisSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Qué emoción está más presente ahora?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: OasisSpacing.xs),
              Text(
                'Elige la que mejor se parezca a este momento.',
                style: typography.body,
              ),
              const SizedBox(height: OasisSpacing.sm),
              EmotionSelector(
                selectedEmotion: _selectedEmotion,
                onSelected: (emotion) {
                  setState(() {
                    _selectedEmotion = emotion;
                    if (_intensity < 1 || _intensity > 5) {
                      _intensity = 3;
                    }
                  });
                },
              ),
              AnimatedSize(
                duration: MotionSpec.selectionFade,
                curve: MotionSpec.easeInOut,
                child: AnimatedSwitcher(
                  duration: MotionSpec.selectionFade,
                  switchInCurve: MotionSpec.easeInOut,
                  switchOutCurve: MotionSpec.easeInOut,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _selectedEmotion == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: OasisSpacing.sm),
                          child: EmotionIntensityPicker(
                            key: ValueKey<JournalEmotion>(_selectedEmotion!),
                            emotion: _selectedEmotion!,
                            selectedLevel: _intensity.round().clamp(1, 5),
                            onLevelSelected: (level) =>
                                setState(() => _intensity = level.toDouble()),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: OasisSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.push(RouteConstants.safetyPlan),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text('Plan de seguridad'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        Hero(
          tag: OasisHeroTags.journalHeader,
          child: Material(
            type: MaterialType.transparency,
            child: HopeCard(
              title: 'Este espacio es íntimo y seguro',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    calmMessage,
                    style: typography.body,
                  ),
                  const SizedBox(height: OasisSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Plan de seguridad',
                      onPressed: () => context.push(RouteConstants.safetyPlan),
                      icon: Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        const SafetySection(
          title: 'Preparacion de expresion multimedia',
          subtitle: 'Listo para foto, audio y etiquetas en la siguiente fase.',
          child: Wrap(
            spacing: OasisSpacing.sm,
            runSpacing: OasisSpacing.sm,
            children: [
              OasisChip(label: 'Foto (proximamente)', selected: false),
              OasisChip(label: 'Audio (proximamente)', selected: false),
              OasisChip(label: 'Etiquetas (proximamente)', selected: false),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Exportacion PDF',
          subtitle: 'Exporta tus ultimos 30 dias como cuaderno personal.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OasisButton(
                label: _isExportingPdf
                    ? 'Exportando ultimos 30 dias...'
                    : 'Exportar ultimos 30 dias',
                leading: AppIcons.share,
                onPressed: _isExportingPdf
                    ? null
                    : () => _exportLast30Days(context, entries),
              ),
              if (_lastExportResult != null) ...[
                const SizedBox(height: OasisSpacing.sm),
                OasisButton(
                  label: 'Compartir ultimo PDF',
                  leading: AppIcons.forward,
                  onPressed: _isExportingPdf
                      ? null
                      : () => _shareLatestPdf(context),
                ),
                const SizedBox(height: OasisSpacing.xs),
                Text(
                  'Guardado: ${_lastExportResult!.filePath}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        _CollapsibleReflection(
          title: '¿Qué ocurrió hoy?',
          collapsedDescription: 'Cuéntalo con tus palabras, sin prisa.',
          icon: Icons.menu_book_rounded,
          expanded: _happenedExpanded,
          onToggle: () =>
              setState(() => _happenedExpanded = !_happenedExpanded),
          child: _JournalNotebookField(
            controller: _happenedController,
            hint: 'Cuéntalo con tus palabras',
            minLines: 4,
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        _CollapsibleReflection(
          title: '¿Qué fue lo mejor de tu día?',
          collapsedDescription: 'Guarda ese detalle que te hizo bien.',
          icon: Icons.wb_sunny_outlined,
          expanded: _bestPartExpanded,
          onToggle: () =>
              setState(() => _bestPartExpanded = !_bestPartExpanded),
          child: _JournalNotebookField(
            controller: _bestPartController,
            hint: 'Lo que quieres recordar',
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        _CollapsibleReflection(
          title: '¿Qué fue lo más difícil?',
          collapsedDescription: 'Nómbralo con amabilidad, sin exigencias.',
          icon: Icons.landscape_outlined,
          expanded: _hardestPartExpanded,
          onToggle: () =>
              setState(() => _hardestPartExpanded = !_hardestPartExpanded),
          child: _JournalNotebookField(
            controller: _hardestPartController,
            hint: 'Lo que te costó sostener',
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        _CollapsibleReflection(
          title: 'Hoy agradezco...',
          collapsedDescription: 'Una pequeña gratitud también cuenta.',
          icon: Icons.spa_outlined,
          expanded: _gratitudeExpanded,
          onToggle: () =>
              setState(() => _gratitudeExpanded = !_gratitudeExpanded),
          child: _JournalNotebookField(
            controller: _gratitudeController,
            hint: 'Agradezco...',
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        _CollapsibleReflection(
          title: '¿Qué aprendí hoy?',
          collapsedDescription: 'Una idea breve puede iluminar mañana.',
          icon: Icons.lightbulb_outline,
          expanded: _learningExpanded,
          onToggle: () =>
              setState(() => _learningExpanded = !_learningExpanded),
          child: _JournalNotebookField(
            controller: _learnedController,
            hint: 'Hoy aprendí que...',
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Pequeños actos de autocuidado',
          subtitle: 'Gestos simples que sostienen tu día.',
          child: Wrap(
            spacing: OasisSpacing.sm,
            runSpacing: OasisSpacing.sm,
            children: [
              OasisChip(
                label: 'Agua',
                selected: _selfCareWater,
                onTap: () => setState(() => _selfCareWater = !_selfCareWater),
              ),
              OasisChip(
                label: 'Comida',
                selected: _selfCareFood,
                onTap: () => setState(() => _selfCareFood = !_selfCareFood),
              ),
              OasisChip(
                label: 'Movimiento',
                selected: _selfCareMovement,
                onTap: () =>
                    setState(() => _selfCareMovement = !_selfCareMovement),
              ),
              OasisChip(
                label: 'Descanso',
                selected: _selfCareRest,
                onTap: () => setState(() => _selfCareRest = !_selfCareRest),
              ),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: double.infinity,
            child: OasisButton(
              label: _editingEntry == null
                  ? 'Guardar registro emocional'
                  : 'Actualizar registro emocional',
              leading: AppIcons.success,
              onPressed: () => _saveEntry(context),
            ),
          ),
        ),
        const SizedBox(height: OasisSpacing.xl),
        const OasisSectionHeader(
          title: 'Patrones emocionales',
          subtitle:
              'Los pródromos son pequeños cambios que, con el tiempo, pueden ayudarte a reconocer cómo evoluciona tu estado emocional.',
        ),
        const SizedBox(height: OasisSpacing.sm),
        for (final insight in insights) ...[
          InsightCard(message: insight, icon: AppIcons.info),
          const SizedBox(height: OasisSpacing.sm),
        ],
        const SizedBox(height: OasisSpacing.lg),
        const OasisSectionHeader(
          title: 'Timeline',
          subtitle: 'Tu evolución emocional en tarjetas.',
        ),
        const SizedBox(height: OasisSpacing.sm),
        JournalTimeline(
          entries: entries,
          onEntryTap: _loadEntryForEditing,
        ),
      ],
    );
  }

  List<String> _buildInsights(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return ['🌿 Tal vez hoy sea un buen momento para escribir unas líneas.'];
    }

    final insights = <String>[];
    final recent3 = entries.take(3).toList();
    final recent7 = entries.take(7).toList();

    if (recent3.length == 3 && recent3.every((entry) => entry.anxiety >= 7)) {
      insights.add(
          'Llevas 3 días con ansiedad alta. Puede ayudarte revisar tu Safety Plan.');
    }

    if (recent7.isNotEmpty && recent7.every((entry) => !entry.selfCareWater)) {
      insights.add(
          'Esta semana no aparece hidratación. Empezar con un vaso ahora puede ayudarte.');
    }

    if (recent3.length == 3 &&
        recent3
            .every((entry) => entry.stress >= 7 && entry.irritability >= 6)) {
      insights.add(
          'Estrés e irritabilidad siguen altos. Prueba una pausa corta de respiración y movimiento suave.');
    }

    if (insights.isEmpty) {
      insights.add(
          'Tu registro muestra constancia. Este diario puede ayudarte a anticipar días difíciles.');
    }

    return insights;
  }

  void _loadEntryForEditing(JournalEntry entry) {
    setState(() {
      _editingEntry = entry;
      _selectedEmotion = entry.emotion;
      _secondaryEmotions
        ..clear()
        ..addAll(entry.secondaryEmotions);
      _intensity = entry.intensity;
      _energy = entry.energy;
      _sleepHours = entry.sleepHours;
      _anxiety = entry.anxiety;
      _irritability = entry.irritability;
      _pain = entry.pain;
      _stress = entry.stress;
      _happenedController.text = entry.happenedToday;
      _bestPartController.text = entry.bestPart;
      _hardestPartController.text = entry.hardestPart;
      _gratitudeController.text = entry.gratitude;
      _learnedController.text = entry.learnedToday;
      _selfCareWater = entry.selfCareWater;
      _selfCareFood = entry.selfCareFood;
      _selfCareMovement = entry.selfCareMovement;
      _selfCareRest = entry.selfCareRest;
    });
  }

  Future<void> _saveEntry(BuildContext context) async {
    final now = DateTime.now();
    final emotion = _selectedEmotion ?? JournalEmotion.neutral;
    final bodyCheckIns = <String>[
      if (_selfCareWater) 'Agua',
      if (_selfCareFood) 'Comida',
      if (_selfCareMovement) 'Movimiento',
      if (_selfCareRest) 'Descanso',
    ];

    final entry = JournalEntry(
      id: _editingEntry?.id ?? '',
      emotion: emotion,
      secondaryEmotions: _secondaryEmotions.toList(),
      intensity: _intensity,
      energy: _energy,
      sleepHours: _sleepHours,
      anxiety: _anxiety,
      irritability: _irritability,
      medicationTaken: false,
      pain: _pain,
      stress: _stress,
      happenedToday: _happenedController.text.trim(),
      bestPart: _bestPartController.text.trim(),
      hardestPart: _hardestPartController.text.trim(),
      gratitude: _gratitudeController.text.trim(),
      learnedToday: _learnedController.text.trim(),
      selfCareWater: _selfCareWater,
      selfCareFood: _selfCareFood,
      selfCareMedication: false,
      selfCareMovement: _selfCareMovement,
      selfCareRest: _selfCareRest,
      bodyCheckIns: bodyCheckIns,
      createdAt: _editingEntry?.createdAt ?? now,
      updatedAt: now,
    );

    // Future feedback cues: haptic journal.save and sound journal.
    await ref.read(journalControllerProvider.notifier).saveEntry(entry);
    if (!mounted) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _editingEntry = null;
    });

    messenger.showSnackBar(
      const SnackBar(
          content: Text(
              'Registro emocional guardado. Gracias por dedicarte este momento.')),
    );
  }

  Future<void> _exportLast30Days(
    BuildContext context,
    List<JournalEntry> entries,
  ) async {
    setState(() => _isExportingPdf = true);

    try {
      final userName =
          ref.read(settingsControllerProvider).valueOrNull?.preferredName ?? '';
      final service = ref.read(journalPdfExportServiceProvider);

      final result = await service.exportLast30Days(
        entries: entries,
        userName: userName,
      );

      if (!mounted || !context.mounted) {
        return;
      }

      setState(() => _lastExportResult = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF generado: ${result.fileName} (${result.entryCount} registros).',
          ),
        ),
      );
    } catch (error) {
      if (!mounted || !context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible exportar el PDF: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  Future<void> _shareLatestPdf(BuildContext context) async {
    final result = _lastExportResult;
    if (result == null) {
      return;
    }

    try {
      final service = ref.read(journalPdfExportServiceProvider);
      await service.shareExportedPdf(result);
    } catch (error) {
      if (!mounted || !context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible compartir el PDF: $error')),
      );
    }
  }
}

class _CollapsibleReflection extends StatelessWidget {
  const _CollapsibleReflection({
    required this.title,
    required this.collapsedDescription,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  final String title;
  final String collapsedDescription;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OasisCard(
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: OasisSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                    ),
                    child: Icon(icon, size: 16),
                  ),
                  const SizedBox(width: OasisSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          collapsedDescription,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: MotionSpec.selectionFade,
                    curve: MotionSpec.easeInOut,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: MotionSpec.selectionFade,
            curve: MotionSpec.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: OasisSpacing.sm),
                    child: TweenAnimationBuilder<double>(
                      duration: MotionSpec.selectionFade,
                      curve: MotionSpec.easeInOut,
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, panelChild) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 10),
                          child: Opacity(opacity: value, child: panelChild),
                        );
                      },
                      child: child,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _JournalNotebookField extends StatelessWidget {
  const _JournalNotebookField({
    required this.controller,
    required this.hint,
    this.minLines = 3,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines + 2,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.26),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.45),
          ),
        ),
        contentPadding: const EdgeInsets.all(OasisSpacing.md),
      ),
    );
  }
}
