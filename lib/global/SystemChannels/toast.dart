import 'package:flutter/services.dart';

class Toast {
  static const _channel = MethodChannel('flutter.io/toast');

  Toast(String message) {
    _show(message);
  }

  void _show(String message) {
    _channel.invokeMethod("show", {"message": message});
  }
}
