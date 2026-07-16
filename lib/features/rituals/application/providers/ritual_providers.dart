import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../domain/entities/quiet_hours.dart';
import '../../domain/entities/ritual.dart';
import '../../infrastructure/services/local_notifications_ritual_scheduler.dart';
import '../../infrastructure/services/ritual_message_service.dart';
import '../../infrastructure/services/ritual_scheduler.dart';

final ritualsProvider = Provider<List<Ritual>>((ref) {
  // TODO(rituals): connect use cases and persistence for ritual list.
  return const <Ritual>[];
});

final quietHoursProvider = Provider<QuietHours>((ref) {
  // TODO(rituals): connect use case that reads configured quiet hours.
  return const QuietHours(
    enabled: false,
    startHour: 22,
    startMinute: 0,
    endHour: 7,
    endMinute: 0,
  );
});

final ritualSchedulerProvider = Provider<RitualScheduler>((ref) {
  final medicationRepository = ref.watch(medicationRepositoryProvider);
  return LocalNotificationsRitualScheduler(
    medicationRepository: medicationRepository,
    messageService: const DefaultRitualMessageService(),
  );
});
