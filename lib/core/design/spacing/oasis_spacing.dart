import 'package:flutter/material.dart';

@immutable
class OasisSpacing {
  const OasisSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 56;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg, vertical: lg);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets dialog = EdgeInsets.all(lg);
}
