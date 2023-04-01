import 'dart:developer';

import 'package:flutter/services.dart';

class PathProvider {
  static const _method = MethodChannel("flutter.io/path");
  static String? _documentdir;
  static String? _mediadir;
  static String? _tempdir;

  static Future<String?> documentDirectory() async {
    if (_documentdir != null) {
      return _documentdir;
    }
    String? path = await _method.invokeMethod("document_directory");
    _documentdir = path;
    log("got document path $path");
    return path;
  }

  static Future<String?> mediaDirectory() async {
    if (_mediadir != null) {
      return _mediadir;
    }
    String? path = await _method.invokeMethod("media_directory");
    _mediadir = path;
    log("got media path $path");
    return path;
  }

  static Future<String?> tempDirectory() async {
    if (_tempdir != null) {
      return _tempdir;
    }
    String? path = await _method.invokeMethod("temporary_directory");
    _tempdir = path;
    log("got temporary path $path");
    return path;
  }
}
