import '../entities/safety_plan.dart';
import '../repositories/safety_plan_repository.dart';

class SetCrisisMode {
  const SetCrisisMode(this._repository);

  final SafetyPlanRepository _repository;

  Future<SafetyPlan> call({
    required SafetyPlan current,
    required bool enabled,
  }) {
    return _repository.updateSafetyPlan(
      current.copyWith(
        crisisMode: enabled,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
