import 'package:chatty/global/variables/colors.dart';
import 'package:flutter/material.dart';

class TextFieldmain extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final VoidCallback? onchanged;
  final String? hintText;
  final bool scrollble;
  final Widget? leading, ending;

  final EdgeInsets? contentPadding;
  const TextFieldmain({
    this.leading,
    this.ending,
    super.key,
    bool? scrollble,
    required this.onchanged,
    this.contentPadding,
    required this.controller,
    this.hintText,
  }) : scrollble = scrollble ?? false;

  @override
  State<TextFieldmain> createState() => _TextFieldmainState();

  @override
  Size get preferredSize => const Size.fromHeight(30);
}

class _TextFieldmainState extends State<TextFieldmain> {
  @override
  void initState() {
    if (widget.onchanged != null) {
      widget.controller.addListener(widget.onchanged!);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.onchanged != null) {
      widget.controller.removeListener(widget.onchanged!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.textFieldbackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {},
          highlightColor: Colors.transparent,
          focusColor: const Color.fromARGB(255, 205, 209, 248),
          splashColor: const Color.fromARGB(255, 193, 199, 247),
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              controller: widget.controller,
              autocorrect: false,
              maxLines: widget.scrollble ? null : 1,
              style: const TextStyle(
                fontSize: 19,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixIconConstraints: BoxConstraints.tight(const Size(40, 20)),
                suffixIconConstraints: BoxConstraints.tight(const Size(60, 35)),
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
          ),
        ),
      ),
    );
  }
}
