import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/local_json_store.dart';
import '../../../../core/di/usecase_providers.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/enums/mood_type.dart';

class MedicationLogEntry {
  final String medicationId;
  final String medicationName;
  final DateTime takenAt;

  const MedicationLogEntry({
    required this.medicationId,
    required this.medicationName,
    required this.takenAt,
  });
}

class WellbeingController extends AsyncNotifier<WellbeingState> {
  static const _storageKey = 'wellbeing_state';
  int _dailyGoalMl = 2000;
  int _completedPomodoroSessions = 0;
  bool _pomodoroRunning = false;
  final List<WaterEntry> _waterEntries = [];
  final List<MedicationLogEntry> _medicationLog = [];
  Future<void>? _initFuture;

  @override
  Future<WellbeingState> build() async {
    await _ensureInitialized();
    return _fetchState();
  }

  Future<WellbeingState> _fetchState() async {
    final getMoodHistory = ref.read(getMoodHistoryProvider);
    final getAllMedications = ref.read(getMedicationsProvider);
    final moodEntries = await getMoodHistory();
    final medications = await getAllMedications();

    final todayWaterMl =
        ref.read(getDailyWaterProvider)(_waterEntries, DateTime.now());

    return WellbeingState(
      moodEntries: moodEntries,
      waterEntries: List.unmodifiable(_waterEntries),
      todayWaterMl: todayWaterMl,
      medications: medications,
      dailyGoalMl: _dailyGoalMl,
      medicationLog: List.unmodifiable(_medicationLog),
      completedPomodoroSessions: _completedPomodoroSessions,
      pomodoroRunning: _pomodoroRunning,
    );
  }

  Future<void> createMoodEntry({
    required MoodType mood,
    int energyLevel = 5,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final createMoodEntry = ref.read(createMoodEntryProvider);
      await createMoodEntry(mood: mood, note: note);
      return _fetchState();
    });
  }

  Future<void> registerWater(int amountMl) async {
    await _ensureInitialized();
    final current = state.value ?? await _fetchState();
    final registerWater = ref.read(registerWaterIntakeProvider);
    final entry = registerWater(amountMl: amountMl);
    _waterEntries.add(entry);
    final getDailyWater = ref.read(getDailyWaterProvider);
    final todayTotal = getDailyWater(_waterEntries, DateTime.now());

    state = AsyncData(
      current.copyWith(
        waterEntries: List.unmodifiable(_waterEntries),
        todayWaterMl: todayTotal,
      ),
    );
    await _persistLocalState();
  }

  Future<void> markMedicationTaken(String medicationId) async {
    await _ensureInitialized();
    final current = state.value ?? await _fetchState();
    final medication = current.medications.firstWhere((item) => item.id == medicationId);
    _medicationLog.add(
      MedicationLogEntry(
        medicationId: medication.id,
        medicationName: medication.name,
        takenAt: DateTime.now(),
      ),
    );

    state = AsyncData(
      current.copyWith(
        medicationLog: List.unmodifiable(_medicationLog),
      ),
    );
    await _persistLocalState();
  }

  Future<void> updateDailyGoal(int goalMl) async {
    await _ensureInitialized();
    _dailyGoalMl = goalMl;
    await _persistLocalState();
    state = await AsyncValue.guard(_fetchState);
  }

  Future<void> startPomodoro() async {
    await _ensureInitialized();
    _pomodoroRunning = true;
    await _persistLocalState();
    state = await AsyncValue.guard(_fetchState);
  }

  Future<void> pausePomodoro() async {
    await _ensureInitialized();
    _pomodoroRunning = false;
    await _persistLocalState();
    state = await AsyncValue.guard(_fetchState);
  }

  Future<void> finishPomodoro() async {
    await _ensureInitialized();
    _pomodoroRunning = false;
    _completedPomodoroSessions += 1;
    await _persistLocalState();
    state = await AsyncValue.guard(_fetchState);
  }

  Future<void> refresh() async {
    await _ensureInitialized();
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchState);
  }

  Future<void> _ensureInitialized() {
    _initFuture ??= _loadLocalState();
    return _initFuture!;
  }

  Future<void> _loadLocalState() async {
    final data = await LocalJsonStore.readMap(_storageKey);
    if (data == null) {
      return;
    }

    _dailyGoalMl = (data['dailyGoalMl'] as int?) ?? 2000;
    _completedPomodoroSessions =
        (data['completedPomodoroSessions'] as int?) ?? 0;
    _pomodoroRunning = (data['pomodoroRunning'] as bool?) ?? false;

    final waterRaw = (data['waterEntries'] as List?) ?? const <dynamic>[];
    _waterEntries
      ..clear()
      ..addAll(
        waterRaw.whereType<Map>().map((item) {
          final json = item.cast<String, dynamic>();
          return WaterEntry(
            id: (json['id'] as String?) ?? DateTime.now().toIso8601String(),
            amountMl: (json['amountMl'] as int?) ?? 0,
            dateTime: DateTime.tryParse((json['dateTime'] as String?) ?? '') ??
                DateTime.now(),
          );
        }),
      );

    final logRaw = (data['medicationLog'] as List?) ?? const <dynamic>[];
    _medicationLog
      ..clear()
      ..addAll(
        logRaw.whereType<Map>().map((item) {
          final json = item.cast<String, dynamic>();
          return MedicationLogEntry(
            medicationId: (json['medicationId'] as String?) ?? '',
            medicationName: (json['medicationName'] as String?) ?? '',
            takenAt: DateTime.tryParse((json['takenAt'] as String?) ?? '') ??
                DateTime.now(),
          );
        }),
      );
  }

  Future<void> _persistLocalState() async {
    await LocalJsonStore.writeMap(_storageKey, {
      'dailyGoalMl': _dailyGoalMl,
      'completedPomodoroSessions': _completedPomodoroSessions,
      'pomodoroRunning': _pomodoroRunning,
      'waterEntries': _waterEntries
          .map((entry) => {
                'id': entry.id,
                'amountMl': entry.amountMl,
                'dateTime': entry.dateTime.toIso8601String(),
              })
          .toList(growable: false),
      'medicationLog': _medicationLog
          .map((entry) => {
                'medicationId': entry.medicationId,
                'medicationName': entry.medicationName,
                'takenAt': entry.takenAt.toIso8601String(),
              })
          .toList(growable: false),
    });
  }
}

class WellbeingState {
  final List<MoodEntry> moodEntries;
  final List<WaterEntry> waterEntries;
  final int todayWaterMl;
  final List<Medication> medications;
  final int dailyGoalMl;
  final List<MedicationLogEntry> medicationLog;
  final int completedPomodoroSessions;
  final bool pomodoroRunning;

  const WellbeingState({
    required this.moodEntries,
    required this.waterEntries,
    required this.todayWaterMl,
    required this.medications,
    required this.dailyGoalMl,
    required this.medicationLog,
    required this.completedPomodoroSessions,
    required this.pomodoroRunning,
  });

  WellbeingState copyWith({
    List<MoodEntry>? moodEntries,
    List<WaterEntry>? waterEntries,
    int? todayWaterMl,
    List<Medication>? medications,
    int? dailyGoalMl,
    List<MedicationLogEntry>? medicationLog,
    int? completedPomodoroSessions,
    bool? pomodoroRunning,
  }) {
    return WellbeingState(
      moodEntries: moodEntries ?? this.moodEntries,
      waterEntries: waterEntries ?? this.waterEntries,
      todayWaterMl: todayWaterMl ?? this.todayWaterMl,
      medications: medications ?? this.medications,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      medicationLog: medicationLog ?? this.medicationLog,
      completedPomodoroSessions: completedPomodoroSessions ?? this.completedPomodoroSessions,
      pomodoroRunning: pomodoroRunning ?? this.pomodoroRunning,
    );
  }

  List<MedicationLogEntry> get todayMedicationLog => medicationLog;
}

final wellbeingControllerProvider = AsyncNotifierProvider<WellbeingController, WellbeingState>(() {
  return WellbeingController();
});
