import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/design_system.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/enums/journal_emotion.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    required this.entry,
    required this.onTap,
    super.key,
  });

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;

    return OasisCard(
      onTap: onTap,
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(entry.emotion.icon,
              color: entry.emotion.color, size: AppIconSize.lg.value),
          const SizedBox(width: OasisSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('d MMM, yyyy', 'es').format(entry.updatedAt),
                        style: typography.titleSmall,
                      ),
                    ),
                    OasisStatusChip(
                        label: entry.emotion.label, color: entry.emotion.color),
                  ],
                ),
                const SizedBox(height: OasisSpacing.xs),
                Text(
                  entry.firstLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyMedium,
                ),
                const SizedBox(height: OasisSpacing.sm),
                Text(
                  _bodyPreview(entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodySmall,
                ),
                const SizedBox(height: OasisSpacing.xs),
                Wrap(
                  spacing: OasisSpacing.xs,
                  runSpacing: OasisSpacing.xs,
                  children: [
                    OasisStatusChip(
                        label: 'Ansiedad ${entry.anxiety.round()}/10',
                        color: const Color(0xFF9D9AAE)),
                    OasisStatusChip(
                        label: 'Estrés ${entry.stress.round()}/10',
                        color: const Color(0xFFB08A78)),
                    OasisStatusChip(
                        label: 'Energía ${entry.energy.round()}/10',
                        color: const Color(0xFF8FAD96)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bodyPreview(JournalEntry entry) {
    if (entry.bodyCheckIns.isEmpty) {
      return 'Sin check-ins corporales';
    }
    return entry.bodyCheckIns.join(' · ');
  }
}
