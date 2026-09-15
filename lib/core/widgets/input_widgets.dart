import 'package:flutter/material.dart';
import 'package:leakuku/core/theme/app_colors.dart';

Widget numberField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool decimals = true,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimals),
    decoration: _inputDecoration(label: label, hint: hint),
  );
}

Widget textField({
  required TextEditingController controller,
  required String label,
  required String hint,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    decoration: _inputDecoration(label: label, hint: hint),
  );
}

InputDecoration _inputDecoration(
    {required String label, required String hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: AppColors.farmCream,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}
