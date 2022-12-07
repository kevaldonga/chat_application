import 'package:chatty/assets/colors/colors.dart';
import 'package:flutter/material.dart';

Widget notificationbubble(int count, Size size) {
  return Container(
    width: size.width,
    height: size.height,
    constraints: BoxConstraints.loose(size),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(9),
      gradient: MyGradients.secondarygradient,
    ),
    child: Center(
        child: Text(
      count >= 100 ? "99+" : count.toString(),
      softWrap: false,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    )),
  );
}
