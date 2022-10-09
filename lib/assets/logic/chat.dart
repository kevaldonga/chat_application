class Chat {
  final String _id;
  final DateTime _time;
  final String _text;
  final String _sentFrom;
  bool _read = false;

  String get id => _id;

  DateTime get time => _time;

  String get text => _text;
  
  String get sentFrom => _sentFrom;

  bool get isread => _read;

  set setread(bool read) => _read = read;

  Chat({
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
        _read = chat["read"]!;

  Map<String, dynamic> toMap() {
    return {
      "id": _id,
      "time": _time.toString(),
      "text": _text,
      "sentfrom": _sentFrom,
      "read": _read,
    };
  }

  @override
  String toString(){
    return "id = $_id || time = $time || text = $text || sentfrom = $sentFrom || read = $_read";
  }
}
