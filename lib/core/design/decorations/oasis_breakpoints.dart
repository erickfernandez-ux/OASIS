import 'package:flutter/material.dart';

@immutable
class OasisBreakpoints {
  const OasisBreakpoints._();

  static const double phone = 0;
  static const double smallTablet = 600;
  static const double largeTablet = 900;
  static const double desktop = 1200;

  static OasisBreakpointBand bandForWidth(double width) {
    if (width >= desktop) return OasisBreakpointBand.desktop;
    if (width >= largeTablet) return OasisBreakpointBand.largeTablet;
    if (width >= smallTablet) return OasisBreakpointBand.smallTablet;
    return OasisBreakpointBand.phone;
  }
}

enum OasisBreakpointBand { phone, smallTablet, largeTablet, desktop }
