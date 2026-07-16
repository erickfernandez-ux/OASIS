import 'package:flutter/material.dart';

@immutable
class OasisRadius {
  const OasisRadius._();

  static const BorderRadius small = BorderRadius.all(Radius.circular(10));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(14));
  static const BorderRadius large = BorderRadius.all(Radius.circular(20));
  static const BorderRadius card = BorderRadius.all(Radius.circular(26));
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(28));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(30));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
  static const BorderRadius fab = BorderRadius.all(Radius.circular(18));
}
