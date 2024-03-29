import 'package:chatty/global/SystemChannels/toast.dart';
import 'package:chatty/global/variables/colors.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/global/widgets/alertdialog.dart';
import 'package:chatty/global/widgets/alertdialog_button.dart';
import 'package:chatty/userside/profiles/widgets/chatroom_media.dart';
import 'package:chatty/userside/profiles/widgets/commongrouplist.dart';
import 'package:chatty/userside/profiles/widgets/mediavisibility.dart';
import 'package:chatty/utils/chat.dart';
import 'package:chatty/utils/chatroom.dart';
import 'package:chatty/utils/firebase_user.dart';
import 'package:chatty/utils/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../global/SystemChannels/intent.dart' as intent;
import '../../dashview/widgets/popupmenuitem.dart';
import '../widgets/animatedappbar.dart';
import '../widgets/bio.dart';

enum OP {
  deletechatroom,
}

class UserProfile extends StatefulWidget {
  final String chatroomid;
  final Profile myprofile;
  final Profile profile;
  final List<Chat> chats;
  final Map<String, String> sentData;
  final FirebaseUser user;
  final Map<String, bool> blockedby;

  const UserProfile({
    Key? key,
    required this.blockedby,
    required this.chatroomid,
    required this.myprofile,
    required this.user,
    required this.sentData,
    required this.chats,
    required this.profile,
  }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late MediaQueryData md;
  late bool amiblocked;
  late bool didiblock;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    didiblock = widget.blockedby[widget.myprofile.getPhoneNumber] ?? false;
    amiblocked = widget.blockedby[widget.profile.getPhoneNumber] ?? false;
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
                  delegate: CustomAppbar(
                    items: [
                      popupMenuItem(
                          value: OP.deletechatroom,
                          height: 20,
                          child: const Row(
                            children: [
                              Icon(Icons.delete_forever,
                                  color: Colors.redAccent),
                              SizedBox(width: 30),
                              Text("delete chatroom"),
                            ],
                          )),
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case OP.deletechatroom:
                          bool yousure = await showdialog(
                            context: context,
                            title: const Text("Are you sure ?"),
                            contents: const Text(
                                "It will delete whole chatroom including media and chats, and you wont be able to get them back !!"),
                            actions: [
                              AlertDialogButton(
                                  text: "YES",
                                  callback: () {
                                    context.pop(true);
                                  }),
                              AlertDialogButton(
                                  text: "CANCEL",
                                  callback: () {
                                    context.pop(false);
                                  })
                            ],
                          );
                          if (yousure) {
                            EasyLoading.show(status: "deleting...");
                            ChatRoom? chatroom = await Database.readchatroom(
                                id: widget.chatroomid,
                                myprofile: widget.myprofile);
                            Database.deletechatroom(chatroom!);
                            EasyLoading.dismiss();
                            if (!context.mounted) return;
                            context.pop("deleted");
                          }
                          break;
                      }
                    },
                    isitgroup: false,
                    herotag: widget.chatroomid,
                    name: widget.profile.getName,
                    screenWidth: MediaQuery.of(context).size.width,
                    url: widget.profile.photourl,
                    onbackpressed: () {
                      onbackpressed(context);
                    },
                  ),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PhoneAndName(
                          description: widget.profile.getPhoneNumber,
                          name: widget.profile.getName),
                      profileOperations(context),
                      bioWidget(
                          bio: widget.profile.bio,
                          name: widget.profile.getName),
                      MediaVisibility(
                        id: widget.chatroomid,
                        user: widget.user,
                      ),
                    ],
                  ),
                ),
                if (widget.chats.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ChatroomMedia(
                      sentdata: widget.sentData,
                      chats: widget.chats,
                      height: md.size.height * 0.13,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: CommonGroupList(
                    phonenos: [
                      widget.myprofile.getPhoneNumber,
                      widget.profile.getPhoneNumber
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: md.size.height * 0.4),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profileOperations(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        profileoperationWidget(
          icon: Icons.call_rounded,
          label: "call",
          backgroundcolor: Colors.green,
          onclick: () async {
            bool isGranted = await Permission.phone.request().isGranted;
            if (isGranted) {
              intent.Intent.call(widget.profile.getPhoneNumber);
            } else {
              Toast("allow permission to use this functionality");
            }
          },
        ),
        profileoperationWidget(
          icon: Icons.chat_rounded,
          label: "chat",
          backgroundcolor: MyColors.primarySwatch,
          onclick: () {
            context.pop();
          },
        ),
        profileoperationWidget(
          icon: didiblock ? Icons.done_rounded : Icons.block_rounded,
          label: didiblock
              ? "unblock"
              : amiblocked
                  ? "blocked"
                  : "block",
          backgroundcolor: didiblock ? Colors.green : Colors.red,
          onclick: () async {
            if (amiblocked) {
              return;
            }
            if (!(widget.blockedby[widget.myprofile.getPhoneNumber] ?? false)) {
              // block
              widget.blockedby[widget.myprofile.getPhoneNumber] = true;
              EasyLoading.show(status: "blocking");
              await Database.updateblockedby(
                  widget.chatroomid, widget.blockedby);
              EasyLoading.dismiss();
              Toast("user blocked !!");
            } else {
              // unblock
              widget.blockedby[widget.myprofile.getPhoneNumber] = false;
              EasyLoading.show(status: "unblocking");
              await Database.updateblockedby(
                  widget.chatroomid, widget.blockedby);
              EasyLoading.dismiss();
              Toast("user unblocked !!");
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget profileoperationWidget({
    required IconData icon,
    required String label,
    required Color backgroundcolor,
    required VoidCallback onclick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Container(
            color: backgroundcolor,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.white54,
                onTap: onclick,
                child: SizedBox(
                  height: md.size.width * 0.13,
                  width: md.size.width * 0.13,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void onbackpressed(BuildContext context) {
    context.pop({"firebaseuser": widget.user, "blockedby": widget.blockedby});
  }
}
