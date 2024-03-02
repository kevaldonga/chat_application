import 'package:chatty/global/variables/colors.dart';
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
        height: 45,
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          gradient: MyGradients.primaryGradient,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
