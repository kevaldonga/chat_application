import 'package:chatty/global/variables/colors.dart';
import 'package:chatty/global/variables/validate.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class TextfieldAuth extends StatefulWidget {
  final TextEditingController controller;
  final String? autofill;
  final bool? autofocus;
  final TextInputType? keyboardtype;
  final String? hintText;
  final String errorText;
  final Gradient bordergradient;
  final int? maxlength;
  const TextfieldAuth(
      {super.key,
      this.autofocus,
      required this.controller,
      required this.bordergradient,
      this.maxlength,
      this.autofill,
      this.keyboardtype,
      this.hintText,
      required this.errorText});

  @override
  State<TextfieldAuth> createState() => _TextfieldAuthState();
}

class _TextfieldAuthState extends State<TextfieldAuth> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: MyColors.textFieldbackground,
        border: GradientBoxBorder(gradient: widget.bordergradient, width: 1.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          controller: widget.controller,
          autofocus: widget.autofocus ?? false,
          autocorrect: false,
          maxLength: widget.maxlength,
          autofillHints: widget.autofill == null ? [] : [widget.autofill!],
          obscureText: widget.autofill == AutofillHints.password,
          maxLines: 1,
          cursorHeight: 24,
          keyboardType: widget.keyboardtype,
          onChanged: widget.autofill == AutofillHints.password ||
                  widget.autofill == AutofillHints.telephoneNumber
              ? (text) {
                  setState(() {});
                }
              : null,
          style: const TextStyle(
            fontSize: 19,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding:
                const EdgeInsets.only(top: 18, bottom: 0, left: 5, right: 25),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            hintStyle: const TextStyle(color: MyColors.textprimary),
            hintText: widget.hintText,
            errorText: widget.errorText,
            counterText: widget.autofill == AutofillHints.password
                ? widget.controller.text.length.toString()
                : widget.autofill == AutofillHints.telephoneNumber
                    ? "${widget.controller.text.length}/10"
                    : null,
          ),
        ),
      ),
    );
  }

  String validate() {
    switch (widget.autofill) {
      case AutofillHints.email:
        if (!EmailValidator.validate(widget.controller.text)) {
          return "invalid format";
        }
        break;
      case AutofillHints.password:
        if (widget.controller.text.length < 8) {
          return "too short";
        }
        break;
      case AutofillHints.telephoneNumber:
        if (widget.controller.text.length < 10) {
          return "too short";
        }
        break;
    }
    return "";
  }
}

String validate(Validate v, String text) {
  switch (v) {
    case Validate.email:
      if (!EmailValidator.validate(text)) {
        return "invalid email";
      }
      break;
    case Validate.password:
      if (text.length < 8) {
        return "too short";
      }
      break;
    case Validate.phone:
      if (text.length < 10) {
        return "too short";
      }
      break;
    case Validate.name:
      if (text.isEmpty) {
        return "empty field";
      }
      break;
  }
  return "";
}
