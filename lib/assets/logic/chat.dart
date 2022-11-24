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
  bool fileexist = false;
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
        fileexist = chat["fileexist"] ?? false,
        filename = chat["filename"] == "null" ? null : chat["filename"],
        url = chat["url"];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      "id": _id,
      "time": _time.toString(),
      "sentfrom": _sentFrom,
      "read": _read,
    };
    if (fileexist) data["fileexist"] = fileexist;
    if (text != "") data["text"] = _text;
    if (filename != null || filename != "null") data["filename"] = filename;
    if (url != null || url != "null") data["url"] = url;
    return data;
  }

  @override
  String toString() {
    return "id = $_id || filename = $filename || fileexist = $fileexist || url = $url || time = $time || text = $text || sentfrom = $sentFrom || read = $_read";
  }
}
