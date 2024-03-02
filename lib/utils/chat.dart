import 'dart:io';

import '../global/variables/enum_file_type.dart';

class Chat {
  FileInfo? fileinfo;
  final String _id;
  final DateTime _time;
  final String? _text;
  final String _sentFrom;
  Map<String, int> reactioncount = {}; // { "😊" : 23, "😂": 32 }
  Map<String, List<String>> reactions =
      {}; // { phoneno : ["😊","❤️"],phoneno : ["😂","👌"]}
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

  Chat.fromMap({required Map<dynamic, dynamic> chat})
      : _id = chat["id"]!,
        _time = DateTime.parse(chat["time"]!),
        _text = chat["text"],
        _sentFrom = chat["sentfrom"]!,
        _read = chat["read"]!,
        reactioncount = (chat["reactioncount"] ?? {}).cast<String, int>(),
        reactions = _convert(chat["reactions"] ?? {}),
        fileinfo = chat["url"] != "null" && chat["url"] != null
            ? FileInfo(
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
      if (text != "" && text != null) "text": _text,
    };
    if (reactioncount.isNotEmpty) {
      data["reactioncount"] = reactioncount;
      data["reactions"] = reactions;
    }
    if (fileinfo == null) return data;
    if (fileinfo!.path != null && fileinfo!.path != "null") {
      data["path"] = fileinfo!.path;
    }

    // dont need file exist varible stored casuse gonna calculate it at intialization
    if (fileinfo?.filename != null && fileinfo?.filename != "null") {
      data["filename"] = fileinfo?.filename;
    }
    if (fileinfo?.url != null && fileinfo?.url != "null") {
      data["url"] = fileinfo?.url;
    }
    return data;
  }

  static Map<String, List<String>> _convert(Map<dynamic, dynamic> data) {
    Map<String, List<String>> mydata = {};
    mydata = data.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as List).cast<String>(),
      ),
    );
    return mydata;
  }

  void sortReactionCount() {
    reactioncount = Map.fromEntries(
      reactioncount.entries.toList()
        ..sort(
          (e1, e2) => e2.value.compareTo(e1.value),
        ),
    );
  }

  @override
  String toString() {
    return "id = $_id || fileinfo = $fileinfo || time = $time || text = $text || sentfrom = $sentFrom || read = $_read || reactioncount = $reactioncount";
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
