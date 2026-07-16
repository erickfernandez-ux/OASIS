import 'package:uuid/uuid.dart';

import '../../domain/entities/habit.dart';
import '../../domain/enums/habit_frequency.dart';
import '../../domain/repositories/habit_repository.dart';

/// In-memory implementation of [HabitRepository].
class MockHabitRepository implements HabitRepository {
  final List<Habit> _habits = [];
  final _uuid = const Uuid();

  MockHabitRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    _habits.addAll([
      Habit(
        id: _uuid.v4(),
        title: 'Meditar 10 minutos',
        frequency: HabitFrequency.daily,
        goal: '10 minutos diarios',
        color: '#A8B5A0',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Beber 2L de agua',
        frequency: HabitFrequency.daily,
        goal: '2 litros diarios',
        color: '#0288D1',
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      Habit(
        id: _uuid.v4(),
        title: 'Ejercicio',
        frequency: HabitFrequency.weekly,
        goal: '3 sesiones por semana',
        color: '#C07756',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ]);
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    await _simulateNetworkDelay();
    return List.unmodifiable(_habits);
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    await _simulateNetworkDelay();
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    await _simulateNetworkDelay();
    final created = habit.copyWith(id: habit.id.isEmpty ? _uuid.v4() : habit.id);
    _habits.add(created);
    return created;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await _simulateNetworkDelay();
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index == -1) throw Exception('Habit not found: ${habit.id}');
    _habits[index] = habit;
    return habit;
  }

  @override
  Future<bool> deleteHabit(String id) async {
    await _simulateNetworkDelay();
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return false;
    _habits.removeAt(index);
    return true;
  }

  @override
  Future<Habit> recordCompletion(String id, DateTime date) async {
    await _simulateNetworkDelay();
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) throw Exception('Habit not found: $id');
    return _habits[index];
  }

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
