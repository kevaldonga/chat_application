import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

class Picker {
  final _channel = const MethodChannel("flutter.io/picker");

  void Function(File? file) onResult;

  Picker({
    required this.onResult,
  });

  void pickfile() async {
    String path =
        await _channel.invokeMethod("filepicker", {"multiple": false});
    log("file picked $path");
    onResult(File(path));
  }

  void pickimage() async {
    var path = await _channel.invokeMethod("imagepicker", {"multiple": false});
    onResult(File(path));
  }
}
