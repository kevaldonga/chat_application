import 'package:chatty/assets/colors/colors.dart';
import 'package:flutter/material.dart';

class ButtonAuth extends StatefulWidget {
  final String text;
  final VoidCallback onclick;
  const ButtonAuth({
    super.key,
    required this.text,
    required this.onclick,
  });

  @override
  State<ButtonAuth> createState() => _ButtonAuthState();
}

class _ButtonAuthState extends State<ButtonAuth> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onclick,
      child: Container(
        decoration: BoxDecoration(
          gradient: MyGradients.primaryGradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: const Color.fromARGB(255, 202, 197, 251),
            highlightColor: const Color.fromRGBO(159, 207, 255, 1),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Text(widget.text)),
            ),
          ),
        ),
      ),
    );
  }
}
