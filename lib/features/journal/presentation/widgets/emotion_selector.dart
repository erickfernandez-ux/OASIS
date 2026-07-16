import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../domain/enums/journal_emotion.dart';

class EmotionSelector extends StatelessWidget {
  const EmotionSelector({
    required this.selectedEmotion,
    required this.onSelected,
    super.key,
  });

  final JournalEmotion? selectedEmotion;
  final ValueChanged<JournalEmotion> onSelected;

  static const List<_EmotionOption> _options = [
    _EmotionOption(
      emotion: JournalEmotion.happy,
      label: 'Alegre',
      subtitle: 'Ligereza suave',
      color: Color(0xFFE8C97D),
    ),
    _EmotionOption(
      emotion: JournalEmotion.serene,
      label: 'En calma',
      subtitle: 'Respirar despacio',
      color: Color(0xFF9CB8A0),
    ),
    _EmotionOption(
      emotion: JournalEmotion.neutral,
      label: 'Neutral',
      subtitle: 'Punto de partida',
      color: Color(0xFF9BA3A8),
    ),
    _EmotionOption(
      emotion: JournalEmotion.sad,
      label: 'Triste',
      subtitle: 'Peso suave',
      color: Color(0xFFB6A7D6),
    ),
    _EmotionOption(
      emotion: JournalEmotion.anxious,
      label: 'Ansioso',
      subtitle: 'Sistema alerta',
      color: Color(0xFFE1B86F),
    ),
    _EmotionOption(
      emotion: JournalEmotion.angry,
      label: 'Irritado',
      subtitle: 'Tensión contenida',
      color: Color(0xFFCC8E72),
    ),
    _EmotionOption(
      emotion: JournalEmotion.tired,
      label: 'Cansado',
      subtitle: 'Pausa necesaria',
      color: Color(0xFF8FA0B7),
    ),
    _EmotionOption(
      emotion: JournalEmotion.overwhelmed,
      label: 'Abrumado',
      subtitle: 'Todo junto',
      color: Color(0xFFDE9A8E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 480 ? 4 : 2;
        final tileWidth =
            (constraints.maxWidth - (OasisSpacing.sm * (columns - 1))) /
                columns;

        return Wrap(
          spacing: OasisSpacing.sm,
          runSpacing: OasisSpacing.sm,
          children: [
            for (final option in _options)
              SizedBox(
                width: tileWidth,
                child: _EmotionTile(
                  option: option,
                  selected: selectedEmotion == option.emotion,
                  onTap: () => onSelected(option.emotion),
                ),
              ),
          ],
        );
      },
    );
  }

}

class EmotionIntensityPicker extends StatelessWidget {
  const EmotionIntensityPicker({
    required this.emotion,
    required this.selectedLevel,
    required this.onLevelSelected,
    super.key,
  });

  final JournalEmotion emotion;
  final int selectedLevel;
  final ValueChanged<int> onLevelSelected;

  @override
  Widget build(BuildContext context) {
    final labels = _intensityLabelsFor(emotion);

    return OasisCard(
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué intensidad tiene ahora?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: OasisSpacing.xs),
          Text(
            'Cinco pasos suaves bastan.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: OasisSpacing.sm),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == labels.length - 1 ? 0 : OasisSpacing.xs,
                    ),
                    child: OasisInteractive(
                      onTap: () => onLevelSelected(i + 1),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: MotionSpec.selectionFade,
                        curve: MotionSpec.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          vertical: OasisSpacing.sm,
                          horizontal: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selectedLevel == i + 1
                              ? emotion.color.withValues(alpha: 0.18)
                              : OasisSurfaces.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selectedLevel == i + 1
                                ? emotion.color.withValues(alpha: 0.5)
                                : OasisSurfaces.border,
                          ),
                          boxShadow: selectedLevel == i + 1
                              ? [
                                  BoxShadow(
                                    color: emotion.color.withValues(alpha: 0.14),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : const [],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              labels[i].emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              labels[i].label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<_IntensityLabel> _intensityLabelsFor(JournalEmotion emotion) {
    return switch (emotion) {
      JournalEmotion.happy => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😊', 'Luz'),
          _IntensityLabel('😄', 'Brillo'),
          _IntensityLabel('😁', 'Vivo'),
          _IntensityLabel('🤩', 'Pleno'),
        ],
      JournalEmotion.serene => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😌', 'Calmo'),
          _IntensityLabel('🌿', 'Fresco'),
          _IntensityLabel('🕊️', 'Ligero'),
          _IntensityLabel('✨', 'Amplio'),
        ],
      JournalEmotion.neutral => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Plano'),
          _IntensityLabel('◦', 'Quieto'),
          _IntensityLabel('•', 'Notable'),
          _IntensityLabel('◉', 'Pleno'),
        ],
      JournalEmotion.sad => const [
          _IntensityLabel('😕', 'Suave'),
          _IntensityLabel('😔', 'Bajo'),
          _IntensityLabel('😢', 'Lento'),
          _IntensityLabel('😭', 'Profundo'),
          _IntensityLabel('💔', 'Muy alto'),
        ],
      JournalEmotion.anxious => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Atento'),
          _IntensityLabel('😟', 'Tenso'),
          _IntensityLabel('😣', 'Activo'),
          _IntensityLabel('😫', 'Muy alto'),
        ],
      JournalEmotion.frustrated => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Contener'),
          _IntensityLabel('😠', 'Tensión'),
          _IntensityLabel('😤', 'Fuerte'),
          _IntensityLabel('🔥', 'Muy alto'),
        ],
      JournalEmotion.angry => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Bajar'),
          _IntensityLabel('😠', 'Firme'),
          _IntensityLabel('😣', 'Intenso'),
          _IntensityLabel('💢', 'Muy alto'),
        ],
      JournalEmotion.tired => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Pausa'),
          _IntensityLabel('😴', 'Sueño'),
          _IntensityLabel('🥱', 'Pesado'),
          _IntensityLabel('😪', 'Muy alto'),
        ],
      JournalEmotion.overwhelmed => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Orden'),
          _IntensityLabel('😟', 'Carga'),
          _IntensityLabel('😣', 'Mucho'),
          _IntensityLabel('🤯', 'Muy alto'),
        ],
      _ => const [
          _IntensityLabel('🙂', 'Suave'),
          _IntensityLabel('😐', 'Neutral'),
          _IntensityLabel('😌', 'Bajo'),
          _IntensityLabel('🙂', 'Medio'),
          _IntensityLabel('✨', 'Alto'),
        ],
    };
  }
}

class _EmotionTile extends StatelessWidget {
  const _EmotionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _EmotionOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OasisInteractive(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: MotionSpec.selectionFade,
        curve: MotionSpec.easeInOut,
        padding: const EdgeInsets.all(OasisSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? option.color.withValues(alpha: 0.18)
              : OasisSurfaces.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? option.color.withValues(alpha: 0.46)
                : OasisSurfaces.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.emotion.icon,
              color: option.color,
              size: AppIconSize.lg.value + 2,
            ),
            const SizedBox(height: 4),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 2),
            Text(
              option.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionOption {
  const _EmotionOption({
    required this.emotion,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final JournalEmotion emotion;
  final String label;
  final String subtitle;
  final Color color;
}

class _IntensityLabel {
  const _IntensityLabel(this.emoji, this.label);

  final String emoji;
  final String label;
}
