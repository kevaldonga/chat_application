import 'package:flutter/material.dart';

Widget buildcircle({required color, required double padding, Widget? child}) {
  return ClipOval(
    child: Container(
      color: color,
      padding: EdgeInsets.all(padding),
      child: child,
    ),
  );
}
