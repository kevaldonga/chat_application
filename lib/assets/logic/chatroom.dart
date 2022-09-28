import 'package:chatty/assets/logic/profile.dart';

import '../common/functions/generateid.dart';
import 'chat.dart';

class ChatRoom {
  final String id;
  // it includes both name and phoneno of connected parties
  List<Profile> connectedPersons = [];
  // {
  //   "kevaldonga38@gmail.com" : {"name" : "keval","phoneno" : "9484844946","photourl": "url"},
  // }
  List<Chat> chats;
  ChatRoom({
    id,
    required this.connectedPersons,
    required this.chats,
  }) : id = id ?? generatedid(10);

  void sortchats(){
    chats.sort((a, b) {
      return a.time.compareTo(b.time);
    });
  }

  Chat getlatestchat() {
    sortchats();
    return chats.last;
  }

  int getnotificationcount(){
    int count = 0;
    for(int i = 0; i < chats.length; i++){
      if(!chats[i].read){
        count++;
      }
    }
    return count;
  }
}