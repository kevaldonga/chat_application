import 'package:chatty/assets/colors/colors.dart';
import 'package:flutter/material.dart';

class TextFieldmain extends StatefulWidget implements PreferredSizeWidget{
  final TextEditingController controller;
  final String? hintText;
  final Widget? leading,ending;

  final EdgeInsetsGeometry contentPadding;
  const TextFieldmain({
    this.leading,
    this.ending,
    super.key,
    required this.contentPadding,
    required this.controller,
    this.hintText,
  });

  @override
  State<TextFieldmain> createState() => _TextFieldmainState();
  
  @override
  Size get preferredSize => const Size.fromHeight(30);
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
          prefixIconConstraints: BoxConstraints.tight(const Size(40,20)),
          suffixIconConstraints: BoxConstraints.tight(const Size(60,35)),
          prefixIcon: widget.leading,
          suffixIcon: widget.ending,
          contentPadding: widget.contentPadding,
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
    );
  }
}
