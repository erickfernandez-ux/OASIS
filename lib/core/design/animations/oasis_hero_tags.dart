import 'package:flutter/foundation.dart';

@immutable
class OasisHeroTags {
  const OasisHeroTags._();

  static const String agendaHeader = 'hero-agenda-header';
  static const String journalHeader = 'hero-journal-header';
  static const String settingsHeader = 'hero-settings-header';
  static const String notesHeader = 'hero-notes-header';
  static const String notesComposer = 'hero-notes-composer';
  static const String journalComposer = 'hero-journal-composer';
  static const String agendaComposer = 'hero-agenda-composer';
  static const String settingsShelter = 'hero-settings-shelter';

  static String noteCard(String id) => 'hero-note-card-$id';
}
