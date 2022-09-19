class Profile {
  String _email;
  String _name;
  String _phoneNumber;
  String? _photourl;

  String get getEmail => _email;

  set setEmail(String email) => _email = email;

  String get getName => _name;

  set setName(name) => _name = name;

  String get getPhoneNumber => _phoneNumber;

  set setPhoneNumber(phoneNumber) => _phoneNumber = phoneNumber;

  String? get getPhotourl => _photourl;

  set setPhotourl(photourl) => _photourl = photourl;

  Profile({
    required String email,
    required String name,
    required String phoneNumber,
    String? photourl,
  })  : _email = email,
        _name = name,
        _phoneNumber = phoneNumber,
        _photourl = photourl;

  Profile.fromMap({
    required Map<String, dynamic> data,
  })  : _name = data["name"].toString(),
        _email = data["email"].toString(),
        _phoneNumber = data["phoneno"].toString(),
        _photourl = data["photourl"].toString().isEmpty
            ? null
            : data["photourl"].toString();

  Map<String, String?> toMap() {
    return {
      "email": _email,
      "name": _name,
      "phoneno": _phoneNumber,
      "photourl": _photourl,
    };
  }

  @override
  String toString() =>
      "email = $_email || name = $_name || phoneno = $_phoneNumber || photourl = $_photourl";
}
