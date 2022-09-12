import 'package:chatty/assets/colors/colors.dart';
import 'package:flutter/material.dart';

class TextFieldmain extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  const TextFieldmain(
      {super.key,
      required this.controller,
      this.hintText,});

  @override
  State<TextFieldmain> createState() => _TextFieldmainState();
}

class _TextFieldmainState extends State<TextFieldmain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: MyColors.textFieldbackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          controller: widget.controller,
          autocorrect: false,
          cursorHeight: 24,
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
            hintStyle: const TextStyle(color: MyColors.textsecondary),
            hintText: widget.hintText,
          ),
        ),
      ),
    );
  }
}