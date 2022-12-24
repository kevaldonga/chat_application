class Profile {
  String _email;
  String _name;
  String _phoneNumber;
  String? photourl;
  String? bio;

  String get getEmail => _email;

  set setEmail(String email) => _email = email;

  String get getName => _name;

  set setName(name) => _name = name;

  String get getPhoneNumber => _phoneNumber;

  set setPhoneNumber(phoneNumber) => _phoneNumber = phoneNumber;

  Profile(
      {required String email,
      required String name,
      required String phoneNumber,
      this.photourl,
      this.bio})
      : _email = email,
        _name = name,
        _phoneNumber = phoneNumber;

  Profile.fromMap({
    required Map<String, dynamic> data,
  })  : _name = data["name"].toString(),
        _email = data["email"].toString(),
        _phoneNumber = data["phoneno"].toString(),
        photourl = data["photourl"].toString().isEmpty
            ? null
            : data["photourl"].toString(),
        bio = data["bio"].toString().isEmpty ? null : data["bio"].toString();

  Map<String, String?> toMap() {
    return {
      "email": _email,
      "name": _name,
      "phoneno": _phoneNumber,
      if (photourl != null && photourl != "null" && photourl != "")
        "photourl": photourl,
      if (bio != null && bio != "null" && bio != "") "bio": bio,
    };
  }

  @override
  String toString() =>
      "email = $_email || name = $_name || phoneno = $_phoneNumber || photourl = $photourl";
}
