import 'package:flutter/material.dart';

alertdialogactionbutton(String text, VoidCallback callback) {
  return TextButton(
    onPressed: callback,
    style: ButtonStyle(
      shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    child: Text(text),
  );
}
