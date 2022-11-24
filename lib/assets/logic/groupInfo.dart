import 'package:chatty/assets/logic/profile.dart';

class GroupInfo {
  String name;
  String photourl;
  Profile admin;
  GroupInfo({
    required this.name,
    required this.photourl,
    required this.admin,
  });
}
