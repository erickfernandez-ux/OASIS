import 'package:uuid/uuid.dart';

import '../../../../core/privacy/privacy_store_manifest.dart';
import '../../../../core/utils/local_json_store.dart';
import '../../domain/entities/safety_contact.dart';
import '../../domain/entities/safety_plan.dart';
import '../../domain/entities/safety_professional.dart';
import '../../domain/repositories/safety_plan_repository.dart';

class MockSafetyPlanRepository implements SafetyPlanRepository {
  MockSafetyPlanRepository() {
    _plan = _seed();
  }

  static const _storageKey = PrivacyStoreManifest.safetyPlanKey;
  late SafetyPlan _plan;
  final Uuid _uuid = const Uuid();
  Future<void>? _initFuture;

  @override
  Future<SafetyPlan> getSafetyPlan() async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    return _plan;
  }

  @override
  Future<SafetyPlan> updateSafetyPlan(SafetyPlan plan) async {
    await _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 120));
    _plan = plan.copyWith(updatedAt: DateTime.now());
    await _persist();
    return _plan;
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadFromStorage();
    return _initFuture!;
  }

  Future<void> _loadFromStorage() async {
    final data = await LocalJsonStore.readMap(_storageKey);
    if (data == null) {
      return;
    }

    _plan = SafetyPlan(
      warningSigns: (data['warningSigns'] as List?)?.whereType<String>().toList(growable: false) ?? const <String>[],
      selfActions: (data['selfActions'] as List?)?.whereType<String>().toList(growable: false) ?? const <String>[],
      safePlaces: (data['safePlaces'] as List?)?.whereType<String>().toList(growable: false) ?? const <String>[],
      contacts: ((data['contacts'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) {
            final json = item.cast<String, dynamic>();
            return SafetyContact(
              id: (json['id'] as String?) ?? _uuid.v4(),
              name: (json['name'] as String?) ?? '',
              relationship: (json['relationship'] as String?) ?? '',
              phone: (json['phone'] as String?) ?? '',
              quickMessage: (json['quickMessage'] as String?) ?? '',
            );
          })
          .toList(growable: false),
      professionals: ((data['professionals'] as List?) ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) {
            final json = item.cast<String, dynamic>();
            return SafetyProfessional(
              id: (json['id'] as String?) ?? _uuid.v4(),
              name: (json['name'] as String?) ?? '',
              role: (json['role'] as String?) ?? '',
              phone: (json['phone'] as String?) ?? '',
            );
          })
          .toList(growable: false),
      reasonsToStay: (data['reasonsToStay'] as List?)?.whereType<String>().toList(growable: false) ?? const <String>[],
      crisisMode: (data['crisisMode'] as bool?) ?? false,
      updatedAt: DateTime.tryParse((data['updatedAt'] as String?) ?? '') ?? DateTime.now(),
    );
  }

  Future<void> _persist() async {
    await LocalJsonStore.writeMap(_storageKey, {
      'warningSigns': _plan.warningSigns,
      'selfActions': _plan.selfActions,
      'safePlaces': _plan.safePlaces,
      'contacts': _plan.contacts
          .map((contact) => {
                'id': contact.id,
                'name': contact.name,
                'relationship': contact.relationship,
                'phone': contact.phone,
                'quickMessage': contact.quickMessage,
              })
          .toList(growable: false),
      'professionals': _plan.professionals
          .map((professional) => {
                'id': professional.id,
                'name': professional.name,
                'role': professional.role,
                'phone': professional.phone,
              })
          .toList(growable: false),
      'reasonsToStay': _plan.reasonsToStay,
      'crisisMode': _plan.crisisMode,
      'updatedAt': _plan.updatedAt.toIso8601String(),
    });
  }

  SafetyPlan _seed() {
    return SafetyPlan(
      warningSigns: const [
        'Empiezo a aislarme y no quiero contestar mensajes.',
        'No puedo concentrarme y siento todo demasiado intenso.',
      ],
      selfActions: const [
        'Respirar 4-6 durante 2 minutos.',
        'Caminar 10 minutos en un lugar tranquilo.',
        'Escuchar mi playlist de calma.',
        'Escribir lo que siento sin juzgarme.',
      ],
      safePlaces: const [
        'Mi habitación con luz cálida.',
        'La sala de mi hermana.',
      ],
      contacts: [
        SafetyContact(
          id: _uuid.v4(),
          name: 'Sofía',
          relationship: 'Hermana',
          phone: '+34 600 123 001',
          quickMessage:
              '¿Puedes acompañarme un momento por teléfono?',
        ),
        SafetyContact(
          id: _uuid.v4(),
          name: 'Dani',
          relationship: 'Amigo',
          phone: '+34 600 123 002',
          quickMessage: 'Me ayudaría hablar cinco minutos contigo.',
        ),
      ],
      professionals: [
        SafetyProfessional(
          id: _uuid.v4(),
          name: 'Dra. Elena Ruiz',
          role: 'Psicóloga',
          phone: '+34 900 456 100',
        ),
      ],
      reasonsToStay: const [
        'Mi perro me espera cada mañana.',
        'Hay personas que me quieren incluso cuando no lo siento.',
        'Ya he pasado momentos difíciles antes y sigo aquí.',
      ],
      crisisMode: false,
      updatedAt: DateTime.now(),
    );
  }
}
