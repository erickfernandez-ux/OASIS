import '../entities/safety_plan.dart';

abstract class SafetyPlanRepository {
  Future<SafetyPlan> getSafetyPlan();
  Future<SafetyPlan> updateSafetyPlan(SafetyPlan plan);
}
