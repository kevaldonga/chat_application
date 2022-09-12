import 'package:chatty/assets/common/widgets/alertdialog_action_button.dart';
import 'package:flutter/material.dart';

Future<bool> showdialog(BuildContext context, String title, String contents,
    List<Widget> actions) async {
  await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(contents),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: actions,
        );
      });
  return true;
}

Future<void> showbasicdialog(BuildContext context, String title, contents) async{
  await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(contents),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            alertdialogactionbutton("ok", () {
              Navigator.of(context).pop(true);
            }),
          ],
        );
      });
}
