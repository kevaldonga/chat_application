class User {
  final String _uid;
  String _name;
  final String _phone;

  get id => _uid;

  get name => _name;

  set name(value) => _name = value;

  get phone => _phone;

  User({
    required uid,
    required name,
    required phone,
  })  : _uid = uid,
        _name = name,
        _phone = phone;
  List<String> connectedchatrooms = [];
}
