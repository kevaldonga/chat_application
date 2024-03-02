import 'dart:developer';
import 'dart:io';

import 'package:chatty/utils/profile.dart';
import 'package:flutter/services.dart';

class Intent {
  static const _channel = MethodChannel("flutter.io/intent");

  static void call(String phoneno) {
    log("calling $phoneno");
    _channel.invokeMethod("call", {"call": phoneno});
  }

  static void openfile(File file) async {
    try {
      log("opening file $file");
      _channel.invokeMethod("openfile", {
        "path": file.path,
      });
    } on Exception catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
    }
  }

  static void addcontact(Profile profile) {
    log("adding contact $profile");
    _channel.invokeMethod("addcontact", profile.toMap());
  }
}
