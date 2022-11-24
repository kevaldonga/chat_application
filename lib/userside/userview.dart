import 'dart:async';
import 'dart:developer';

import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:chatty/assets/common/widgets/alertdialog.dart';
import 'package:chatty/assets/common/widgets/alertdialog_action_button.dart';
import 'package:chatty/assets/common/widgets/chatroomitem.dart';
import 'package:chatty/assets/common/widgets/getprofilewidget.dart';
import 'package:chatty/assets/common/widgets/popupmenuitem.dart';
import 'package:chatty/assets/common/widgets/textfield_main.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/firebaseuser.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/constants/profile_operations.dart';
import 'package:chatty/firebase/auth/firebase_auth.dart';
import 'package:chatty/userside/chatroom_activity.dart';
import 'package:chatty/userside/fabactions.dart';
import 'package:chatty/userside/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../assets/common/widgets/chatroomitem_shimmer.dart';
import '../firebase/database/my_database.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  TextEditingController searchcontroller = TextEditingController();
  late FirebaseAuth auth;
  late Profile profile;
  late FirebaseUser user;
  bool initialized = false;
  List<ChatRoom> chatrooms = [];
  List<ChatRoom> searchchatrooms = [];
  Map<String, dynamic>? snapshot;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? listener;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    init();
    super.initState();
  }

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    ThemeData theme = Theme.of(context);
    if (snapshot == null) {
      EasyLoading.show();
    }
    return snapshot == null
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
            child: Container())
        : Scaffold(
            extendBodyBehindAppBar: true,
            floatingActionButton: FloatingActionButton(
              backgroundColor: MyColors.textfieldborder2,
              foregroundColor: Colors.white,
              focusColor: const Color.fromARGB(255, 111, 119, 207),
              splashColor: const Color.fromARGB(255, 83, 93, 208),
              onPressed: () {
                floatingbuttonaction();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.message_rounded),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
                statusBarColor: Colors.transparent,
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SizedBox(
              width: md.size.width,
              height: md.size.height,
              child: CustomScrollView(
                physics:
                    !initialized ? const NeverScrollableScrollPhysics() : null,
                shrinkWrap: true,
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: md.padding.top)),
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: topsearchbar(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  buildlistview(context),
                ],
              ),
            ),
            extendBody: true,
          );
  }

  SizedBox topsearchbar(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextFieldmain(
          onchanged: () {
            setsearcheditems();
          },
          leading: const Icon(
            Icons.search_rounded,
            color: MyColors.textsecondary,
          ),
          ending: popupmenu(context),
          hintText: "search...",
          contentPadding: const EdgeInsets.only(bottom: 15, top: 15),
          controller: searchcontroller),
    );
  }

  PopupMenuButton<dynamic> popupmenu(BuildContext context) {
    return PopupMenuButton(
      clipBehavior: Clip.antiAlias,
      splashRadius: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      enabled: true,
      itemBuilder: (context) {
        return [
          popupMenuItem(
              value: Profileop.myprofile,
              height: 20,
              child: Row(
                children: const [
                  Icon(Icons.person, color: MyColors.seconadaryswatch),
                  SizedBox(width: 30),
                  Text("profile")
                ],
              )),
          popupMenuItem(
              value: Profileop.refresh,
              height: 20,
              child: Row(
                children: const [
                  Icon(Icons.refresh, color: MyColors.seconadaryswatch),
                  SizedBox(width: 30),
                  Text("refresh")
                ],
              )),
          popupMenuItem(
              value: Profileop.updatepassword,
              height: 20,
              child: Row(
                children: const [
                  Icon(Icons.password_rounded,
                      color: MyColors.seconadaryswatch),
                  SizedBox(width: 30),
                  Text("update password")
                ],
              )),
          popupMenuItem(
              value: Profileop.verify,
              height: 20,
              child: Row(
                children: [
                  Icon(Icons.verified,
                      color: auth.currentUser!.emailVerified
                          ? Colors.green
                          : MyColors.textprimary),
                  const SizedBox(width: 30),
                  Text(auth.currentUser!.emailVerified
                      ? "verified"
                      : "verify yourself"),
                ],
              )),
          popupMenuItem(
              value: Profileop.signout,
              height: 20,
              child: Row(
                children: const [
                  Icon(Icons.logout, color: MyColors.seconadaryswatch),
                  SizedBox(width: 30),
                  Text("sign out"),
                ],
              )),
        ];
      },
      onSelected: (value) async {
        switch (value) {
          case Profileop.myprofile:
            if (listener != null) listener!.pause();
            profile = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return MyProfile(profile: profile);
            }));
            if (listener != null) listener!.cancel();
            setState(() {});
            break;

          case Profileop.refresh:
            initialized = false;
            await Database.retrivechatrooms(uid: auth.currentUser!.uid)
                .then((value) {
              chatrooms = value ?? [];
              initialized = true;
              if (!mounted) return;
              setState(() {});
            });
            await AuthFirebase.refresh();
            break;
          case Profileop.verify:
            if (auth.currentUser!.emailVerified) {
              showbasicdialog(
                  context, "verified", "you are already verified !!");
              return;
            }
            await showbasicdialog(context, "are you sure ?",
                "you will sent link to verify your email");
            await AuthFirebase.verify();
            break;
          case Profileop.updatepassword:
            break;
          case Profileop.signout:
            bool yousure = await showdialog(
                context,
                const Text("Are you sure ?"),
                const Text("Are you sure you want to sign out ? "), [
              alertdialogactionbutton("go back", () {
                Navigator.of(context).pop(false);
              }),
              alertdialogactionbutton("yes", () {
                Navigator.of(context).pop(true);
              }),
            ]);
            if (yousure) {
              if (listener != null) listener!.cancel();
              await AuthFirebase.signout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.loginview, (_) => false);
            }
        }
      },
      child: Center(
        child: profile.getPhotourl == null || profile.getPhotourl == "null"
            ? const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 176, 184, 250),
                child:
                    Icon(Icons.person, color: MyColors.primarySwatch, size: 30),
              )
            : profilewidget(profile.getPhotourl!, 35),
      ),
    );
  }

  Widget buildlistview(BuildContext context) {
    if (chatrooms.isEmpty && initialized) {
      return buildblankview("you are not connected to any chatgroups");
    }
    if (searchchatrooms.isEmpty && searchcontroller.text.isNotEmpty) {
      return buildblankview("we could not find the specified");
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: initialized
            ? searchcontroller.text.isEmpty
                ? chatrooms.length
                : searchchatrooms.length
            : 10,
        (context, index) {
          if (!initialized) {
            return ShimmerChatRoomItem();
          }
          ChatRoom currentchatroom = searchcontroller.text.isEmpty
              ? chatrooms[index]
              : searchchatrooms[index];
          currentchatroom.sortchats();
          String myphoneno = profile.getPhoneNumber;
          bool? isread = currentchatroom.chats.isNotEmpty
              ? currentchatroom.chats.last.sentFrom == myphoneno
                  ? currentchatroom.chats.last.isread
                  : null
              : null;
          return ChatRoomItem(
            id: chatrooms[index].id,
            url: getotherprofile(currentchatroom.connectedPersons).getPhotourl,
            top: index == 0 ? true : null,
            notificationcount: isread == null
                ? currentchatroom.getnotificationcount(myphoneno: myphoneno)
                : 0,
            read: isread,
            searchcontroller: searchcontroller,
            ontap: () => ontap(index),
            date: currentchatroom.chats.isNotEmpty
                ? currentchatroom.sortchats().last.time
                : null,
            title: getotherprofile(currentchatroom.connectedPersons).getName,
            description: getcurrentchatroomdescription(currentchatroom),
          );
        },
      ),
    );
  }

  void setsearcheditems() {
    setState(() {
      searchchatrooms = [];
      if (searchcontroller.text.isEmpty) {
        return;
      }
      String title;
      String searchtext = searchcontroller.text.toLowerCase();
      for (int i = 0; i < chatrooms.length; i++) {
        title = getotherprofile(chatrooms[i].connectedPersons)
            .getName
            .toLowerCase();
        if (title.contains(searchtext)) {
          searchchatrooms.add(chatrooms[i]);
        }
      }
    });
  }

  void retrivechatrooms() {
    Database.retrivechatrooms(uid: auth.currentUser!.uid).then((value) {
      chatrooms = value ?? [];
      initialized = true;
      setState(() {});
      listentochatroomchanges();
    });
  }

  void init() {
    getpersonalinfo(auth.currentUser!.uid).then((value) {
      EasyLoading.dismiss();
      snapshot = value;
      profile = Profile.fromMap(data: snapshot!);
      setState(() {});
      retrivechatrooms();
    });
  }

  void ontap(int index) async {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    if (listener != null) listener!.pause();
    chatrooms[index] =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatRoomActivity(chatroom: chatrooms[index]);
    }));
    if (listener != null) listener!.resume();
    setState(() {});
  }

  void floatingbuttonaction() async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return FabActions(profile, chatrooms);
      },
    )).then((newchatroom) {
      if (newchatroom == null) {
        return;
      }
      setState(() => chatrooms.add(newchatroom));
      listentochatroomchanges();
    });
  }

  Profile getotherprofile(List<Profile> profiles) {
    String? myemail = auth.currentUser?.email;
    for (int i = 0; i < profiles.length; i++) {
      if (myemail != profiles[i].getEmail) {
        return profiles[i];
      }
    }
    throw Error();
  }

  Widget buildblankview(String title) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Text(
            textAlign: TextAlign.center,
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  void intializechatrooms(Map<String, dynamic> snapshot) async {
    chatrooms = await Database.retrivechatrooms(
          uid: auth.currentUser!.uid,
          snapshot: snapshot,
        ) ??
        [];
  }

  void listentochatroomchanges() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    for (int i = 0; i < chatrooms.length; i++) {
      listener = db
          .collection("chatrooms")
          .doc(chatrooms[i].id)
          .snapshots()
          .listen((event) {
        Database.refreshchatroom(event.data()!, chatrooms[i].chats)
            .then((value) {
          chatrooms[i].chats = value;
          if (chatrooms[i].chats.isEmpty) return;
          log("updated value at chatroom = ${chatrooms[i].id} is ${chatrooms[i].chats.last}");
          if (mounted) setState(() {});
        });
      });
    }
  }

  String getcurrentchatroomdescription(ChatRoom currentchatroom) {
    if (currentchatroom.chats.isEmpty) {
      return "";
    }
    if (currentchatroom.getlatestchat().text == null ||
        currentchatroom.getlatestchat().text == "") {
      return currentchatroom.getlatestchat().filename == null ? "🖼️" : "📄";
    } else {
      return (currentchatroom.getlatestchat().url != null ? "🖼️  " : "") +
          currentchatroom.getlatestchat().text!;
    }
  }
}
