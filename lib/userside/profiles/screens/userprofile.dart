import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/logic/FirebaseUser.dart';
import 'package:chatty/assets/logic/chat.dart';
import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/userside/profiles/common/widgets/chatroom_media.dart';
import 'package:chatty/userside/profiles/common/widgets/commongrouplist.dart';
import 'package:chatty/userside/profiles/common/widgets/mediavisibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../assets/logic/profile.dart';
import '../../../assets/SystemChannels/intent.dart' as intent;
import '../common/widgets/animatedappbar.dart';
import '../common/widgets/bio.dart';

class UserProfile extends StatelessWidget {
  String chatroomid;
  final String myphoneno;
  final Profile profile;
  final List<Chat> chats;
  final Map<String, String> sentData;
  FirebaseUser user;
  late MediaQueryData md;

  UserProfile({
    Key? key,
    required this.chatroomid,
    required this.myphoneno,
    required this.user,
    required this.sentData,
    required this.chats,
    required this.profile,
  }) : super(key: key);

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
                  delegate: CustomAppbar(
                    isitgroup: false,
                    herotag: chatroomid,
                    name: profile.getName,
                    screenWidth: MediaQuery.of(context).size.width,
                    url: profile.photourl,
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
                          description: profile.getPhoneNumber,
                          name: profile.getName),
                      profileOperations(context),
                      bioWidget(bio: profile.bio, name: profile.getName),
                      MediaVisibility(
                        id: chatroomid,
                        user: user,
                      ),
                    ],
                  ),
                ),
                if (chats.isNotEmpty)
                  SliverToBoxAdapter(
                    child: ChatroomMedia(
                      sentdata: sentData,
                      chats: chats,
                      height: md.size.height * 0.13,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: CommonGroupList(
                    phonenos: [myphoneno, profile.getPhoneNumber],
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
              intent.Intent.call(profile.getPhoneNumber);
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
            Navigator.pop(context);
          },
        ),
        profileoperationWidget(
          icon: Icons.block_rounded,
          label: "block",
          backgroundcolor: Colors.red,
          onclick: () {},
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
    Navigator.of(context).pop({"firebaseuser": user});
  }
}
