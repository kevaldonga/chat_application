import 'dart:developer';

import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chatty/assets/logic/chatroom.dart';
import '../../assets/logic/chat.dart';
import '../../assets/logic/profile.dart';

class Database {
  static FirebaseFirestore? _db;

  static Future<void> writechat(
      {required Chat chat, required String chatroomid}) async {
    _db ??= FirebaseFirestore.instance;
    // write it globally
    await _db?.collection("chats").doc(chat.id).set(chat.toMap());

    // put id of chat in respected chatroom
    // using array union of field value you can update individual elements in array
    await _db?.collection("chatrooms").doc(chatroomid).update({
      "chatids": FieldValue.arrayUnion([chat.id])
    });
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
    // write it globally
    List<String> uids = [];
    // get uids by phone no given in profiles
    for (int i = 0; i < chatroom.connectedPersons.length; i++) {
      String? uid = await getuid(chatroom.connectedPersons[i].getPhoneNumber);
      if (uid == null) continue;
      uids.add(uid);
    }

    // sets write chat globally
    await _db
        ?.collection("chatrooms")
        .doc(chatroom.id)
        .set({"chatids": chatroom.chats, "connectedpersons": uids});

    // write chatroom id to everyconnected parties' account in connectedchatrooms

    for (int i = 0; i < uids.length; i++) {
      // using fieldvalue you can update values inside of an array of documents
      // first of all you have to create empty docs before using update
      await _db?.collection("connectedchatrooms").doc(uids[i]).set({});
      await _db?.collection("connectedchatrooms").doc(uids[i]).update({
        "chatroomids": FieldValue.arrayUnion([chatroom.id]),
      });
    }
  }

  static Future<ChatRoom> readchatroom({required String id}) async {
    _db ??= FirebaseFirestore.instance;
    // gets all chats ids
    Map<String, dynamic>? data = {};
    await _db?.collection("chatrooms").doc(id).get().then((value) {
      data = value.data();
    });
    List<dynamic> chatids = data?["chatids"];
    List<Chat> chats = [];

    // get chats by its ids
    for (int i = 0; i < chatids.length; i++) {
      Chat? chat = await Database.readchat(chatids[i]);
      if (chat == null) continue;
      chats.add(chat);
    }

    // get personal info by getting uids of both parties
    List<dynamic> uids = data?["connectedpersons"];
    List<Profile> profiles = [];
    for (int i = 0; i < uids.length; i++) {
      profiles.add(Profile.fromMap(data: await getpersonalinfo(uids[i])));
    }
    return ChatRoom(id: id, connectedPersons: profiles, chats: chats);
  }

  static Future<void> writepersonalinfo(Profile profile) async {
    _db ??= FirebaseFirestore.instance;
    await _db
        ?.collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(profile.toMap());
    log("inserted value of ${profile.toString()}");
  }

  static Future<String?> getuid(String phoneno) async {
    _db = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>>? data;
    try {
      data = await _db?.collection("userquickinfo").doc(phoneno).get();
    } catch (e) {
      return null;
    }
    return data!.data()?["uid"];
  }

  static Future<void> setuid(String phoneno, String uid) async {
    _db = FirebaseFirestore.instance;
    await _db?.collection("userquickinfo").doc(phoneno).set({"uid": uid});
  }

  static Future<List<ChatRoom>?> retrivechatrooms(
      {required String uid, Map<String, dynamic>? snapshot}) async {
    _db ??= FirebaseFirestore.instance;
    // retrive all ids of connectedchatrooms
    List<dynamic>? chatroomids = [];
    if (snapshot == null) {
      await _db?.collection("connectedchatrooms").doc(uid).get().then((value) {
        chatroomids = value.data()?["chatroomids"];
      });
    } else {
      chatroomids = snapshot["chatroomsids"];
    }
    if (chatroomids == null) {
      log("chat ids are null");
      return null;
    }
    // retrive all chatrooms by its ids
    List<ChatRoom> chatrooms = [];
    for (int i = 0; i < chatroomids!.length; i++) {
      chatrooms.add(await Database.readchatroom(id: chatroomids![i]));
    }
    return chatrooms;
  }

  static void markchatsread(List<Chat> chats) async{
    _db = FirebaseFirestore.instance;

    // update all chats individualy by its ids 
    for(int i = 0; i < chats.length; i++){
      await _db?.collection("chats").doc(chats[i].id).update({"read": true});
    }
  }
}
