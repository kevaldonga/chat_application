import 'package:chatty/assets/logic/profile.dart';

class FirebaseUser {
  final String _uid;
  final Profile _profile;

  get id => _uid;

  get name => _profile.getName;

  set name(value) => _profile.setName = name;

  get phone => _profile.getPhoneNumber;

  String? get url => _profile.photourl;

  set seturl(String url) => _profile.photourl = url;

  FirebaseUser({
    required String uid,
    required Profile profile,
    required this.connectedchatrooms,
  })  : _uid = uid,
        _profile = profile;
  List<String> connectedchatrooms = [];
}
