import 'package:flutter/material.dart';

void unfocus(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}
