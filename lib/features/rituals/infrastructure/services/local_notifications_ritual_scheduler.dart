import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/local_json_store.dart';
import '../../../medications/domain/repositories/medication_repository.dart';
import '../../domain/entities/quiet_hours.dart';
import '../../domain/entities/ritual.dart';
import '../../domain/enums/ritual_type.dart';
import 'ritual_message_service.dart';
import 'ritual_scheduler.dart';

class LocalNotificationsRitualScheduler implements RitualScheduler {
  LocalNotificationsRitualScheduler({
    required MedicationRepository medicationRepository,
    required RitualMessageService messageService,
  })  : _medicationRepository = medicationRepository,
        _messageService = messageService;

  static const _androidChannelId = 'oasis_rituals';
  static const _androidChannelName = 'Rituales y Recordatorios';
  static const _androidChannelDescription =
      'Invitaciones suaves de OASIS para sostener tu ritmo diario.';

  static const _actionMedicationTaken = 'medication_taken';
  static const _actionHydrationDone = 'hydration_done';
  static const _actionOpenJournal = 'open_journal';
  static const _actionSnooze15 = 'snooze_15';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final MedicationRepository _medicationRepository;
  final RitualMessageService _messageService;

  Future<void> Function(String route)? _onOpenRoute;
  Future<void> Function(String actionId, String? payload)? _onAction;
  bool _initialized = false;

  @override
  Future<void> initialize({
    required Future<void> Function(String route) onOpenRoute,
    required Future<void> Function(String actionId, String? payload) onAction,
  }) async {
    _onOpenRoute = onOpenRoute;
    _onAction = onAction;

    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  @override
  Future<void> syncRituals({
    required List<Ritual> rituals,
    required QuietHours quietHours,
  }) async {
    await clearAll();

    final settings = await LocalJsonStore.readMap('settings');
    final notificationsEnabled =
        (settings?['notificationsEnabled'] as bool?) ?? true;
    if (!notificationsEnabled) {
      return;
    }

    final preferredName = (settings?['preferredName'] as String?)?.trim();

    final ritualsState = await LocalJsonStore.readMap('rituals_state');
    final medicationCriticalInQuietHours =
        (ritualsState?['medicationCriticalInQuietHours'] as bool?) ?? false;

    for (final ritual in rituals.where((item) => item.enabled)) {
      if (ritual.type == RitualType.medication) {
        await _scheduleMedicationRitual(
          ritual: ritual,
          quietHours: quietHours,
          criticalInQuietHours: medicationCriticalInQuietHours,
          preferredName: preferredName,
        );
        continue;
      }

      final next = _nextInstance(ritual.hour, ritual.minute);
      if (_isBlockedByQuietHours(next, quietHours)) {
        continue;
      }

      final payload = _payloadForRitual(ritual);
      await _plugin.zonedSchedule(
        _notificationIdFor(payload),
        _messageService.titleFor(
          ritual,
          preferredName: preferredName,
          now: next,
        ),
        _messageService.bodyFor(ritual, now: next),
        next,
        _detailsFor(ritual),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    }
  }

  @override
  Future<void> clearAll() async {
    await _plugin.cancelAll();
  }

  @override
  Future<void> scheduleSnoozeFromPayload(
    String payload,
    Duration delay,
  ) async {
    final data = _decodePayload(payload);
    final title = (data['title'] as String?) ?? 'Recordatorio OASIS';
    final body = (data['body'] as String?) ?? 'Volvemos en un momento.';

    final date = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      _notificationIdFor('$payload-snooze'),
      title,
      body,
      date,
      _detailsForSnooze(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> _scheduleMedicationRitual({
    required Ritual ritual,
    required QuietHours quietHours,
    required bool criticalInQuietHours,
    required String? preferredName,
  }) async {
    final meds = await _medicationRepository.getActiveMedications();

    for (final medication in meds) {
      for (final schedule in medication.schedule) {
        final parsed = _parseTime(schedule);
        if (parsed == null) continue;

        final next = _nextInstance(parsed.$1, parsed.$2);
        final blocked = _isBlockedByQuietHours(next, quietHours);
        if (blocked && !criticalInQuietHours) {
          continue;
        }

        final payload = jsonEncode({
          'kind': 'medication',
          'route': RouteConstants.wellbeing,
          'ritualId': ritual.id,
          'medicationId': medication.id,
          'title': 'Hora de tu medicacion',
          'body': '${medication.name} · ${medication.dosage}',
        });

        final title = _messageService.titleFor(
          ritual,
          preferredName: preferredName,
          now: next,
        );
        final body = '${medication.name} · ${medication.dosage}';

        await _plugin.zonedSchedule(
          _notificationIdFor(payload),
          title,
          body,
          next,
          _detailsForMedication(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      }
    }
  }

  NotificationDetails _detailsFor(Ritual ritual) {
    final hasSnooze = ritual.type == RitualType.hydration ||
        ritual.type == RitualType.movement ||
        ritual.type == RitualType.medication;

    final actions = <AndroidNotificationAction>[];

    if (ritual.type == RitualType.medication) {
      actions.add(
        const AndroidNotificationAction(
          _actionMedicationTaken,
          '✓ Tomada',
          showsUserInterface: false,
        ),
      );
    }

    if (ritual.type == RitualType.hydration) {
      actions.add(
        const AndroidNotificationAction(
          _actionHydrationDone,
          '✓ Ya bebi agua',
          showsUserInterface: false,
        ),
      );
    }

    if (ritual.type == RitualType.journal || ritual.type == RitualType.night) {
      actions.add(
        const AndroidNotificationAction(
          _actionOpenJournal,
          'Abrir Journal',
        ),
      );
    }

    if (hasSnooze) {
      actions.add(
        const AndroidNotificationAction(
          _actionSnooze15,
          'Posponer 15 min',
        ),
      );
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
        actions: actions,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  NotificationDetails _detailsForMedication() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            _actionMedicationTaken,
            '✓ Tomada',
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            _actionSnooze15,
            'Posponer 15 min',
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  NotificationDetails _detailsForSnooze() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  bool _isBlockedByQuietHours(
    tz.TZDateTime date,
    QuietHours quietHours,
  ) {
    if (!quietHours.enabled) return false;

    final minute = date.hour * 60 + date.minute;
    final start = quietHours.startHour * 60 + quietHours.startMinute;
    final end = quietHours.endHour * 60 + quietHours.endMinute;

    if (start == end) {
      return false;
    }

    if (start < end) {
      return minute >= start && minute < end;
    }

    return minute >= start || minute < end;
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  (int, int)? _parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return (hour, minute);
  }

  String _payloadForRitual(Ritual ritual) {
    final route = switch (ritual.type) {
      RitualType.morning => RouteConstants.home,
      RitualType.night => RouteConstants.journal,
      RitualType.journal => RouteConstants.journal,
      RitualType.medication => RouteConstants.wellbeing,
      RitualType.hydration => RouteConstants.wellbeing,
      RitualType.movement => RouteConstants.wellbeing,
      RitualType.agenda => RouteConstants.agenda,
    };

    return jsonEncode({
      'kind': ritual.type.name,
      'route': route,
      'ritualId': ritual.id,
      'title': _messageService.titleFor(ritual),
      'body': _messageService.bodyFor(ritual),
    });
  }

  int _notificationIdFor(String source) {
    return source.hashCode.abs() % 2147480000;
  }

  Map<String, dynamic> _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  Future<void> _handleNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    final actionId = response.actionId;

    if (actionId != null && actionId.isNotEmpty) {
      await _onAction?.call(actionId, payload);
      return;
    }

    final data = _decodePayload(payload);
    final route = (data['route'] as String?) ?? RouteConstants.home;
    await _onOpenRoute?.call(route);
  }
}
