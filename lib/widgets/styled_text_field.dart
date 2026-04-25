import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class StyledTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final int? maxLines;
  final TextInputType? keyboardType;

  const StyledTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.suffix,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}
