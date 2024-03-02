import 'dart:io';

import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/global/variables/colors.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/global/widgets/alertdialog.dart';
import 'package:chatty/global/widgets/alertdialog_button.dart';
import 'package:chatty/global/widgets/primary_textfield.dart';
import 'package:chatty/userside/dashview/widgets/popupmenuitem.dart';
import 'package:chatty/userside/profiles/functions/setprofileimage.dart';
import 'package:chatty/userside/profiles/widgets/animatedappbar.dart';
import 'package:chatty/userside/profiles/widgets/groupinfoitem.dart';
import 'package:chatty/utils/chat.dart';
import 'package:chatty/utils/chatroom.dart';
import 'package:chatty/utils/firebase_user.dart';
import 'package:chatty/utils/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import '../../../assets/SystemChannels/picker.dart';
import '../functions/compressimage.dart';
import '../widgets/bio.dart';
import '../widgets/chatroom_media.dart';
import '../widgets/mediavisibility.dart';

class GroupProfile extends StatefulWidget {
  final String myphoneno;
  final List<Chat> mediachats;
  final Map<String, String> sentData;
  final FirebaseUser user;
  final ChatRoom chatroom;

  const GroupProfile({
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

enum PopUp {
  editgroupinfo,
  leave,
  delete,
}

class _GroupProfileState extends State<GroupProfile> {
  String? name, bio;
  File? file;
  late MediaQueryData md;
  late bool amIadmin;
  late TextEditingController groupname;
  late TextEditingController groupbio;

  @override
  void initState() {
    super.initState();
    groupname = TextEditingController(text: widget.chatroom.groupinfo!.name);
    groupbio = TextEditingController(text: widget.chatroom.groupinfo!.bio);
    amIadmin = isthisadmin(widget.myphoneno);
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        onbackpressed(context);
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
                    isitgroup: true,
                    onSelected: (value) async {
                      switch (value) {
                        case PopUp.editgroupinfo:
                          editgroupinfo();
                          break;
                        case PopUp.leave:
                          if (widget.chatroom.groupinfo!.admins.length == 1 &&
                              amIadmin) {
                            Toast("you cant leave as you are the only admin");
                            return;
                          }
                          bool result = await showdialog(
                            context: context,
                            title: const Text("Are you sure ?"),
                            contents: Text(widget
                                        .chatroom.connectedPersons.length ==
                                    2
                                ? "group will be deleted as group with one person can't exist, Are you sure you want to do this ?"
                                : "Are you sure you want to leave ${widget.chatroom.groupinfo!.name} ?"),
                            actions: [
                              AlertDialogButton(
                                text: "YES",
                                callback: () {
                                  context.pop(true);
                                },
                              ),
                              AlertDialogButton(
                                text: "NO",
                                callback: () {
                                  context.pop(false);
                                },
                              ),
                            ],
                          );
                          if (result) {
                            if (widget.chatroom.connectedPersons.length == 2) {
                              deletegroup();
                            } else {
                              leavegroup();
                            }
                          }
                          break;
                        case PopUp.delete:
                          await deletegroupoperation(context);
                          break;
                        default:
                          break;
                      }
                    },
                    items: [
                      if (amIadmin)
                        popupMenuItem(
                          value: PopUp.editgroupinfo,
                          child: const Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                color: MyColors.primarySwatch,
                              ),
                              SizedBox(width: 15),
                              Text("edit group info"),
                            ],
                          ),
                          height: 20,
                        ),
                      popupMenuItem(
                        value: PopUp.leave,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 15),
                            Text("leave"),
                          ],
                        ),
                        height: 20,
                      ),
                      if (amIadmin)
                        popupMenuItem(
                            value: PopUp.delete,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 15),
                                Text("delete group"),
                              ],
                            ),
                            height: 20),
                    ],
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

  Future<void> deletegroupoperation(BuildContext context) async {
    bool result = await showdialog(
      context: context,
      title: const Text("Are you sure ?"),
      contents: const Text(
          "group will be deleted forever and you won't be able to restore data , Are you sure you wanna do this ?"),
      actions: [
        AlertDialogButton(
          text: "YES",
          callback: () {
            context.pop(true);
          },
        ),
        AlertDialogButton(
          text: "NO",
          callback: () {
            context.pop(false);
          },
        ),
      ],
    );
    if (result) {
      deletegroup();
    }
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
    context.pop({"chatroom": widget.chatroom, "firebaseuser": widget.user});
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
              isitgroup: false,
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
    if (profile.getPhoneNumber == widget.myphoneno || !amIadmin) {
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
              context.pop();
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
              await Database.updategroupinfo(
                widget.chatroom.id,
                widget.chatroom.groupinfo!,
              );
              setState(() {});
            },
          ),
          alertdialogitem(
            "Remove ${profile.getName}",
            () async {
              context.pop();
              if (widget.chatroom.connectedPersons.length == 2) {
                deletegroupoperation(context);
                return;
              }
              if (admin) {
                widget.chatroom.groupinfo!.admins
                    .remove(profile.getPhoneNumber);
              }
              widget.chatroom.connectedPersons.remove(profile);
              Toast("${profile.getName} has been removed from group");
              // update the groupinfo
              await Database.updategroupinfo(
                  widget.chatroom.id, widget.chatroom.groupinfo!);
              String uid = (await Database.getuid(profile.getPhoneNumber))!;
              await Database.updateparticipants(uid, widget.chatroom.id, false);
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

  void editgroupinfo() async {
    bool? result = await showdialog(
      barrierDismissible: true,
      context: context,
      title: const Text("Edit Group Info"),
      contents: SizedBox(
        width: md.size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryTextField(
                controller: groupname,
                label: "group name",
                maxLength: 20,
                onChanged: (text) {
                  if (text.length == 20) {
                    Toast("limit reached");
                  }
                },
                keyboardType: TextInputType.name,
              ),
              PrimaryTextField(
                controller: groupbio,
                label: "group bio",
                onChanged: (text) {
                  if (text.length == 50) {
                    Toast("limit reached");
                  }
                },
                keyboardType: TextInputType.multiline,
                maxLength: 50,
              ),
              Center(
                child: TextButton(
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    EasyLoading.show(status: "saving..");
                    if (groupname.text.isEmpty) {
                      Toast("name field is empty");
                      EasyLoading.dismiss();
                      return;
                    }
                    if (groupname.text == widget.chatroom.groupinfo!.name &&
                        groupbio.text == widget.chatroom.groupinfo!.bio) {
                      context.pop();
                      EasyLoading.dismiss();
                      return;
                    }
                    widget.chatroom.groupinfo!.name = groupname.text;
                    widget.chatroom.groupinfo!.bio = groupbio.text;
                    await Database.updategroupinfo(
                        widget.chatroom.id, widget.chatroom.groupinfo!);
                    Toast("info updated successfully !!");
                    EasyLoading.dismiss();
                    if (!context.mounted) return;
                    context.pop(true);
                    setState(() {});
                  },
                  child: const Text("SAVE"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!result) {
      groupname = TextEditingController(text: widget.chatroom.groupinfo!.name);
      groupbio = TextEditingController(text: widget.chatroom.groupinfo!.bio);
    }
  }

  void leavegroup() async {
    EasyLoading.show(status: "leaving");
    Toast("leaving group...");
    if (amIadmin) {
      widget.chatroom.groupinfo!.admins.remove(widget.myphoneno);
      await Database.updategroupinfo(
          widget.chatroom.id, widget.chatroom.groupinfo!);
    }
    Profile? profile;
    for (int i = 0; i < widget.chatroom.connectedPersons.length; i++) {
      if (widget.chatroom.connectedPersons[i].getPhoneNumber ==
          widget.myphoneno) {
        profile = widget.chatroom.connectedPersons[i];
      }
    }
    widget.chatroom.connectedPersons.remove(profile);
    await Database.updateparticipants(
        FirebaseAuth.instance.currentUser!.uid, widget.chatroom.id, false);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    context.pop("pop");
  }

  void deletegroup() async {
    EasyLoading.show(status: "deleting");
    Toast("deleting group...");
    await Database.deletechatroom(widget.chatroom, isItGroup: true);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    context.pop("pop");
  }
}
