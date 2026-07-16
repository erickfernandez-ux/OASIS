/// Base class for all domain entities.
/// Provides a common contract for identity across the domain.
/// All entities must have a unique identifier.
abstract class Entity {
  final String id;

  const Entity({required this.id});

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();
}
