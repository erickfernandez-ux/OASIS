import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../domain/entities/safety_contact.dart';
import '../../domain/entities/safety_plan.dart';
import '../../domain/entities/safety_professional.dart';

class SafetyPlanController extends AsyncNotifier<SafetyPlan> {
  final Uuid _uuid = const Uuid();

  @override
  Future<SafetyPlan> build() {
    return ref.read(getSafetyPlanProvider)();
  }

  Future<void> _persist(SafetyPlan next) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final saved = await ref.read(updateSafetyPlanProvider)(next);
      return saved;
    });
  }

  Future<void> setCrisisMode(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(setCrisisModeProvider)(
          current: current, enabled: enabled);
    });
  }

  Future<void> addWarningSign(String value) async {
    final current = state.value;
    final trimmed = value.trim();
    if (current == null || trimmed.isEmpty) return;
    await _persist(
        current.copyWith(warningSigns: [...current.warningSigns, trimmed]));
  }

  Future<void> addSelfAction(String value) async {
    final current = state.value;
    final trimmed = value.trim();
    if (current == null || trimmed.isEmpty) return;
    await _persist(
        current.copyWith(selfActions: [...current.selfActions, trimmed]));
  }

  Future<void> addSafePlace(String value) async {
    final current = state.value;
    final trimmed = value.trim();
    if (current == null || trimmed.isEmpty) return;
    await _persist(
        current.copyWith(safePlaces: [...current.safePlaces, trimmed]));
  }

  Future<void> addReason(String value) async {
    final current = state.value;
    final trimmed = value.trim();
    if (current == null || trimmed.isEmpty) return;
    await _persist(
        current.copyWith(reasonsToStay: [...current.reasonsToStay, trimmed]));
  }

  Future<void> addContact({
    required String name,
    required String relationship,
    required String phone,
    required String message,
  }) async {
    final current = state.value;
    if (current == null || name.trim().isEmpty) return;

    final contact = SafetyContact(
      id: _uuid.v4(),
      name: name.trim(),
      relationship: relationship.trim(),
      phone: phone.trim(),
      quickMessage: message.trim(),
    );

    await _persist(current.copyWith(contacts: [...current.contacts, contact]));
  }

  Future<void> addProfessional({
    required String name,
    required String role,
    required String phone,
  }) async {
    final current = state.value;
    if (current == null || name.trim().isEmpty) return;

    final professional = SafetyProfessional(
      id: _uuid.v4(),
      name: name.trim(),
      role: role.trim(),
      phone: phone.trim(),
    );

    await _persist(current
        .copyWith(professionals: [...current.professionals, professional]));
  }

  Future<void> removeWarningSign(int index) async {
    final current = state.value;
    if (current == null || index < 0 || index >= current.warningSigns.length) {
      return;
    }
    final next = [...current.warningSigns]..removeAt(index);
    await _persist(current.copyWith(warningSigns: next));
  }

  Future<void> removeSelfAction(int index) async {
    final current = state.value;
    if (current == null || index < 0 || index >= current.selfActions.length) {
      return;
    }
    final next = [...current.selfActions]..removeAt(index);
    await _persist(current.copyWith(selfActions: next));
  }

  Future<void> removeSafePlace(int index) async {
    final current = state.value;
    if (current == null || index < 0 || index >= current.safePlaces.length) {
      return;
    }
    final next = [...current.safePlaces]..removeAt(index);
    await _persist(current.copyWith(safePlaces: next));
  }

  Future<void> removeReason(int index) async {
    final current = state.value;
    if (current == null || index < 0 || index >= current.reasonsToStay.length) {
      return;
    }
    final next = [...current.reasonsToStay]..removeAt(index);
    await _persist(current.copyWith(reasonsToStay: next));
  }

  Future<void> removeContact(String id) async {
    final current = state.value;
    if (current == null) return;
    await _persist(current.copyWith(
        contacts: current.contacts.where((item) => item.id != id).toList()));
  }

  Future<void> removeProfessional(String id) async {
    final current = state.value;
    if (current == null) return;
    await _persist(current.copyWith(
        professionals:
            current.professionals.where((item) => item.id != id).toList()));
  }
}

final safetyPlanControllerProvider =
    AsyncNotifierProvider<SafetyPlanController, SafetyPlan>(
  SafetyPlanController.new,
);
