import 'dart:developer';

import 'package:chatty/firebase/database/database_hive.dart';
import 'package:chatty/utils/chat.dart';
import 'package:chatty/utils/chatroom.dart';
import 'package:chatty/utils/firebase_user.dart';
import 'package:chatty/utils/group_info.dart';
import 'package:chatty/utils/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class Database {
  static FirebaseFirestore? _db;

  static Future<void> writechat({
    required Chat chat,
    required String chatroomid,
  }) async {
    _db ??= FirebaseFirestore.instance;
    // write it globally
    await _db?.collection("chats").doc(chat.id).set(chat.toMap());

    // put id of chat in respected chatroom
    // using array union of field value you can update individual elements in array
    await _db?.collection("chatrooms").doc(chatroomid).update({
      "chatids": FieldValue.arrayUnion([chat.id])
    });
    await MyHive.writechat(chat: chat, chatroomid: chatroomid);
    log("written chat $chat");
  }

  static Future<void> updatechat(Chat chat) async {
    _db ??= FirebaseFirestore.instance;

    // update it only by its id
    // dont need anything
    await _db?.collection("chats").doc(chat.id).update(chat.toMap());

    await MyHive.updatechat(chat);
    log("updated chat $chat");
  }

  static Future<Chat?> readchat(String id) async {
    Chat? chat = await MyHive.readchat(id);

    // only changable item is read in chat
    // we first check if that property can be changed now or not
    // like if read is true it cant be false now so it is safe to read from storage
    if (chat != null && chat.isread) {
      return chat;
    }
    _db ??= FirebaseFirestore.instance;
    Map<String, dynamic>? data = {};
    await _db?.collection("chats").doc(id).get().then((value) {
      data = value.data();
    });
    if (data == null) {
      return null;
    }

    chat = Chat.fromMap(chat: data!);

    if (chat.isread) {
      await MyHive.updatechat(chat);
    }
    log("retrived chat $chat");
    return chat;
  }

  static Future<void> writechatroom(ChatRoom chatroom) async {
    _db ??= FirebaseFirestore.instance;
    // write it globally
    List<String> uids = [];
    // get uids by phone no given in profiles
    for (int i = 0; i < chatroom.connectedPersons.length; i++) {
      String? uid = await getuid(chatroom.connectedPersons[i].getPhoneNumber);
      uids.add(uid!);
    }

    // sets write chat globally
    Map<String, dynamic> data = {
      "chatids": chatroom.chats,
      "connectedpersons": uids,
      if (chatroom.isitgroup) "isitgroup": chatroom.isitgroup,
      "blockedby": chatroom.blockedby,
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
    await MyHive.writechatroom(chatroom);
  }

  static Future<ChatRoom?> readchatroom({
    required String id,
    required Profile myprofile,
  }) async {
    ChatRoom? chatroom = await MyHive.readchatroom(id);

    _db ??= FirebaseFirestore.instance;

    Map<String, dynamic> data = {};
    await _db?.collection("chatrooms").doc(id).get().then((value) {
      data = value.data() ?? {};
    });

    // check if data is empty just return storage copy of chatroom
    if (data.isEmpty) {
      return chatroom;
    }
    List<Chat> chats = [];
    if (chatroom != null) {
      // check for chats added or removed
      List<dynamic> firestorechats = data["chatids"];
      List<String> hivechats = List.generate(chatroom.chats.length, (index) {
        return chatroom.chats[index].id;
      });

      if (firestorechats.length > hivechats.length) {
        List<String> chatstobeadded = subtractcommon(firestorechats, hivechats);
        for (int i = 0; i < chatstobeadded.length; i++) {
          Chat? chat = await readchat(id);
          if (chat != null) {
            chatroom.chats.add(chat);
            // write new chat to storage
            await MyHive.writechat(chat: chat, chatroomid: chatroom.id);
          }
        }
      } else if (firestorechats.length < hivechats.length) {
        // these chats will be added to firestore from storage
        List<String> chatstobeadded = subtractcommon(hivechats, firestorechats);
        for (int i = 0; i < chatstobeadded.length; i++) {
          await writechat(
              chat: chatroom.chats
                  .where((element) => element.id == chatstobeadded[i])
                  .first,
              chatroomid: id);
        }
      }
    } else {
      // gets all chats ids
      List<dynamic> chatids = data["chatids"] ?? [];

      // get chats by its ids
      for (int i = 0; i < chatids.length; i++) {
        Chat? chat = await Database.readchat(chatids[i]);
        if (chat == null) continue;
        await MyHive.writechat(chat: chat, chatroomid: id);
        chats.add(chat);
      }
    }
    GroupInfo? groupinfo;
    if (data["isitgroup"] ?? false) {
      await Database.readgroupinfo(id).then((value) {
        groupinfo = value;
      });
    }

    // get personal info by getting uids of both parties
    List<dynamic> uids = data["connectedpersons"];
    // remove my uid so I dont have to read it again and again
    uids.remove(FirebaseAuth.instance.currentUser?.uid);

    // we have remove my profile from getting read from database
    // so we have to manually add it here
    List<Profile> profiles = [myprofile];
    for (int i = 0; i < uids.length; i++) {
      profiles.add(await getpersonalinfo(uids[i]));
    }
    Map<String, dynamic> blockedby = data["blockedby"];

    return ChatRoom(
      id: id,
      blockedby: blockedby.cast<String, bool>(),
      connectedPersons: profiles,
      chats: chatroom == null ? chats : chatroom.chats,
      groupinfo: groupinfo,
    );
  }

  static Future<void> writepersonalinfo(Profile profile) async {
    _db ??= FirebaseFirestore.instance;
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    await _db?.collection("users").doc(uid).set(profile.toMap());
    await MyHive.writepersonalinfo(uid, profile);
    log("inserted value of $profile");
  }

  static Future<String?> getuid(String phoneno) async {
    _db ??= FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>>? data =
        await _db?.collection("userquickinfo").doc(phoneno).get();
    if (data?.data() == null) {
      return null;
    }
    await MyHive.setuid(phoneno, data?.data()?["uid"]);
    return data?.data()?["uid"];
  }

  static Future<void> setuid(String phoneno, String uid) async {
    _db ??= FirebaseFirestore.instance;
    await _db?.collection("userquickinfo").doc(phoneno).set({"uid": uid});
    await MyHive.setuid(phoneno, uid);
  }

  static Future<void> markchatread(Chat chat) async {
    _db ??= FirebaseFirestore.instance;

    if (!chat.isread) {
      await _db?.collection("chats").doc(chat.id).update({"read": true});
    }
    await MyHive.markchatread(chat);
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
        await readchat(latestchatids[i]).then((value) {
          chats.add(value!);
        });
      }
    }
    return chats;
  }

  static Future<List<ChatRoom>> chatroomidsListener(
      Map<String, dynamic>? snapshot,
      List<ChatRoom> chatrooms,
      Profile myprofile) async {
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
          subtractcommon(oldchatroomids, newchatroomsids.cast());

      // remove chatrooms
      for (int i = 0; i < chatrooms.length; i++) {
        if (idstoberemoved.contains(chatrooms[i].id)) {
          log("chatroom id ${chatrooms[i].id} has been removed");
          chatrooms.removeAt(i);
        }
      }
      return chatrooms;
    } else {
      List<String> idstobeadded =
          subtractcommon(newchatroomsids.cast(), oldchatroomids);

      // add chatrooms
      for (int i = 0; i < idstobeadded.length; i++) {
        await readchatroom(id: idstobeadded[i], myprofile: myprofile)
            .then((value) {
          // here just throw error if its null
          if (value == null) {
            throw ErrorDescription(
                "there was error occured trying to retrive chatroom from firebase ${idstobeadded[i]}");
          }
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

  static Future<FirebaseUser> readMediavisibility(String uid) async {
    FirebaseUser? user = await MyHive.readMediavisibility(uid);
    if (user != null) {
      return user;
    }
    _db ??= FirebaseFirestore.instance;
    Map<String, dynamic> mediavisibility = {};
    await _db?.collection("connectedchatrooms").doc(uid).get().then((value) {
      mediavisibility = value.data()?["mediavisibility"] ?? {};
    });
    user = FirebaseUser(mediavisibility: mediavisibility.cast());
    await MyHive.setmediavisibility(uid, user);
    return user;
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
    await MyHive.setmediavisibility(myuid, user);
  }

  static Future<List<GroupInfo>> intializeCommonGroups(
    List<String> commongroupids,
  ) async {
    _db ??= FirebaseFirestore.instance;

    // retrive groupinfos by ids
    List<GroupInfo> groupinfos = [];
    for (int i = 0; i < commongroupids.length; i++) {
      await readgroupinfo(commongroupids[i]).then((value) {
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
    List<String> commonchatroomsids =
        extractcommon(userchatroomsids.cast(), mychatroomsids.cast());

    // get common groupchatroom ids
    List<String> commongroupids = [];
    for (int i = 0; i < commonchatroomsids.length; i++) {
      if (await checkExist(commonchatroomsids[i])) {
        commongroupids.add(commonchatroomsids[i]);
      }
    }

    // intialize group infos
    List<GroupInfo> groupinfos = [];
    groupinfos = await intializeCommonGroups(commongroupids);
    return groupinfos;
  }

  static Future<bool> checkExist(String docID) async {
    _db ??= FirebaseFirestore.instance;
    var data = await _db?.collection("groupinfo").doc(docID).get();
    return data?.exists ?? false;
  }

  static Future<GroupInfo> readgroupinfo(String chatroomid) async {
    // first read groupinfo from firebase and if that comes out null
    // then we will return groupinfo from storage
    GroupInfo? groupinfo;
    _db ??= FirebaseFirestore.instance;
    await _db
        ?.collection("groupinfo")
        .doc(chatroomid)
        .get()
        .then((value) async {
      if (value.data()?.isEmpty ?? true) {
        groupinfo = await MyHive.readgroupinfo(chatroomid);
      } else {
        groupinfo = GroupInfo.fromMap(value.data());
      }
    });
    if (groupinfo == null) {
      throw ErrorDescription("groupinfo was found null please try again later");
    }
    return groupinfo!;
  }

  static Future<void> writegroupinfo(String id, GroupInfo groupinfo) async {
    _db ??= FirebaseFirestore.instance;
    await _db?.collection("groupinfo").doc(id).set(groupinfo.toMap());
    await MyHive.writegroupinfo(id, groupinfo);
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
    await _db?.collection("connectedchatrooms").doc(uid).set(
      {
        "chatroomids": FieldValue.arrayRemove([chatroomid])
      },
      SetOptions(merge: true),
    );
  }

  static void updatestatus(String phonenno, int status) async {
    // dont need hive storage replica for status
    // cause if you are without internet everyone will be offline
    // reading from storage also will read wrong values
    // so better not show read them
    _db ??= FirebaseFirestore.instance;
    _db?.collection("status").doc(phonenno).set({"status": status});
  }

  static Future<Profile> getpersonalinfo(String uid) async {
    Map<String, dynamic>? data;
    _db ??= FirebaseFirestore.instance;
    Profile profile;
    DocumentSnapshot snapshot = await _db!.collection("users").doc(uid).get();
    data = snapshot.data() as Map<String, dynamic>?;
    data ??= await MyHive.getpersonalinfo(uid);
    if (data == null) {
      throw ErrorDescription("couldn't get personal info $uid try again later");
    }
    profile = Profile.fromMap(data: data);
    await MyHive.writepersonalinfo(uid, profile);
    return profile;
  }

  static List<String> extractcommon(List<String> parent, List<String> child) {
    List<String> common = [];
    for (int i = 0; i < child.length; i++) {
      if (parent.contains(child[i])) {
        common.add(child[i]);
        continue;
      }
    }
    return common;
  }

  static List<String> subtractcommon(
      List<dynamic> parent, List<dynamic> child) {
    List<String> unique = [];
    for (int i = 0; i < parent.length; i++) {
      if (!child.contains(parent[i])) {
        unique.add(parent[i]);
        continue;
      }
    }
    return unique;
  }

  static Future<void> updategroupinfo(String id, GroupInfo groupinfo) async {
    _db ??= FirebaseFirestore.instance;

    await _db?.collection("groupinfo").doc(id).update(groupinfo.toMap());
  }

  static Future<void> deletechatroom(ChatRoom chatroom,
      {bool isItGroup = false}) async {
    _db ??= FirebaseFirestore.instance;

    // delete every chat from group
    for (int i = 0; i < chatroom.chats.length; i++) {
      await Database.deleteChat(chatroom.chats[i], chatroom.id);
    }

    if (isItGroup) {
      await _db?.collection("groupinfo").doc(chatroom.id).delete();
    }

    // delete chatroom also
    await _db?.collection("chatrooms").doc(chatroom.id).delete();

    // delete chatroom id in connectedchatrooms
    for (int i = 0; i < chatroom.connectedPersons.length; i++) {
      String? uid = await getuid(chatroom.connectedPersons[i].getPhoneNumber);
      await _db?.collection("connectedchatrooms").doc(uid!).set(
        {
          "chatroomids": FieldValue.arrayRemove([chatroom.id])
        },
        SetOptions(merge: true),
      );
    }

    if (isItGroup) {
      // delete the profile picture if has it
      if (chatroom.groupinfo!.photourl != null) {
        await FirebaseStorage.instance
            .refFromURL(chatroom.groupinfo!.photourl!)
            .delete();
      }
    }
  }

  static Future<void> deleteChat(Chat chat, String chatroomid) async {
    _db ??= FirebaseFirestore.instance;

    // delete globally
    await _db?.collection("chats").doc(chat.id).delete();

    // delete in chatroom
    await _db?.collection("chatrooms").doc(chatroomid).set(
      {
        "chatids": FieldValue.arrayRemove([chat.id]),
      },
      SetOptions(merge: true),
    );

    // delete file if has it
    if (chat.fileinfo != null) {
      await FirebaseStorage.instance.refFromURL(chat.fileinfo!.url!).delete();
    }

    log("deleted chat $chat");
  }

  static Future<void> updateblockedby(
      String chatroomid, Map<String, bool> blockedby) async {
    _db ??= FirebaseFirestore.instance;

    await _db
        ?.collection("chatrooms")
        .doc(chatroomid)
        .update({"blockedby": blockedby});
  }
}
