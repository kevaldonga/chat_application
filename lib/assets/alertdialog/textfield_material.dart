import 'package:chatty/assets/colors/colors.dart';
import 'package:flutter/material.dart';

Widget textfieldmaterial({
  required String label,
  required void Function(String) onchanged,
  required TextInputType keyboardtype,
  TextEditingController? controller,
  int? maxlength,
}) {
  return Theme(
    data: ThemeData(
      primaryColor: MyColors.primarySwatch,
    ),
    child: TextField(
      controller: controller,
      autofocus: true,
      enableSuggestions: true,
      autocorrect: false,
      maxLength: maxlength,
      keyboardType: keyboardtype,
      onChanged: onchanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: MyColors.primarySwatch, width: 1),
        ),
      ),
    ),
  );
}
