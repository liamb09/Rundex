import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  const InputBox({
    super.key,
    required this.labelText,
    required this.value,
    required this.setter,
    required this.validator,
    this.maxLines,
    this.keyboardType,
  });

  final String labelText;
  final String value;
  final void Function(String value) setter;
  final String? Function (String value) validator;
  final int? maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: labelText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      keyboardType: keyboardType,
      initialValue: value,
      onSaved:  (newValue) => setter("$newValue"),
      validator: (value) => validator(value!),
      maxLines: maxLines,
    );
  }
}