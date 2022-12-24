import 'package:flutter/services.dart';

class Toast {
  static const _platform = MethodChannel('toast.flutter.io/toast');

  Toast(String message) {
    _show(message);
  }

  void _show(String message) {
    _platform.invokeMethod("show", {"message": message});
  }
}
