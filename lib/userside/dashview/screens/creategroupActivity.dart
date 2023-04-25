import 'dart:io';

import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/logic/groupInfo.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/profiles/common/functions/setprofileimage.dart';
import 'package:chatty/userside/profiles/common/widgets/getprofilecircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../assets/SystemChannels/picker.dart';
import '../../../assets/logic/chatroom.dart';
import '../../../assets/logic/profile.dart';
import '../../profiles/common/functions/compressimage.dart';
import '../../profiles/common/widgets/buildcircle.dart';

enum MemberType {
  admin,
  rookie,
}

class CreateGroup extends StatefulWidget {
  final List<Profile> users;
  final List<Profile> admins;

  const CreateGroup({
    super.key,
    required this.users,
    required this.admins,
  });

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  FirebaseAuth auth = FirebaseAuth.instance;
  int focusedindex = 0;
  File? file;
  late MediaQueryData md;
  TextEditingController groupname = TextEditingController();
  ScrollController scrollcontroller = ScrollController();
  FocusNode nodegroupname = FocusNode();
  TextEditingController groupdescription = TextEditingController();
  FocusNode nodegroupdes = FocusNode();

  @override
  void initState() {
    super.initState();
    nodegroupname.addListener(() {
      if (nodegroupname.hasFocus) {
        setState(() {
          focusedindex = 1;
        });
      }
    });
    nodegroupdes.addListener(() {
      if (nodegroupdes.hasFocus) {
        setState(() {
          focusedindex = 2;
        });
      }
    });
  }

  @override
  void dispose() {
    nodegroupname.dispose();
    nodegroupdes.dispose();
    groupname.dispose();
    groupdescription.dispose();
    scrollcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Theme(
        data: ThemeData(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: Colors.transparent)),
        child: FloatingActionButton.extended(
          isExtended: true,
          icon: const Icon(Icons.add_rounded),
          label: const Text("Create"),
          backgroundColor: MyColors.primarySwatch,
          focusColor: Colors.transparent,
          foregroundColor: Colors.white,
          splashColor: const Color.fromARGB(255, 105, 103, 208),
          onPressed: () {
            if (groupname.text.isEmpty) {
              Toast("group must have a name");
              return;
            }
            creategroup();
          },
        ),
      ),
      appBar: AppBar(
        title: const Text(
          "New Group",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: MyColors.primarySwatch,
        leading: IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.white38,
          splashRadius: 30,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: md.size.height,
          padding: EdgeInsets.symmetric(horizontal: md.size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: md.size.height * 0.05,
                ),
                child: profilerow(),
              ),
              // group description
              Padding(
                padding: EdgeInsets.symmetric(vertical: md.size.height * 0.02),
                child: description(),
              ),
              const Text(
                "Admins",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: md.size.height * 0.02),
                child: adminslist(),
              ),
              participantslist(),
            ],
          ),
        ),
      ),
    );
  }

  AnimatedContainer description() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
            color: focusedindex == 2
                ? MyColors.primarySwatch
                : MyColors.textprimary,
            width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        focusNode: nodegroupdes,
        controller: groupdescription,
        maxLines: 10,
        maxLength: 50,
        decoration: const InputDecoration(
          contentPadding:
              EdgeInsets.only(left: 15, top: 15, bottom: 15, right: 15),
          hintText: "Group description",
        ),
      ),
    );
  }

  Row profilerow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // profile
        Flexible(
          flex: 5,
          fit: FlexFit.loose,
          child: _profilewidget(md),
        ),
        // group name
        Flexible(
          flex: 15,
          fit: FlexFit.tight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: focusedindex == 1
                      ? MyColors.primarySwatch
                      : MyColors.textprimary,
                  width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              focusNode: nodegroupname,
              controller: groupname,
              maxLength: 20,
              maxLines: 1,
              decoration: const InputDecoration(
                isCollapsed: true,
                contentPadding: EdgeInsets.only(left: 20, top: 20, right: 5),
                hintText: "Group name",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profilewidget(MediaQueryData md) {
    return GestureDetector(
      onTap: () async {
        Picker picker = Picker(onResult: (value) async {
          if (value == null) {
            return;
          }
          file = await compressimage(value, 80);
        });
        picker.pickimage();
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildimage(md),
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildcircle(
              color: Colors.white,
              padding: 4,
              child: _buildcircle(
                color: MyColors.primarySwatch,
                padding: 10,
                child: const Icon(Icons.edit, size: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildimage(MediaQueryData md) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        width: md.size.width * 0.2,
        height: md.size.width * 0.2,
        child: file == null
            ? const CircleAvatar(
                backgroundColor: MyColors.profilebackground,
                child: Icon(Icons.groups_rounded,
                    size: 50, color: MyColors.profileforeground),
              )
            : Image.file(file!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildcircle(
      {required color, required double padding, Widget? child}) {
    return ClipOval(
      child: Container(
        color: color,
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }

  Widget adminslist() {
    return SingleChildScrollView(
      controller: scrollcontroller,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.admins.length, (index) {
          return adminitem(widget.admins[index]);
        }),
      ),
    );
  }

  Widget participantslist() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: MyColors.primarySwatch,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints.loose(
          Size.fromHeight(md.size.height * 0.27),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.users.length, (index) {
                return participantsitem(widget.users[index]);
              })),
        ),
      ),
    );
  }

  Widget adminitem(Profile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: md.size.width * 0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.users.add(profile);
                widget.admins.remove(profile);
              });
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                profilewidget(profile.photourl, md.size.width * 0.1, false),
                // check if its me or not
                if (profile.getEmail != auth.currentUser!.email)
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: buildcircle(
                        color: Colors.white,
                        padding: 2,
                        child: buildcircle(
                            padding: 6,
                            color: Colors.red,
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 12)),
                      )),
              ],
            ),
          ),
          Text(
            profile.getName,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  Widget participantsitem(Profile profile) {
    return GestureDetector(
      onTap: () {
        setState(() {
          scrolltoend();
          widget.admins.add(profile);
          widget.users.remove(profile);
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child:
                  profilewidget(profile.photourl, md.size.width * 0.12, false),
            ),
            Flexible(
              flex: 8,
              fit: FlexFit.tight,
              child: Text(profile.getName),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: ClipOval(
                child: Container(
                  color: Colors.green,
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrolltoend() {
    if (!scrollcontroller.hasClients) {
      return;
    }
    scrollcontroller.animateTo(
      scrollcontroller.position.maxScrollExtent + 150,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void creategroup() async {
    EasyLoading.show(status: "creating");
    String? url;
    if (file != null) {
      url = await setuserprofile(file!);
    }
    ChatRoom chatroom = ChatRoom(
      blockedby: {},
      connectedPersons: widget.admins + widget.users,
      chats: [],
      groupinfo: GroupInfo(
          photourl: url,
          name: groupname.text,
          bio: groupdescription.text,
          admins: getadminsphoneno()),
    );
    Database.writechatroom(chatroom).whenComplete(() {
      EasyLoading.dismiss();
      Toast("Group created succussfully!!");
      Navigator.of(context).pop(chatroom);
    });
  }

  List<String> getadminsphoneno() {
    List<String> phonenos = [];
    for (int i = 0; i < widget.admins.length; i++) {
      phonenos.add(widget.admins[i].getPhoneNumber);
    }
    return phonenos;
  }
}
