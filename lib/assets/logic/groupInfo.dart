import 'package:chatty/assets/logic/profile.dart';

class GroupInfo {
  String name;
  String photourl;
  List<Profile> admins;
  GroupInfo({
    required this.name,
    required this.photourl,
    required this.admins,
  });
}
