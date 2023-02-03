import 'dart:io';

import 'package:chatty/assets/alertdialog/alertdialog.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/logic/FirebaseUser.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/profiles/common/functions/setprofileimage.dart';
import 'package:chatty/userside/profiles/common/widgets/animatedappbar.dart';
import 'package:chatty/userside/profiles/common/widgets/groupinfoitem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../assets/SystemChannels/picker.dart';
import '../../../assets/logic/chat.dart';
import '../../../assets/logic/profile.dart';
import '../common/functions/compressimage.dart';
import '../common/widgets/bio.dart';
import '../common/widgets/chatroom_media.dart';
import '../common/widgets/mediavisibility.dart';

class GroupProfile extends StatefulWidget {
  final String myphoneno;
  final List<Chat> mediachats;
  final Map<String, String> sentData;
  FirebaseUser user;
  ChatRoom chatroom;

  GroupProfile({
    super.key,
    required this.myphoneno,
    required this.mediachats,
    required this.sentData,
    required this.user,
    required this.chatroom,
  });

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  String? name, bio;
  File? file;
  late MediaQueryData md;
  late bool amIadmin;

  @override
  void initState() {
    super.initState();
    amIadmin = isthisadmin(widget.myphoneno);
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        onbackpressed(context);
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: MyColors.primarySwatch,
          statusBarIconBrightness: Brightness.light,
        ),
        child: SafeArea(
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CustomAppbar(
                    onprofiletap: () async {
                      Picker picker = Picker(onResult: (value) async {
                        if (value == null) {
                          return;
                        }
                        file = await compressimage(value, 80);
                        setState(() {});
                      });
                      picker.pickimage();
                    },
                    areyouadmin: amIadmin,
                    url: widget.chatroom.groupinfo!.photourl,
                    file: file,
                    onbackpressed: () {
                      onbackpressed(context);
                    },
                    herotag: widget.chatroom.id,
                    screenWidth: md.size.width,
                    name: widget.chatroom.groupinfo!.name,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PhoneAndName(
                        description: null,
                        name: widget.chatroom.groupinfo!.name,
                      ),
                      bioWidget(
                        bio: widget.chatroom.groupinfo!.bio,
                        name: widget.chatroom.groupinfo!.name,
                      ),
                      MediaVisibility(
                        id: widget.chatroom.id,
                        user: widget.user,
                      ),
                    ],
                  ),
                ),
                if (widget.mediachats.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ChatroomMedia(
                      sentdata: widget.sentData,
                      chats: widget.mediachats,
                      height: md.size.height * 0.13,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: participantsList(),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: md.size.height * 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onbackpressed(context) async {
    bool diditchange = file != null || name != null || bio != null;
    if (diditchange) {
      Toast("saving info...");
    }
    if (file != null) {
      String url = await setuserprofile(file!);
      widget.chatroom.groupinfo!.photourl = url;
    }
    if (name != null) {
      widget.chatroom.groupinfo!.name = name!;
    }
    if (bio != null) {
      widget.chatroom.groupinfo!.bio = bio!;
    }
    await Database.writegroupinfo(
        widget.chatroom.id, widget.chatroom.groupinfo!);
    Navigator.of(context)
        .pop({"chatroom": widget.chatroom, "firebaseuser": widget.user});
  }

  Widget participantsList() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "participants",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // participants list including admins
          ...List.generate(widget.chatroom.connectedPersons.length, (index) {
            Profile currentprofile = widget.chatroom.connectedPersons[index];
            return chatroomitem(
              onitemtap: () {
                onitemtap(currentprofile);
              },
              amIadmin: amIadmin,
              md: md,
              url: currentprofile.photourl,
              name: currentprofile.getName,
              bio: currentprofile.bio,
              endactions: isthisadmin(currentprofile.getPhoneNumber)
                  ? adminContainer()
                  : null,
            );
          }),
        ],
      ),
    );
  }

  bool isthisadmin(String phoneno) {
    return widget.chatroom.groupinfo!.admins.contains(phoneno);
  }

  Widget adminContainer() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: MyGradients.maingradientvertical,
      ),
      child: const Text(
        "admin",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void onitemtap(Profile profile) async {
    // if its me return
    if (profile.getPhoneNumber == widget.myphoneno) {
      return;
    }
    bool admin = isthisadmin(profile.getPhoneNumber);
    await showdialog(
      barrierDismissible: true,
      context: context,
      title: null,
      contents: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          alertdialogitem(
            admin ? "Dismiss as admin" : "Make group admin",
            () async {
              Navigator.pop(context);
              if (admin) {
                // removing an admin
                widget.chatroom.groupinfo!.admins
                    .remove(profile.getPhoneNumber);
                Toast("${profile.getName} has been dismissed as an admin");
              } else {
                widget.chatroom.groupinfo!.admins.add(profile.getPhoneNumber);
                Toast("${profile.getName} is now an admin");
              }
              // update groupinfo to remove or add admin
              await Database.writegroupinfo(
                widget.chatroom.id,
                widget.chatroom.groupinfo!,
              );
              setState(() {});
            },
          ),
          alertdialogitem(
            "Remove ${profile.getName}",
            () async {
              Navigator.pop(context);
              if (admin) {
                widget.chatroom.groupinfo!.admins
                    .remove(profile.getPhoneNumber);
              }
              widget.chatroom.connectedPersons.remove(profile);
              Toast("${profile.getName} has been removed from group");
              // update the groupinfo
              await Database.writegroupinfo(
                  widget.chatroom.id, widget.chatroom.groupinfo!);
              if (admin) {
                String uid = await Database.getuid(profile.getPhoneNumber);
                await Database.updateparticipants(
                    uid, widget.chatroom.id, false);
              }
              setState(() {});
            },
          ),
        ],
      ),
      actions: null,
    );
  }

  Widget alertdialogitem(String text, VoidCallback ontap) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.black26,
      borderRadius: BorderRadius.circular(8),
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        width: double.infinity,
        child: Text(text),
      ),
    );
  }
}
