import 'package:flutter/material.dart';

import '../components/oasis_icons.dart';
import '../radius/oasis_radius.dart';
import '../spacing/oasis_spacing.dart';

class OasisTextField extends StatelessWidget {
  const OasisTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.textAlignVertical,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      textAlignVertical: textAlignVertical,
      onChanged: onChanged,
      style: textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surface,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon == null
            ? null
            : GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, size: 20),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: OasisSpacing.md, vertical: OasisSpacing.sm),
            border: const OutlineInputBorder(borderRadius: OasisRadius.medium),
            enabledBorder:
                const OutlineInputBorder(borderRadius: OasisRadius.medium),
            focusedBorder:
                const OutlineInputBorder(borderRadius: OasisRadius.medium),
      ),
    );
  }
}

class OasisSearchField extends StatefulWidget {
  const OasisSearchField({
    super.key,
    this.controller,
    this.hint = 'Buscar',
    this.onChanged,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<OasisSearchField> createState() => _OasisSearchFieldState();
}

class _OasisSearchFieldState extends State<OasisSearchField> {
  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant OasisSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_refresh);
      widget.controller?.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OasisTextField(
      controller: widget.controller,
      hint: widget.hint,
      prefixIcon: OasisIcons.search,
      suffixIcon: widget.controller != null && widget.controller!.text.isNotEmpty ? OasisIcons.close : null,
      onSuffixTap: () {
        widget.controller?.clear();
        widget.onClear?.call();
      },
      onChanged: widget.onChanged,
    );
  }
}

class OasisMultilineField extends StatelessWidget {
  const OasisMultilineField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.onChanged,
    this.minLines = 3,
    this.maxLines,
    this.expands = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int? maxLines;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    return OasisTextField(
      controller: controller,
      label: label,
      hint: hint,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines ?? minLines,
      expands: expands,
      textAlignVertical: expands ? TextAlignVertical.top : null,
    );
  }
}

class OasisDropdown<T> extends StatelessWidget {
  const OasisDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class OasisSwitch extends StatelessWidget {
  const OasisSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(value: value, onChanged: onChanged);
  }
}

class OasisSlider extends StatelessWidget {
  const OasisSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return Slider(value: value, onChanged: onChanged, min: min, max: max);
  }
}

class OasisSegmentedSelector<T> extends StatelessWidget {
  const OasisSegmentedSelector({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  final T value;
  final List<({T value, String label})> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: [
        for (final segment in segments)
          ButtonSegment<T>(
            value: segment.value,
            label: Text(segment.label),
          ),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
    );
  }
}
