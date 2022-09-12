import 'chat.dart';

class ChatRoom {
  final String collectionPath; // to read data
  List<String> connnectedPersons = []; // most of the time 2
  Map<String,List<Chat>> chats;
  ChatRoom({
    required this.collectionPath, 
    required this.connnectedPersons,
    required this.chats,
  });
}
