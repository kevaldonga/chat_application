import 'package:chatty/global/variables/colors.dart';
import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final int? maxLength;
  final TextInputType keyboardType;
  final Function(String value) onChanged;

  const PrimaryTextField({
    super.key,
    this.controller,
    this.maxLength,
    required this.label,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: MyColors.primarySwatch,
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        enableSuggestions: true,
        autocorrect: false,
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: MyColors.primarySwatch, width: 1),
          ),
        ),
      ),
    );
  }
}
