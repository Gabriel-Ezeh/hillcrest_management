import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/constants/validators/field_validators.dart'; // Adjust path if needed

class DobPickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;

  const DobPickerField({
    super.key,
    required this.controller,
    this.label = 'Date of Birth',
    this.hint = 'YYYY-MM-DD',
    this.validator,
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          validator: validator ?? FieldValidators.validateDateOfBirth,
          keyboardType: TextInputType.datetime,
        ),
      ),
    );
  }
}