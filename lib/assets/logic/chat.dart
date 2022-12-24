import 'dart:io';

import 'package:file_picker/file_picker.dart';

class Chat {
  FileInfo? fileinfo;
  final String _id;
  final DateTime _time;
  final String? _text;
  final String _sentFrom;
  bool _read = false;

  String get id => _id;

  DateTime get time => _time;

  String? get text => _text;

  String get sentFrom => _sentFrom;

  bool get isread => _read;

  set setread(bool read) => _read = read;

  Chat({
    this.fileinfo,
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
        fileinfo = chat["url"] != "null" && chat["url"] != null
            ? FileInfo(
                fileexist: chat["fileexist"] ?? false,
                filename: chat["filename"] == "null" ? null : chat["filename"],
                url: chat["url"],
                path: chat["path"],
              )
            : null;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      "id": _id,
      "time": _time.toString(),
      "sentfrom": _sentFrom,
      "read": _read,
      if (text != "") "text": _text,
    };
    if (fileinfo == null) return data;
    if (fileinfo!.path != null && fileinfo!.path != "null") {
      data["path"] = fileinfo!.path;
    }
    if (fileinfo!.fileexist) data["fileexist"] = fileinfo!.fileexist;
    if (fileinfo?.filename != null && fileinfo?.filename != "null") {
      data["filename"] = fileinfo?.filename;
    }
    if (fileinfo?.url != null && fileinfo?.url != "null") {
      data["url"] = fileinfo?.url;
    }
    return data;
  }

  @override
  String toString() {
    return "id = $_id || filename = ${fileinfo?.filename} || fileexist = ${fileinfo?.fileexist} || url = ${fileinfo?.url} || time = $time || text = $text || sentfrom = $sentFrom || read = $_read";
  }
}

class FileInfo {
  bool fileexist;
  File? file;
  String? filename;
  String? url;
  FileType? type;
  String? path;

  FileInfo({
    this.file,
    this.filename,
    this.type,
    this.url,
    this.fileexist = false,
    this.path,
  });

  @override
  String toString() {
    return "filexist = $fileexist || file = $file || filename = $filename || url = $url || type = $type || path = $path";
  }
}
