import 'dart:io';

import 'package:flutter/services.dart';

class Intent {
  static const _channel = MethodChannel("flutter.io/intent");

  static void call(String phoneno) {
    _channel.invokeMethod("call", {"call": phoneno});
  }

  static void openfile(File file) {
    _channel.invokeMethod("openfile", {"path": file.path});
  }
}
