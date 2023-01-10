import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class Intent {
  static const _channel = MethodChannel("flutter.io/intent");

  static void call(String phoneno) {
    log("calling $phoneno");
    _channel.invokeMethod("call", {"call": phoneno});
  }

  static void openfile(File file) async {
    log("opening file $file");
    _channel.invokeMethod("openfile", {
      "path": file.path,
    });
  }
}
