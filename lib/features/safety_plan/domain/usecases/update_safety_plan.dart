import '../entities/safety_plan.dart';
import '../repositories/safety_plan_repository.dart';

class UpdateSafetyPlan {
  const UpdateSafetyPlan(this._repository);

  final SafetyPlanRepository _repository;

  Future<SafetyPlan> call(SafetyPlan plan) {
    return _repository.updateSafetyPlan(plan);
  }
}
