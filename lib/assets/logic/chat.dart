class Chat {
  final String _id;
  final DateTime _time;
  final String _text;
  final String _sentFrom;

  String get id => _id;

  DateTime get time => _time;

  String get text => _text;
  
  String get sentFrom => _sentFrom;

  Chat({
    required id,
    required time,
    required text,
    required sentFrom,
  })  : _id = id,
        _time = time,
        _text = text,
        _sentFrom = sentFrom;

  Chat.fromMap({required Map<String, String> chat})
      : _id = chat["id"]!,
        _time = DateTime.parse(chat["time"]!),
        _text = chat["text"]!,
        _sentFrom = chat["sentfrom"]!;

  Map<String, String> toMap() {
    return {
      "id": _id,
      "time": _time.toString(),
      "text": _text,
    };
  }
}
