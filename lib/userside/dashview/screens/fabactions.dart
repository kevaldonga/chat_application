import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/logic/FirebaseUser.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../assets/alertdialog/alertdialog.dart';
import '../../../assets/alertdialog/alertdialog_action_button.dart';
import '../../../assets/alertdialog/textfield_material.dart';
import '../../../assets/logic/profile.dart';
import '../../../firebase/database/my_database.dart';
import '../../chatroom/screens/chatroom_activity.dart';
import '../../profiles/common/widgets/getprofilecircle.dart';
import 'creategroupActivity.dart';

class FabActions extends StatefulWidget {
  List<ChatRoom> chatrooms;
  Profile profile;
  FirebaseUser user;
  FabActions(this.profile, this.chatrooms, this.user, {super.key});

  @override
  State<FabActions> createState() => _FabActionsState();
}

class _FabActionsState extends State<FabActions> {
  late MediaQueryData md;
  late int chatroomlength = 0;
  List<Profile> profiles = [];
  List<Profile> selectedprofiles = [];
  bool selection = false;

  @override
  void initState() {
    super.initState();
    getchatroomslength();
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.white38,
          splashRadius: 30,
          icon: Icon(
            !selection ? Icons.arrow_back_rounded : Icons.close_rounded,
          ),
          onPressed: () {
            if (!selection) {
              Navigator.pop(context);
            } else {
              setState(() {
                selection = false;
                selectedprofiles = [];
              });
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              !selection
                  ? "Select contact"
                  : "${selectedprofiles.length} contacts selected",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
            Text(
              "$chatroomlength contacts",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          // create group
          extraTopItems(
            icon: Icons.group_add_rounded,
            text: "New group",
            ontap: createGroup,
          ),
          // add chatroom
          extraTopItems(
            icon: Icons.person_add_alt_rounded,
            text: "New chatroom",
            ontap: createChatRoom,
          ),
          ...List.generate(profiles.length, (index) {
            return item(profile: profiles[index]);
          }),
        ],
      ),
    );
  }

  void getchatroomslength() {
    for (int i = 0; i < widget.chatrooms.length; i++) {
      if (!widget.chatrooms[i].isitgroup) {
        chatroomlength++;
        profiles.add(getotherprofile(widget.chatrooms[i].connectedPersons));
      }
    }
    profiles.sort(
      (a, b) {
        return a.getName.compareTo(b.getName);
      },
    );
  }

  Widget item({required Profile profile}) {
    return InkWell(
      highlightColor: Colors.transparent,
      onTap: () {
        if (selection) {
          if (selectedprofiles.contains(profile)) {
            setState(() {
              selectedprofiles.remove(profile);
              if (selectedprofiles.isEmpty) {
                selection = false;
              }
            });
            return;
          }
          setState(() {
            selection = true;
            selectedprofiles.add(profile);
          });
        } else {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return ChatRoomActivity(
                  chatroom: getchatroom(profile), user: widget.user);
            },
          ));
        }
      },
      onLongPress: () {
        if (selectedprofiles.contains(profile)) {
          setState(() {
            selectedprofiles.remove(profile);
            if (selectedprofiles.isEmpty) {
              selection = false;
            }
          });
          return;
        }
        setState(() {
          selection = true;
          selectedprofiles.add(profile);
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        width: md.size.width,
        child: Row(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                profile.photourl == "null" || profile.photourl == null
                    ? const CircleAvatar(
                        backgroundColor: MyColors.profilebackground,
                        child: Icon(Icons.person_rounded,
                            color: MyColors.profileforeground),
                      )
                    : profilewidget(
                        profile.photourl!, md.size.width * 0.1, false),
                AnimatedOpacity(
                  opacity: selectedprofiles.contains(profile) ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: ClipOval(
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      color: Colors.white,
                      child: ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          color: MyColors.primarySwatch,
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: md.size.width * 0.07),
            Text(
              profile.getName,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  void createGroup() async {
    if (selectedprofiles.length < 2) {
      showbasicdialog(context, "Select more than 1 people",
          "You have to select more than 1 people to create a group");
      return;
    }
    ChatRoom? chatroom = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateGroup(
            users: selectedprofiles,
            admins: [widget.profile],
          ),
        ));
    if (chatroom != null) {
      if (!mounted) return;
      Navigator.of(context).pop(chatroom);
    }
  }

  void createChatRoom() async {
    String phone = "";
    String? result;
    bool? response = await showdialog(
        context: context,
        title: const Text("add chatroom"),
        contents: textfieldmaterial(
          keyboardtype: TextInputType.number,
          label: "phoneno",
          onchanged: (value) {
            phone = value;
          },
          maxlength: 10,
        ),
        actions: [
          alertdialogactionbutton("ADD", () async {
            if (phone.length < 10) {
              Toast("too short!!");
              return;
            }
            EasyLoading.show(status: "searching");
            result = await Database.getuid(phone);
            EasyLoading.dismiss();
            if (!mounted) return;
            Navigator.of(context).pop(true);
          }),
          alertdialogactionbutton("CANCEL", () {
            Navigator.of(context).pop(false);
          }),
        ]);
    if (!mounted) return;
    if (result != null && response) {
      if (phone == widget.profile.getPhoneNumber) {
        Toast("you can't add your own number!");
        return;
      }
      Toast("chatroom added successfully!");
      addchatroom(phone);
    } else {
      if (phone.length < 10) return;
      Toast("given number doesn't exist!!");
    }
  }

  Widget extraTopItems(
      {required IconData icon,
      required String text,
      required VoidCallback ontap}) {
    return InkWell(
      highlightColor: Colors.transparent,
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: md.size.width * 0.1,
                height: md.size.width * 0.1,
                color: MyColors.seconadaryswatch,
                child: Icon(icon, color: Colors.white),
              ),
            ),
            SizedBox(width: md.size.width * 0.07),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ChatRoom getchatroom(Profile profile) {
    for (int i = 0; i < widget.chatrooms.length; i++) {
      for (int j = 0; j < widget.chatrooms[i].connectedPersons.length; j++) {
        if (widget.chatrooms[i].connectedPersons[j].getPhoneNumber ==
            profile.getPhoneNumber) {
          return widget.chatrooms[i];
        }
      }
    }
    throw Error();
  }

  void addchatroom(String phone) async {
    // checks if the chatroom exist already
    for (int i = 0; i < widget.chatrooms.length; i++) {
      if (phone ==
          getotherprofile(
            widget.chatrooms[i].connectedPersons,
          ).getPhoneNumber) {
        return;
      }
    }
    // get personal info like email, name by uid
    String? uid = await Database.getuid(phone);
    if (uid == null) {
      Toast("chatroom doesn't exist !!");
    }
    late Profile otherprofile;
    await Database.getpersonalinfo(uid!).then((value) {
      otherprofile = value;
    });
    ChatRoom chatRoom = ChatRoom(
      blockedby: {},
      connectedPersons: [otherprofile, widget.profile],
      chats: [],
    );
    widget.user.mediavisibility[otherprofile.getEmail] = true;
    await Database.setmediavisibility(
        FirebaseAuth.instance.currentUser!.uid, widget.user);
    await Database.writechatroom(chatRoom).whenComplete(() {
      if (mounted) Navigator.of(context).pop(chatRoom);
    });
  }

  Profile getotherprofile(List<Profile> profiles) {
    String? myemail = FirebaseAuth.instance.currentUser?.email;
    for (int i = 0; i < profiles.length; i++) {
      if (myemail != profiles[i].getEmail) {
        return profiles[i];
      }
    }
    throw Error();
  }
}
