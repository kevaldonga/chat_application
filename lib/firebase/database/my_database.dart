import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chatty/assets/logic/chatroom.dart';
import '../../assets/logic/chat.dart';
import '../../assets/logic/profile.dart';

class Database {
  static FirebaseFirestore? _db;

  static Future<void> writechat(Chat chat) async {
    _db ??= FirebaseFirestore.instance;
    await _db?.collection("chats").doc(chat.id).set(chat.toMap());
  }

  static Future<Chat?> readchat(String id) async {
    _db ??= FirebaseFirestore.instance;
    Map<String, dynamic>? chat = {};
    await _db?.collection("chats").doc(id).get().then((value) {
      chat = value.data();
    });
    if (chat == null) {
      return null;
    }
    return Chat.fromMap(chat: chat!);
  }

  static Future<void> writechatroom(ChatRoom chatroom) async {
    _db ??= FirebaseFirestore.instance;
    List<String> chatids = [];
    for (int i = 0; i < chatroom.chats.length; i++) {
      chatids.add(chatroom.chats[i].id);
    }
    // adding chats ids
    await _db
        ?.collection("chatrooms")
        .doc(chatroom.id)
        .set({"chatids": chatids});
    // adding connected persons
    await _db
        ?.collection("chatrooms")
        .doc("connectedpersons")
        .set(chatroom.connectedPersons);
  }

  static Future<ChatRoom> readchatroom(String id) async {
    _db ??= FirebaseFirestore.instance;
    // gets all chats ids
    Map<String, dynamic>? data = {};
    await _db?.collection("chatrooms").doc(id).get().then((value) {
      data = value.data();
    });
    List<dynamic> chatids = data?["chatids"] as List<dynamic>;
    // retrive chats by ids in list of chat
    List<Chat> chats = [];
    for (int i = 0; i < chatids.length; i++) {
      Chat? chat = await readchat(chatids[i].toString());
      if (chat == null) {
        log("chat id of ${chatids[i]} was found null");
      } else {
        chats.add(chat);
      }
    }
    // get connected persons
    await _db
        ?.collection("chatsrooms")
        .doc("connectedpersons")
        .get()
        .then((value) {
      data = value.data();
    });
    Map<String, Profile> connectedpersons = {};
    data?.forEach((key, val) {
      connectedpersons[key] = Profile.fromMap(data: val);
    });
    return ChatRoom(connectedPersons: connectedpersons, chats: chats, id: id);
  }

  static void writepersonalinfo(Profile profile) async {
    _db ??= FirebaseFirestore.instance;
    _db?.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).set(profile.toMap());
    log("inserted value of ${profile.toString()}");
  }
}
