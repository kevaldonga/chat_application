import 'dart:io';

class Chat {
  final String _id;
  final DateTime _time;
  final String _text;
  final String _sentFrom;
  bool _read = false;
  bool? isiturl;
  File? file;
  String? url;

  String get id => _id;

  DateTime get time => _time;

  String get text => _text;

  String get sentFrom => _sentFrom;

  bool get isread => _read;

  set setread(bool read) => _read = read;

  Chat({
    this.file,
    this.url,
    this.isiturl,
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
        _text = chat["text"]!,
        _sentFrom = chat["sentfrom"]!,
        _read = chat["read"]!,
        url = chat["url"];

  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      if (url != null || url != "null") "url": url,
      "time": _time.toString(),
      "text": _text,
      "sentfrom": _sentFrom,
      "read": _read,
    };
  }

  @override
  String toString() {
    return "id = $_id || url = $url || time = $time || text = $text || sentfrom = $sentFrom || read = $_read";
  }
}
