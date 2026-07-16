import 'package:flutter/material.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/enums/journal_emotion.dart';

class JournalTimeline extends StatefulWidget {
  const JournalTimeline({
    required this.entries,
    required this.onEntryTap,
    super.key,
  });

  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onEntryTap;

  @override
  State<JournalTimeline> createState() => _JournalTimelineState();
}

class _JournalTimelineState extends State<JournalTimeline> {
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isEmpty) {
      return const OasisEmptyState(
        icon: AppIcons.empty,
        title: 'Cada día merece ser escuchado.',
        description: 'Tu historia tiene un lugar aquí.',
      );
    }

    final baseDay = DateUtils.dateOnly(DateTime.now());
    final days = List<DateTime>.generate(
      11,
      (index) => baseDay.add(Duration(days: index - 5)),
    );

    final entriesByDay = <DateTime, List<JournalEntry>>{};
    for (final entry in widget.entries) {
      final day = DateUtils.dateOnly(entry.createdAt);
      entriesByDay.putIfAbsent(day, () => []).add(entry);
    }

    final selectedEntries = entriesByDay[_selectedDay] ?? const [];
    final selected = selectedEntries.isEmpty
        ? null
        : (selectedEntries.toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
            .first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: OasisSpacing.sm),
            itemBuilder: (context, index) {
              final day = days[index];
              final dayEntries = entriesByDay[day] ?? const [];
              final predominant = dayEntries.isEmpty
                  ? null
                  : (dayEntries.toList()
                        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
                      .first
                      .emotion;
              final isSelected = DateUtils.isSameDay(day, _selectedDay);

              return OasisInteractive(
                onTap: () => setState(() => _selectedDay = day),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.all(OasisSpacing.sm),
                  decoration: BoxDecoration(
                    color: (predominant?.color ?? const Color(0xFF98A0A6))
                        .withValues(alpha: isSelected ? 0.40 : 0.28),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (predominant?.color ?? const Color(0xFF98A0A6))
                          : Colors.white.withValues(alpha: 0.28),
                      width: isSelected ? 1.2 : 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.day}/${day.month}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: OasisSpacing.xs),
                      Icon(
                        predominant?.icon ?? AppIcons.neutral,
                        color: predominant?.color ?? const Color(0xFF98A0A6),
                        size: AppIconSize.md.value,
                      ),
                      const Spacer(),
                      Text(
                        dayEntries.isEmpty
                            ? 'Sin registro'
                            : '${dayEntries.length} registro(s)',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: OasisSpacing.sm),
        AnimatedSwitcher(
          duration: MotionSpec.selectionFade,
          switchInCurve: MotionSpec.easeInOut,
          switchOutCurve: MotionSpec.easeInOut,
          child: selected == null
              ? OasisCard(
                  key: const ValueKey<String>('no-entry-day'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.14),
                    ),
                    padding: const EdgeInsets.all(OasisSpacing.md),
                    child: const Text(
                      'Cada día merece ser escuchado.',
                    ),
                  ),
                )
                  : OasisCard(
                  key: const ValueKey<String>('entry-card'),
                  onTap: () => widget.onEntryTap(selected),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.14),
                    ),
                    padding: const EdgeInsets.all(OasisSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selected.emotion.icon,
                              color: selected.emotion.color,
                              size: AppIconSize.md.value,
                            ),
                            const SizedBox(width: OasisSpacing.sm),
                            Expanded(
                              child: Text(
                                selected.emotion.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              '${selected.createdAt.day}/${selected.createdAt.month}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: OasisSpacing.sm),
                        _DetailLine(
                            label: 'Registro', value: selected.happenedToday),
                        _DetailLine(
                            label: 'Notas', value: selected.hardestPart),
                        _DetailLine(
                            label: 'Aprendizaje', value: selected.learnedToday),
                        _DetailLine(
                            label: 'Gratitud', value: selected.gratitude),
                        _DetailLine(
                          label: 'Emociones',
                          value: [
                            selected.emotion.label,
                            ...selected.secondaryEmotions
                          ].join(', '),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final safe = value.trim().isEmpty ? 'Sin registro' : value.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: OasisSpacing.xs),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: safe),
          ],
        ),
      ),
    );
  }
}
