import 'package:flutter/material.dart';

import '../../core/design/design_system.dart';

/// Styled text field with the OASIS design system.
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? errorText;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.errorText,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OasisTextField(
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      onSuffixTap: onSuffixTap,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
    );
  }
}
