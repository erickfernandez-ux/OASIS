import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable animation tokens.
@immutable
class AppAnimations extends ThemeExtension<AppAnimations> {
  final Duration fast;
  final Duration normal;
  final Duration slow;
  final Curve fastCurve;
  final Curve normalCurve;
  final Curve slowCurve;
  final Curve spring;

  const AppAnimations({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.fastCurve,
    required this.normalCurve,
    required this.slowCurve,
    required this.spring,
  });

  factory AppAnimations.defaultAnimations() {
    return const AppAnimations(
      fast: Duration(milliseconds: 150),
      normal: Duration(milliseconds: 250),
      slow: Duration(milliseconds: 350),
      fastCurve: Curves.easeInOut,
      normalCurve: Curves.fastOutSlowIn,
      slowCurve: Curves.decelerate,
      spring: Curves.elasticOut,
    );
  }

  @override
  AppAnimations copyWith({
    Duration? fast,
    Duration? normal,
    Duration? slow,
    Curve? fastCurve,
    Curve? normalCurve,
    Curve? slowCurve,
    Curve? spring,
  }) {
    return AppAnimations(
      fast: fast ?? this.fast,
      normal: normal ?? this.normal,
      slow: slow ?? this.slow,
      fastCurve: fastCurve ?? this.fastCurve,
      normalCurve: normalCurve ?? this.normalCurve,
      slowCurve: slowCurve ?? this.slowCurve,
      spring: spring ?? this.spring,
    );
  }

  @override
  AppAnimations lerp(ThemeExtension<AppAnimations>? other, double t) {
    if (other is! AppAnimations) return this;
    return AppAnimations(
      fast: _lerpDuration(fast, other.fast, t),
      normal: _lerpDuration(normal, other.normal, t),
      slow: _lerpDuration(slow, other.slow, t),
      fastCurve: t < 0.5 ? fastCurve : other.fastCurve,
      normalCurve: t < 0.5 ? normalCurve : other.normalCurve,
      slowCurve: t < 0.5 ? slowCurve : other.slowCurve,
      spring: t < 0.5 ? spring : other.spring,
    );
  }

  static Duration _lerpDuration(Duration a, Duration b, double t) {
    return Duration(
      milliseconds: lerpDouble(
        a.inMilliseconds.toDouble(),
        b.inMilliseconds.toDouble(),
        t,
      )!.round(),
    );
  }
}
