import 'package:flutter/material.dart';

/// Semantic icon sizes.
enum AppIconSize {
  sm(16),
  md(24),
  lg(32),
  xl(48);

  final double value;
  const AppIconSize(this.value);
}

/// Centralized icon system.
/// No widget should use Icons.xxx directly.
class AppIcons {
  AppIcons._();

  // --- Navigation ---
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData agenda = Icons.calendar_today_outlined;
  static const IconData agendaFilled = Icons.calendar_today;
  static const IconData notes = Icons.note_outlined;
  static const IconData notesFilled = Icons.note;
  static const IconData journal = Icons.auto_stories_outlined;
  static const IconData journalFilled = Icons.auto_stories;
  static const IconData wellbeing = Icons.favorite_outline;
  static const IconData wellbeingFilled = Icons.favorite;
  static const IconData settings = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;

  // --- Actions ---
  static const IconData add = Icons.add;
  static const IconData search = Icons.search;
  static const IconData close = Icons.close;
  static const IconData back = Icons.arrow_back;
  static const IconData forward = Icons.arrow_forward;
  static const IconData more = Icons.more_vert;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData share = Icons.share_outlined;
  static const IconData filter = Icons.filter_list_outlined;

  // --- Content ---
  static const IconData empty = Icons.inbox_outlined;
  static const IconData folder = Icons.folder_outlined;
  static const IconData image = Icons.image_outlined;
  static const IconData attachment = Icons.attach_file_outlined;
  static const IconData phone = Icons.call_outlined;
  static const IconData support = Icons.support_agent_outlined;
  static const IconData hope = Icons.lightbulb_outline;
  static const IconData breathing = Icons.air;
  static const IconData safety = Icons.health_and_safety_outlined;
  static const IconData serene = Icons.spa_outlined;
  static const IconData happy = Icons.sentiment_satisfied_alt_outlined;
  static const IconData grateful = Icons.favorite_border;
  static const IconData hopeful = Icons.wb_sunny_outlined;
  static const IconData neutral = Icons.radio_button_unchecked;
  static const IconData tired = Icons.bedtime_outlined;
  static const IconData anxious = Icons.psychology_outlined;
  static const IconData sad = Icons.cloud_outlined;
  static const IconData frustrated = Icons.trending_down_outlined;
  static const IconData angry = Icons.whatshot_outlined;
  static const IconData overwhelmed = Icons.waves_outlined;

  // --- Status ---
  static const IconData success = Icons.check_circle_outline;
  static const IconData successFilled = Icons.check_circle;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData error = Icons.error_outline;
  static const IconData info = Icons.info_outline;
  static const IconData loading = Icons.refresh;

  // --- Accessibility helpers ---
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
}
