import 'dart:io';

import 'package:file_picker/file_picker.dart';

class Chat {
  final String _id;
  final DateTime _time;
  final String? _text;
  final String _sentFrom;
  String? filename;
  FileType? type;
  bool _read = false;
  File? file;
  String? url;

  String get id => _id;

  DateTime get time => _time;

  String? get text => _text;

  String get sentFrom => _sentFrom;

  bool get isread => _read;

  set setread(bool read) => _read = read;

  Chat({
    this.file,
    this.url,
    this.filename,
    this.type,
    required String id,
    required DateTime time,
    required String text,
    required String sentFrom,
  })  : _id = id,
        _time = time,
        _text = text,
        _read = false,
        _sentFrom = sentFrom;

  Chat.fromMap({required Map<String, dynamic> chat})
      : _id = chat["id"]!,
        _time = DateTime.parse(chat["time"]!),
        _text = chat["text"],
        _sentFrom = chat["sentfrom"]!,
        _read = chat["read"]!,
        filename = chat["filename"],
        url = chat["url"] == "null" ? null : chat["url"];

  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      if (filename != null || filename != "null") "filename": filename,
      if (url != null || url != "null") "url": url,
      "time": _time.toString(),
      if (text != "") "text": _text,
      "sentfrom": _sentFrom,
      "read": _read,
    };
  }

  @override
  String toString() {
    return "id = $_id || filename = $filename || url = $url || time = $time || text = $text || sentfrom = $sentFrom || read = $_read";
  }
}
