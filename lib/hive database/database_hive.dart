import 'dart:developer';

import 'package:chatty/assets/SystemChannels/path.dart';
import 'package:chatty/assets/logic/chat.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/groupInfo.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:hive/hive.dart';

import '../assets/logic/FirebaseUser.dart';
import '../assets/logic/profile.dart';

class MyHive {
  static BoxCollection? _collection;

  static Future<BoxCollection> init() async {
    return await BoxCollection.open(
      "my_database",
      {
        "chatrooms",
        "chats",
        "connectedchatrooms",
        "status",
        "groupinfo",
        "userquickinfo",
        "users",
      },
      path: await PathProvider.documentDirectory(),
    );
  }

  static Future<void> writechat({
    required Chat chat,
    required chatroomid,
  }) async {
    _collection ??= await init();
    final chatsbox = await _collection?.openBox("chats");
    // write it globally
    await chatsbox?.put(chat.id, chat.toMap());

    var chatroomsbox = await _collection?.openBox("chatrooms");
    Map<String, dynamic>? data = await chatroomsbox?.get(chatroomid);
    List<dynamic> chatids = data?["chatids"] ?? [];
    chatids.add(chat.id);
    chatroomsbox?.put(chatroomid, data);
    log("written chat to storage $chat");
  }

  static Future<void> updatechat(Chat chat) async {
    _collection ??= await init();
    final chatsbox = await _collection?.openBox("chats");

    await chatsbox?.put(chat.id, chat.toMap());
    log("updated chat on storage $chat");
  }

  static Future<Chat?> readchat(String id) async {
    _collection ??= await init();

    final chatsbox = await _collection?.openBox("chats");
    final data = await chatsbox?.get(id);
    if (data == null || data.isEmpty) {
      return null;
    }
    log("read chat from storage $data");
    return Chat.fromMap(chat: data);
  }

  static Future<void> writechatroom(ChatRoom chatroom) async {
    _collection ??= await init();
    List<String> uids = [];
    for (int i = 0; i < chatroom.connectedPersons.length; i++) {
      String? uid = await getuid(chatroom.connectedPersons[i].getPhoneNumber);
      uid ??=
          await Database.getuid(chatroom.connectedPersons[i].getPhoneNumber);
      uids.add(uid);
    }
    Map<String, dynamic> data = {
      "chatids": chatroom.chats,
      "connectedpersons": uids,
      if (chatroom.isitgroup) "isitgroup": chatroom.isitgroup,
    };

    if (chatroom.isitgroup) {
      // write in groupinfo if its group
      final groupinfobox = await _collection?.openBox("groupinfo");
      await groupinfobox?.put(chatroom.id, chatroom.groupinfo!.toMap());
    }
    final chatroomsbox = await _collection?.openBox("chatrooms");
    await chatroomsbox?.put(chatroom.id, data);

    for (int i = 0; i < uids.length; i++) {
      final connectedchatroomsbox =
          await _collection?.openBox("connectedchatrooms");
      Map<String, dynamic> chatroomids =
          await connectedchatroomsbox?.get(uids[i]);
      List<dynamic> uid = chatroomids["chatroomids"];
      uid.add(chatroom.id);
      await connectedchatroomsbox?.put(uids[i], chatroomids);
      log("written chatroom to storage $chatroom");
    }
  }

  static Future<String?> getuid(String phoneno) async {
    _collection ??= await init();
    final userquickinfobox = await _collection?.openBox("userquickinfo");
    final data = await userquickinfobox?.get(phoneno);
    return data?["uid"];
  }

  static Future<ChatRoom?> readchatroom(String id) async {
    _collection ??= await init();
    final chatroomsbox = await _collection?.openBox("chatrooms");
    Map<String, dynamic>? data = await chatroomsbox?.get(id);
    if (data == null) {
      return null;
    }
    GroupInfo? groupinfo;
    if (data["isitgroup"] ?? false) {
      groupinfo = await readgroupinfo(id);
    }

    List<dynamic> chatids = data["chatids"] ?? [];
    List<Chat> chats = [];

    for (int i = 0; i < chatids.length; i++) {
      Chat? chat = await readchat(chatids[i]);
      if (chat == null) continue;
      chats.add(chat);
    }

    List<dynamic> uids = data["connectedchatrooms"];
    List<Profile> profiles = [];

    for (int i = 0; i < uids.length; i++) {
      var data = await getpersonalinfo(uids[i]);
      if (data != null) {
        profiles.add(Profile.fromMap(data: data));
      }
    }
    final chatroom = ChatRoom(
      id: id,
      connectedPersons: profiles,
      chats: chats,
      groupinfo: groupinfo,
    );
    log("read chatroom from storage $chatroom");
    return chatroom;
  }

  static Future<GroupInfo?> readgroupinfo(String id) async {
    _collection ??= await init();
    GroupInfo? groupinfo;
    final groupinfobox = await _collection?.openBox("groupinfo");
    Map<String, dynamic>? data = await groupinfobox?.get(id);
    if (data == null || data.isEmpty) {
      return null;
    }
    log("read groupinfo from storage $data");
    groupinfo = GroupInfo.fromMap(data);
    return groupinfo;
  }

  static Future<Map<String, dynamic>?> getpersonalinfo(String uid) async {
    _collection ??= await init();
    final usersbox = await _collection?.openBox("users");
    Map<dynamic, dynamic>? data = await usersbox?.get(uid);
    log("read personal info to storage $data");
    return data?.cast();
  }

  static Future<void> writepersonalinfo(String uid, Profile profile) async {
    _collection ??= await init();
    final usersbox = await _collection?.openBox("users");
    await usersbox?.put(uid, profile.toMap());
    log("inserted value of $profile");
  }

  static Future<void> setuid(String phoneno, String uid) async {
    _collection ??= await init();
    final quickinfo = await _collection?.openBox("userquickinfo");
    await quickinfo?.put(phoneno, {"uid": uid});
  }

  static Future<void> setmediavisibility(
    String uid,
    FirebaseUser user,
  ) async {
    _collection ??= await init();
    final connectedchatroomsbox =
        await _collection?.openBox("connectedchatrooms");
    Map<dynamic, dynamic> data = await connectedchatroomsbox?.get(uid) ?? {};
    data.addAll(user.toMap());
    log("written mediavisibility to storage $data");
    await connectedchatroomsbox?.put(uid, data);
  }

  static Future<List<GroupInfo>> intializeCommonGroups(
    List<String> commongroupids,
  ) async {
    _collection ??= await init();

    // retrive groupinfos by ids
    List<GroupInfo> groupinfos = [];
    for (int i = 0; i < commongroupids.length; i++) {
      await readgroupinfo(commongroupids[i]).then((value) async {
        value ??= await Database.readgroupinfo(commongroupids[i]);
        groupinfos.add(value);
      });
    }
    log("intialized common groups from storage $groupinfos");
    return groupinfos;
  }

  static Future<void> writegroupinfo(String id, GroupInfo groupinfo) async {
    _collection ??= await init();
    final groupinfobox = await _collection?.openBox("groupinfo");
    await groupinfobox?.put(id, groupinfo.toMap());
  }

  static Future<void> markchatread(Chat chat) async {
    _collection ??= await init();
    final chatsbox = await _collection?.openBox("chats");
    if (!chat.isread) {
      var data = await chatsbox?.get(chat.id);
      data["read"] = true;
      await chatsbox?.put(chat.id, data);
    }
  }

  static Future<FirebaseUser?> readMediavisibility(String uid) async {
    _collection ??= await init();
    final connectedchatroomsbox =
        await _collection?.openBox("connectedchatrooms");
    Map<dynamic, dynamic>? data = await connectedchatroomsbox?.get(uid);
    if (data == null || data.isEmpty) {
      return null;
    }
    log("read mediavisiblity from storage $data");
    return FirebaseUser(
        mediavisibility: data["mediavisibility"].cast<String, bool>());
  }
}
