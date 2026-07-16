import 'package:flutter/material.dart';

@immutable
class MotionSpec {
  const MotionSpec._();

  static const Duration fadeIn = Duration(milliseconds: 820);
  static const Duration page = Duration(milliseconds: 560);
  static const Duration pageReverse = Duration(milliseconds: 500);
  static const Duration moduleNavigation = Duration(milliseconds: 560);
  static const Duration backgroundCrossfade = Duration(milliseconds: 600);
  static const Duration ambientShift = Duration(milliseconds: 800);
  static const Duration selectionFade = Duration(milliseconds: 250);
  static const Duration breathing = Duration(milliseconds: 1400);
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration stagger = Duration(milliseconds: 50);
  static const Duration hover = Duration(milliseconds: 150);
  static const Duration longPress = Duration(milliseconds: 180);
  static const Duration onboardingStep = Duration(milliseconds: 280);
  static const Duration splashFade = Duration(milliseconds: 420);
  static const Duration splashSwitch = Duration(milliseconds: 320);
  static const Duration splashHold = Duration(milliseconds: 980);
  static const Duration breathingCycle = Duration(seconds: 8);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;

  static const double swipeCommitDistancePx = 36.0;
  static const double swipeCommitVelocityPxPerSecond = 500.0;

  static const double beginScale = 0.98;
  static const double pageScale = 0.992;
  static const double hoverScale = 1.004;
  static const double pressedScale = 0.98;
  static const double hoverLiftPx = 2.0;
  static const double blurBeginning = 6;
}
