import 'dart:developer';

import 'package:chatty/assets/logic/FirebaseUser.dart';
import 'package:chatty/assets/logic/groupInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chatty/assets/logic/chatroom.dart';
import '../../assets/logic/chat.dart';
import '../../assets/logic/profile.dart';
import '../../userside/profiles/common/functions/getpersonalinfo.dart';

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
    log("written chat $chat");
  }

  static Future<void> updatechat(Chat chat) async {
    _db ??= FirebaseFirestore.instance;

    // update it only by its id
    // dont need anything
    await _db?.collection("chats").doc(chat.id).update(chat.toMap());
    log("updated chat $chat");
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
    log("retrived chat $chat");
    return Chat.fromMap(chat: chat!);
  }

  static Future<void> writechatroom(ChatRoom chatroom) async {
    _db ??= FirebaseFirestore.instance;
    // write it globally
    List<String> uids = [];
    // get uids by phone no given in profiles
    for (int i = 0; i < chatroom.connectedPersons.length; i++) {
      String? uid = await getuid(chatroom.connectedPersons[i].getPhoneNumber);
      uids.add(uid);
    }

    // sets write chat globally
    Map<String, dynamic> data = {
      "chatids": chatroom.chats,
      "connectedpersons": uids,
      if (chatroom.isitgroup) "isitgroup": chatroom.isitgroup,
    };
    if (chatroom.isitgroup) {
      await _db
          ?.collection("groupinfo")
          .doc(chatroom.id)
          .set(chatroom.groupinfo!.toMap());
    }
    await _db?.collection("chatrooms").doc(chatroom.id).set(data);

    // write chatroom id to everyconnected parties' account in connectedchatrooms

    for (int i = 0; i < uids.length; i++) {
      // using fieldvalue you can update values inside of an array of documents
      // first of all you have to create empty docs before using update

      await _db?.collection("connectedchatrooms").doc(uids[i]).set({
        "chatroomids": FieldValue.arrayUnion([chatroom.id]),
      }, SetOptions(merge: true));
    }
  }

  static Future<ChatRoom> readchatroom({required String id}) async {
    _db ??= FirebaseFirestore.instance;
    Map<String, dynamic>? data = {};
    await _db?.collection("chatrooms").doc(id).get().then((value) {
      data = value.data();
    });
    // get groupinfo if available
    GroupInfo? groupinfo;
    if (data?["isitgroup"] ?? false) {
      await Database.readgroupinfo(id).then((value) {
        groupinfo = value;
      });
    }

    // gets all chats ids
    List<dynamic> chatids = data?["chatids"] ?? [];
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
    return ChatRoom(
      id: id,
      connectedPersons: profiles,
      chats: chats,
      groupinfo: groupinfo,
    );
  }

  static Future<void> writepersonalinfo(Profile profile) async {
    _db ??= FirebaseFirestore.instance;
    await _db
        ?.collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(profile.toMap());
    log("inserted value of $profile");
  }

  static Future<String> getuid(String phoneno) async {
    _db = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>>? data;
    data = await _db?.collection("userquickinfo").doc(phoneno).get();
    return data!.data()?["uid"];
  }

  static Future<void> setuid(String phoneno, String uid) async {
    _db = FirebaseFirestore.instance;
    await _db?.collection("userquickinfo").doc(phoneno).set({"uid": uid});
  }

  static Future<List<ChatRoom>?> retrivechatrooms({
    required String uid,
    Map<String, dynamic>? snapshot,
  }) async {
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

  static Future<void> markchatsread(List<Chat> chats, String phoneno) async {
    _db = FirebaseFirestore.instance;

    // update all chats individualy by its ids
    for (int i = 0; i < chats.length; i++) {
      if (chats[i].sentFrom != phoneno && !chats[i].isread) {
        await _db?.collection("chats").doc(chats[i].id).update({"read": true});
      }
    }
  }

  static Future<List<Chat>> refreshchatroom(
    Map<String, dynamic> snapshot,
    List<Chat> chats,
  ) async {
    List<dynamic> latestchatids = snapshot["chatids"] ?? [];
    // create array of chats ids
    List<String> chatids = [];
    for (int i = 0; i < chats.length; i++) {
      chatids.add(chats[i].id);
    }

    // compare both array ids to find new ids
    // and retrive chats from that ids
    for (int i = 0; i < latestchatids.length; i++) {
      if (!chatids.contains(latestchatids[i])) {
        await Database.readchat(latestchatids[i]).then((value) {
          chats.add(value!);
        });
      }
    }
    return chats;
  }

  static Future<List<ChatRoom>> chatroomidsListener(
      Map<String, dynamic>? snapshot, List<ChatRoom> chatrooms) async {
    _db ??= FirebaseFirestore.instance;

    // return if snapshot is null
    if (snapshot == null) {
      log("chatroom listener found null snapshot !!");
      return [];
    }

    // retrive old chatrooms ids
    List<String> oldchatroomids = [];
    for (int i = 0; i < chatrooms.length; i++) {
      oldchatroomids.add(chatrooms[i].id);
    }

    // retrive new chatrooms ids
    List<dynamic> newchatroomsids = snapshot["chatroomids"] ?? [];
    if (newchatroomsids.isEmpty) {
      return [];
    }

    // check if need to add or remvoe
    if (newchatroomsids.length < oldchatroomids.length) {
      List<String> idstoberemoved =
          oldchatroomids.toSet().difference(newchatroomsids.toSet()).toList();

      // remove chatrooms
      for (int i = 0; i < chatrooms.length; i++) {
        if (idstoberemoved.contains(chatrooms[i].id)) {
          chatrooms.removeAt(i);
          log("chatroom id ${chatrooms[i].id} has been removed");
        }
      }
      return chatrooms;
    } else {
      List<String> idstobeadded = newchatroomsids
          .toSet()
          .difference(oldchatroomids.toSet())
          .toList()
          .cast();

      // add chatrooms
      for (int i = 0; i < idstobeadded.length; i++) {
        await Database.readchatroom(id: idstobeadded[i]).then((value) {
          // check if it exist
          bool shouldadd = true;
          inner:
          for (int i = 0; i < chatrooms.length; i++) {
            if (value.id == chatrooms[i].id) {
              shouldadd = false;
              break inner;
            }
          }
          if (shouldadd) {
            chatrooms.add(value);
            log("chatroom id ${idstobeadded[i]} has been added");
          }
        });
      }
      return chatrooms;
    }
  }

  static Future<FirebaseUser> readFirebaseUser(String uid) async {
    _db ??= FirebaseFirestore.instance;
    Map<String, dynamic> mediavisibility = {};
    await _db?.collection("connectedchatrooms").doc(uid).get().then((value) {
      mediavisibility = value.data()?["mediavisibility"] ?? {};
    });
    return FirebaseUser(mediavisibility: mediavisibility.cast<String, bool>());
  }

  static Future<void> setmediavisibility(
    String myuid,
    FirebaseUser user,
  ) async {
    _db ??= FirebaseFirestore.instance;
    await _db
        ?.collection("connectedchatrooms")
        .doc(myuid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  static Future<List<GroupInfo>> intializeCommonGroups(
    List<String> commongroupids,
  ) async {
    _db ??= FirebaseFirestore.instance;

    // retrive groupinfos by ids
    List<GroupInfo> groupinfos = [];
    for (int i = 0; i < commongroupids.length; i++) {
      await Database.readgroupinfo(commongroupids[i]).then((value) {
        groupinfos.add(value);
      });
    }
    return groupinfos;
  }

  static Future<List<GroupInfo>> getCommonGroupChatRoomids(
      List<String> uids) async {
    _db ??= FirebaseFirestore.instance;
    // returns common chatrooms id
    List<dynamic> mychatroomsids = [];
    List<dynamic> userchatroomsids = [];

    // get my chatroom ids
    await _db
        ?.collection("connectedchatrooms")
        .doc(uids[0])
        .get()
        .then((value) {
      mychatroomsids = value.data()!["chatroomids"];
    });

    // get user chatroom ids
    await _db
        ?.collection("connectedchatrooms")
        .doc(uids[1])
        .get()
        .then((value) {
      userchatroomsids = value.data()!["chatroomids"];
    });

    // extract commmon chatrooms ids
    List<String> commonchatroomsids = [];
    for (int i = 0; i < mychatroomsids.length; i++) {
      if (userchatroomsids.contains(mychatroomsids[i])) {
        commonchatroomsids.add(mychatroomsids[i]);
        continue;
      }
    }

    // get common groupchatroom ids
    List<String> commongroupids = [];
    for (int i = 0; i < commonchatroomsids.length; i++) {
      if (await checkExist(commonchatroomsids[i])) {
        commongroupids.add(commonchatroomsids[i]);
      }
    }

    // intialize group infos
    List<GroupInfo> groupinfos = [];
    groupinfos = await Database.intializeCommonGroups(commongroupids);
    return groupinfos;
  }

  static Future<bool> checkExist(String docID) async {
    _db ??= FirebaseFirestore.instance;
    var data = await _db?.collection("groupinfo").doc(docID).get();
    if (data == null) return false;
    return data.exists;
  }

  static Future<GroupInfo> readgroupinfo(String chatroomid) async {
    _db ??= FirebaseFirestore.instance;
    GroupInfo? groupinfo;
    await _db?.collection("groupinfo").doc(chatroomid).get().then((value) {
      groupinfo = GroupInfo.fromMap(value.data());
    });
    return groupinfo!;
  }

  static Future<void> writegroupinfo(String id, GroupInfo groupinfo) async {
    _db ??= FirebaseFirestore.instance;
    await _db?.collection("groupinfo").doc(id).set(groupinfo.toMap());
  }

  static Future<void> updateparticipants(
    String uid,
    String chatroomid,
    bool shouldadd,
  ) async {
    _db ??= FirebaseFirestore.instance;
    // should add is false then remove the user

    // first of all remove him from chatroom connectedpersons
    await _db?.collection("chatrooms").doc(chatroomid).set(
      {
        "connectedpersons": FieldValue.arrayRemove([uid]),
      },
      SetOptions(merge: true),
    );

    // then remove the chatroom from his profile
    await _db?.collection("connectedpersons").doc(uid).set(
      {
        "chatroomids": FieldValue.arrayRemove([chatroomid])
      },
      SetOptions(merge: true),
    );
  }

  static void updatestatus(String phonenno, int status) async {
    _db ??= FirebaseFirestore.instance;
    _db?.collection("status").doc(phonenno).set({"status": status});
  }
}
