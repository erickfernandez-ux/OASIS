import 'package:flutter/material.dart';

/// Global snackbar style used by the design system.
class AppSnackbar {
  const AppSnackbar._();

  static SnackBar build({
    required String message,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    Color? backgroundColor,
  }) {
    return SnackBar(
      behavior: behavior,
      backgroundColor: backgroundColor,
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
