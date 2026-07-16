import 'package:flutter/material.dart';
import '../../core/design/design_system.dart';

/// Specialized search field.
/// Pill shape for immediate visual differentiation.
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchField({
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OasisSearchField(
      controller: controller,
      hint: hint ?? 'Search...',
      onChanged: onChanged,
      onClear: onClear,
    );
  }
}
