import '../../domain/entities/quiet_hours.dart';
import '../../domain/entities/ritual.dart';

abstract interface class RitualScheduler {
  Future<void> initialize({
    required Future<void> Function(String route) onOpenRoute,
    required Future<void> Function(String actionId, String? payload) onAction,
  });

  Future<void> syncRituals({
    required List<Ritual> rituals,
    required QuietHours quietHours,
  });

  Future<void> clearAll();

  Future<void> scheduleSnoozeFromPayload(
    String payload,
    Duration delay,
  );
}

class NoopRitualScheduler implements RitualScheduler {
  const NoopRitualScheduler();

  @override
  Future<void> initialize({
    required Future<void> Function(String route) onOpenRoute,
    required Future<void> Function(String actionId, String? payload) onAction,
  }) async {}

  @override
  Future<void> syncRituals({
    required List<Ritual> rituals,
    required QuietHours quietHours,
  }) async {
    // TODO(rituals): map rituals and quiet hours to background scheduling.
    // Intentionally no-op while notification stack is not approved.
  }

  @override
  Future<void> clearAll() async {
    // TODO(rituals): clear pending scheduled ritual triggers.
    // Intentionally no-op while notification stack is not approved.
  }

  @override
  Future<void> scheduleSnoozeFromPayload(
    String payload,
    Duration delay,
  ) async {}
}
