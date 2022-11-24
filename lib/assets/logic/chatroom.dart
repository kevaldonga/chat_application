import 'package:chatty/assets/logic/profile.dart';

import '../common/functions/generateid.dart';
import 'chat.dart';
import 'groupInfo.dart';

class ChatRoom {
  final String id;
  final List<Profile> _connectedPersons;
  List<Chat> chats;
  GroupInfo? groupinfo;
  bool isitgroup = false;

  List<Profile> get connectedPersons => _connectedPersons;

  ChatRoom({
    id,
    this.groupinfo,
    required List<Profile> connectedPersons,
    required this.chats,
  })  : id = id ?? generatedid(10),
        _connectedPersons = connectedPersons,
        isitgroup = connectedPersons.length > 2 && groupinfo != null;

  List<Chat> sortchats() {
    chats.sort((a, b) {
      return a.time.compareTo(b.time);
    });
    return chats;
  }

  Chat getlatestchat() {
    return chats.last;
  }

  int getnotificationcount({required String myphoneno}) {
    int count = 0;
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].sentFrom != myphoneno && !chats[i].isread) {
        count++;
      }
    }
    return count;
  }

  @override
  String toString() {
    return "id = $id || list of profiles = $_connectedPersons || list of chats = $chats";
  }
}
