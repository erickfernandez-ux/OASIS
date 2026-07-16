import 'package:equatable/equatable.dart';

/// Base class for all Value Objects in the domain.
/// Value Objects are immutable, have no identity, and are compared by value.
abstract class ValueObject extends Equatable {
  const ValueObject();

  /// Validates the value object. Returns null if valid, or an error message.
  String? validate();

  /// Returns true if the value object is valid.
  bool get isValid => validate() == null;
}
