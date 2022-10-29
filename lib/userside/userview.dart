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
import 'package:chatty/assets/common/widgets/textfield_material.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/firebaseuser.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/constants/profile_operations.dart';
import 'package:chatty/firebase/auth/firebase_auth.dart';
import 'package:chatty/userside/chatroom_activity.dart';
import 'package:chatty/userside/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
              onPressed: () async {
                floatingbuttonaction();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
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
          ending: PopupMenuButton(
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
                  EasyLoading.show(status: "refreshing");
                  await Database.retrivechatrooms(uid: auth.currentUser!.uid)
                      .then((value) {
                    chatrooms = value ?? [];
                    EasyLoading.dismiss();
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
              child:
                  profile.getPhotourl == null || profile.getPhotourl == "null"
                      ? const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 176, 184, 250),
                          child: Icon(Icons.person,
                              color: MyColors.primarySwatch, size: 30),
                        )
                      : profilewidget(profile.getPhotourl!, 35),
            ),
          ),
          hintText: "search...",
          contentPadding: const EdgeInsets.only(bottom: 15, top: 15),
          controller: searchcontroller),
    );
  }

  Widget buildlistview(BuildContext context) {
    if (chatrooms.isEmpty) {
      return buildblankview("you are not connected to any chatgroups");
    }
    if (searchchatrooms.isEmpty && searchcontroller.text.isNotEmpty) {
      return buildblankview("we could not find the specified");
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
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
          description: currentchatroom.chats.isNotEmpty
              ? currentchatroom.getlatestchat().text
              : "",
        );
      },
          childCount: searchcontroller.text.isEmpty
              ? chatrooms.length
              : searchchatrooms.length),
    );
  }

  void setsearcheditems() {
    setState(() {
      searchchatrooms = [];
      if (searchcontroller.text.isEmpty) {
        return;
      }
      String title, description;
      String searchtext = searchcontroller.text.toLowerCase();
      for (int i = 0; i < chatrooms.length; i++) {
        title = getotherprofile(chatrooms[i].connectedPersons)
            .getName
            .toLowerCase();
        description = chatrooms[i].getlatestchat().text;
        if (title.contains(searchtext) || description.contains(searchtext)) {
          searchchatrooms.add(chatrooms[i]);
        }
      }
    });
  }

  void retrivechatrooms() {
    Database.retrivechatrooms(uid: auth.currentUser!.uid).then((value) {
      chatrooms = value ?? [];
      setState(() {});
      EasyLoading.dismiss();
      listentochatroomchanges();
    });
  }

  void init() {
    getpersonalinfo(auth.currentUser!.uid).then((value) {
      snapshot = value;
      profile = Profile.fromMap(data: snapshot!);
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
    String phone = "";
    String? result;
    await showdialog(
        context,
        const Text("add chatroom"),
        textfieldmaterial(
          keyboardtype: TextInputType.number,
          label: "phoneno",
          onchanged: (value) {
            phone = value;
          },
          maxlength: 10,
        ),
        [
          alertdialogactionbutton("add", () async {
            if (phone.length < 10) return;
            EasyLoading.show(status: "searching");
            result = await Database.getuid(phone);
            EasyLoading.dismiss();
            if (!mounted) return;
            Navigator.of(context).pop();
          }),
          alertdialogactionbutton("cancel", () {
            Navigator.of(context).pop(false);
          }),
        ]);
    if (!mounted) return;
    if (result != null) {
      if (phone == profile.getPhoneNumber) {
        showbasicdialog(
          context,
          "forbidden",
          "you cannot add your own phone no",
        );
        return;
      }
      await showbasicdialog(
        context,
        "added",
        "given phone number was added successfully !",
      );
      addchatroom(phone);
    } else {
      if (phone.length < 10) return;
      showbasicdialog(
        context,
        "failed",
        "given number doesnt exist yet !!",
      );
    }
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

  void addchatroom(String phone) async {
    // checks if the chatroom exist already
    for (int i = 0; i < chatrooms.length; i++) {
      if (phone ==
          getotherprofile(
            chatrooms[i].connectedPersons,
          ).getPhoneNumber) {
        return;
      }
    }

    // get personal info like email, name by uid
    String uid = await Database.getuid(phone) ?? "";
    late Profile otherprofile;
    await getpersonalinfo(uid).then((value) {
      otherprofile = Profile.fromMap(data: value);
    });
    ChatRoom chatRoom = ChatRoom(
      connectedPersons: [otherprofile, profile],
      chats: [],
    );
    setState(() => chatrooms.add(chatRoom));
    await Database.writechatroom(chatRoom);
    listentochatroomchanges();
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
        Database.refreshchatroom(event.data()!, chatrooms.first.chats)
            .then((value) {
          chatrooms.first.chats = value;
          if (chatrooms.first.chats.isEmpty) return;
          log("updated value at chatroom = ${chatrooms[i].id} is ${chatrooms[i].chats.last}");
          if (mounted) setState(() {});
        });
      });
    }
  }
}
