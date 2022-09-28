import 'package:flutter/material.dart';

PopupMenuItem popupMenuItem(
    {required value, required Widget child, required double height}) {
  return PopupMenuItem(
    value: value,
    height: height,
    enabled: true,
    padding: const EdgeInsets.only(left: 20,bottom: 10,top: 10,right: 20),
    child: child,
  );
}
