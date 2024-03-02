import 'package:flutter/material.dart';

class AlertDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  const AlertDialogButton({
    super.key,
    required this.text,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
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
}
