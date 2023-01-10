import 'dart:developer';

import 'package:flutter/services.dart';

class PathProvider {
  static const _method = MethodChannel("flutter.io/path");

  static Future<String?> documentDirectory() async {
    String? path = await _method.invokeMethod("document_directory");
    log("got document path $path");
    return path;
  }

  static Future<String?> mediaDirectory() async {
    String? path = await _method.invokeMethod("media_directory");
    log("got media path $path");
    return path;
  }

  static Future<String?> tempDirectory() async {
    String? path = await _method.invokeMethod("temporary_directory");
    log("got temporary path $path");
    return path;
  }
}
