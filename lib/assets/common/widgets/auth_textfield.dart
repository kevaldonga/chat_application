import 'package:flutter/material.dart';

class TextfieldAuth extends StatefulWidget {
  final TextEditingController controller;
  final String? autofill;
  final TextInputType? keyboardtype;
  final String? hintText, errorText;
  final Color bordercolor;
  const TextfieldAuth(
      {super.key,
      required this.controller,
      this.autofill,
      required this.bordercolor,
      this.keyboardtype,
      this.hintText,
      this.errorText});

  @override
  State<TextfieldAuth> createState() => _TextfieldAuthState();
}

class _TextfieldAuthState extends State<TextfieldAuth> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: true,
      autocorrect: false,
      autofillHints: [
        
      ],
      obscureText: widget.autofill == AutofillHints.password,
      maxLines: 1,
      keyboardType: widget.keyboardtype,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderSide: BorderSide(
          color: widget.bordercolor,
          width: 1,
        )),
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: widget.hintText,
        errorText: widget.errorText,
      ),
    );
  }
}
