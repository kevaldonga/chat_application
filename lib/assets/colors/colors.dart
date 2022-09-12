import 'package:flutter/material.dart';

class MyColors {
  static const Color scaffoldbackground = Color.fromRGBO(237, 228, 255, 1);
  static const Color primarySwatch = Color.fromRGBO(76, 74, 206, 1);
  static const Color seconadaryswatch = Color.fromRGBO(124, 38, 216,1);
  static const Color textprimary = Color.fromRGBO(80, 80, 80, 1);
  static const Color textsecondary = Color.fromRGBO(89, 89, 89, 1);
  static const Color textFieldbackground = Color.fromARGB(144, 194, 200, 253);
  static const Color textfieldborder2 = Color.fromRGBO(69, 80, 206,1);
}

class MyGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color.fromRGBO(75, 56, 247, 1),
      Color.fromRGBO(159, 207, 255, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient secondarygradient = LinearGradient(
    colors: [
      Color.fromRGBO(5, 129, 255, 1),
      Color.fromRGBO(239, 190, 190, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient maingradient = LinearGradient(
    colors: [
      Color.fromRGBO(174, 3, 226, 1),
      Color.fromRGBO(8, 100, 223, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const LinearGradient maingradientvertical = LinearGradient(
    colors: [
      Color.fromRGBO(8, 100, 223, 1),
      Color.fromRGBO(174, 3, 226, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
