import 'package:flutter/material.dart';

import '../../../../core/theme/icons/app_icons.dart';

/// Human-centered emotion options for the journal.
enum JournalEmotion {
  serene,
  happy,
  grateful,
  hopeful,
  neutral,
  tired,
  anxious,
  sad,
  frustrated,
  angry,
  overwhelmed,
}

extension JournalEmotionX on JournalEmotion {
  String get label => switch (this) {
        JournalEmotion.serene => 'Sereno',
        JournalEmotion.happy => 'Feliz',
        JournalEmotion.grateful => 'Agradecido',
        JournalEmotion.hopeful => 'Esperanzado',
        JournalEmotion.neutral => 'Neutral',
        JournalEmotion.tired => 'Cansado',
        JournalEmotion.anxious => 'Ansioso',
        JournalEmotion.sad => 'Triste',
        JournalEmotion.frustrated => 'Frustrado',
        JournalEmotion.angry => 'Enojado',
        JournalEmotion.overwhelmed => 'Abrumado',
      };

  Color get color => switch (this) {
        JournalEmotion.serene => const Color(0xFF7EA6A6),
        JournalEmotion.happy => const Color(0xFF9BB57E),
        JournalEmotion.grateful => const Color(0xFFB7A17A),
        JournalEmotion.hopeful => const Color(0xFF8FAD96),
        JournalEmotion.neutral => const Color(0xFF98A0A6),
        JournalEmotion.tired => const Color(0xFF9A8F92),
        JournalEmotion.anxious => const Color(0xFF9D9AAE),
        JournalEmotion.sad => const Color(0xFF8D9EB2),
        JournalEmotion.frustrated => const Color(0xFFB08A78),
        JournalEmotion.angry => const Color(0xFFB3746D),
        JournalEmotion.overwhelmed => const Color(0xFF8599A4),
      };

  IconData get icon => switch (this) {
        JournalEmotion.serene => AppIcons.serene,
        JournalEmotion.happy => AppIcons.happy,
        JournalEmotion.grateful => AppIcons.grateful,
        JournalEmotion.hopeful => AppIcons.hopeful,
        JournalEmotion.neutral => AppIcons.neutral,
        JournalEmotion.tired => AppIcons.tired,
        JournalEmotion.anxious => AppIcons.anxious,
        JournalEmotion.sad => AppIcons.sad,
        JournalEmotion.frustrated => AppIcons.frustrated,
        JournalEmotion.angry => AppIcons.angry,
        JournalEmotion.overwhelmed => AppIcons.overwhelmed,
      };
}
