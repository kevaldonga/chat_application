import 'package:cloud_firestore/cloud_firestore.dart';

import '../../assets/logic/chat.dart';


class Database{
  static FirebaseFirestore? _db;
  static Future<void> writechat(Chat chat) async{
    _db ??= FirebaseFirestore.instance;
    _db?.collection("chats").doc("/radomlygeneratedid/").set(chat.toMap());
  }
}