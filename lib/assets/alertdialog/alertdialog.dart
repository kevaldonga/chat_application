import 'package:flutter/material.dart';

import 'alertdialog_action_button.dart';

Future<bool> showdialog(BuildContext context, Widget title, Widget contents,
    List<Widget> actions) async {
  return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              title: title,
              content: contents,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              actions: actions,
            );
          }) ??
      false;
}

Future<void> showbasicdialog(
    BuildContext context, String title, contents) async {
  await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
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
