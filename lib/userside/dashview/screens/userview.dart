import 'dart:async';
import 'dart:developer';

import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/logic/FirebaseUser.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/auth/screens/login_view.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/constants/profile_operations.dart';
import 'package:chatty/firebase/auth/firebase_auth.dart';
import 'package:chatty/userside/profiles/screens/myprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../assets/alertdialog/alertdialog.dart';
import '../../../assets/alertdialog/alertdialog_action_button.dart';
import '../../../firebase/database/my_database.dart';
import '../../chatroom/screens/chatroom_activity.dart';
import '../../profiles/common/widgets/getprofilecircle.dart';
import '../common/widgets/chatroomitem.dart';
import '../common/widgets/chatroomitem_shimmer.dart';
import '../common/widgets/popupmenuitem.dart';
import '../common/widgets/textfield_main.dart';
import 'fabactions.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  TextEditingController searchcontroller = TextEditingController();
  late FirebaseAuth auth;
  Profile? profile;
  bool initialized = false;
  late FirebaseUser user;
  List<ChatRoom> chatrooms = [];
  List<ChatRoom> searchchatrooms = [];
  Map<String, dynamic>? snapshot;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? listener;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      addedtochatroom;
  late MediaQueryData md;

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
    md = MediaQuery.of(context);
    ThemeData theme = Theme.of(context);
    return profile == null
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
            floatingActionButton: Theme(
              data: ThemeData(
                  colorScheme: ColorScheme.fromSwatch()
                      .copyWith(secondary: Colors.transparent)),
              child: FloatingActionButton(
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
              value: Profileop.deleteaccount,
              height: 20,
              child: Row(
                children: const [
                  Icon(Icons.delete_forever, color: Colors.redAccent),
                  SizedBox(width: 30),
                  Text("delete account"),
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
            pauselisteners();
            profile = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return MyProfile(profile: profile!);
            }));
            resumelisteners();
            setState(() {});
            break;

          case Profileop.refresh:
            setState(() {
              initialized = false;
            });
            await AuthFirebase.refresh();
            setState(() {
              initialized = true;
            });
            break;
          case Profileop.verify:
            if (auth.currentUser!.emailVerified) {
              Toast("you are already verifed!");
              return;
            }
            Toast("sending link to verify!");
            await AuthFirebase.verify();
            break;
          case Profileop.updatepassword:
            String password = "";
            await showdialog(
              context: context,
              title: const Text("change password"),
              contents: TextField(
                autocorrect: false,
                obscureText: true,
                autofocus: true,
                enableSuggestions: false,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "New password",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                alertdialogactionbutton(
                  "change",
                  (() async {
                    if (password.isEmpty) {
                      Toast("too short");
                      return;
                    }
                    await auth.currentUser
                        ?.updatePassword(password)
                        .whenComplete(() {
                      Toast("your password has been updated !!");
                    });
                  }),
                ),
              ],
            );
            break;
          case Profileop.signout:
            bool yousure = await showdialog(
                context: context,
                title: const Text("Are you sure ?"),
                contents: const Text("Are you sure you want to sign out ? "),
                actions: [
                  alertdialogactionbutton("BACK", () {
                    Navigator.of(context).pop(false);
                  }),
                  alertdialogactionbutton("YES", () {
                    Navigator.of(context).pop(true);
                  }),
                ]);
            if (yousure) {
              cancellisteners();
              await AuthFirebase.signout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, Routes.loginview, (_) => false);
            }
            break;
          case Profileop.deleteaccount:
            String password = "";
            await showdialog(
              barrierDismissible: false,
              context: context,
              title: const Text("Are you sure ?"),
              contents: const Text(
                  "This is serious action to perform !! All your data will be deleted and you won't be able to get them back !!"),
              actions: [
                alertdialogactionbutton(
                  "AUTHENTICATE",
                  () async {
                    Toast(
                        "you have to reauthenticate to delete your account !");
                    Navigator.pop(context);
                    bool result = await showdialog(
                      context: context,
                      title: const Text("authenticate yourself"),
                      contents: Theme(
                        data: ThemeData(),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                autocorrect: false,
                                obscureText: true,
                                autofocus: true,
                                enableSuggestions: false,
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: "password",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        alertdialogactionbutton(
                          "REAUTHENTICATE",
                          () async {
                            if (password.length < 8) {
                              Toast("password is too short !!");
                              return;
                            }
                            try {
                              await auth.currentUser
                                  ?.reauthenticateWithCredential(
                                      EmailAuthProvider.credential(
                                          email: auth.currentUser!.email!,
                                          password: password));
                            } on FirebaseAuthException catch (e) {
                              if (e.code == "wrong-password") {
                                Toast("you have enterred wrong password");
                                Navigator.of(context).pop(false);
                              }
                              return;
                            }
                            Toast("reauthenticated");
                            if (!mounted) return;
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                    if (result) {
                      deleteAccount();
                    }
                  },
                ),
                alertdialogactionbutton("NEVERMIND", () {
                  Navigator.of(context).pop(false);
                }),
              ],
            );
        }
      },
      child: Center(child: profilewidget(profile!.photourl, 35, false)),
    );
  }

  Widget buildlistview(BuildContext context) {
    if (chatrooms.isEmpty && initialized) {
      return buildblankview("you are not connected to any chatrooms");
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
            return const ShimmerChatRoomItem();
          }
          ChatRoom currentchatroom = searchcontroller.text.isEmpty
              ? chatrooms[index]
              : searchchatrooms[index];
          currentchatroom.sortchats();
          String myphoneno = profile!.getPhoneNumber;
          bool? isread = currentchatroom.chats.isNotEmpty
              ? currentchatroom.chats.last.sentFrom == myphoneno
                  ? currentchatroom.chats.last.isread
                  : null
              : null;
          String? url = currentchatroom.isitgroup
              ? currentchatroom.groupinfo!.photourl
              : getotherprofile(currentchatroom.connectedPersons).photourl;
          String title = currentchatroom.isitgroup
              ? currentchatroom.groupinfo!.name
              : getotherprofile(currentchatroom.connectedPersons).getName;
          return ChatRoomItem(
            isitgroup: chatrooms[index].isitgroup,
            id: chatrooms[index].id,
            url: url,
            top: index == 0 ? true : null,
            notificationcount: currentchatroom.getnotificationcount(
                myphoneno: myphoneno, isread: isread),
            read: isread,
            searchcontroller: searchcontroller,
            ontap: () => ontap(index),
            date: currentchatroom.chats.isNotEmpty
                ? currentchatroom.sortchats().last.time
                : null,
            title: title,
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

  void init() {
    initfirebaseuser();
    Database.getpersonalinfo(auth.currentUser!.uid).then((value) {
      FlutterNativeSplash.remove();
      profile = value;
      setState(() {});
      listentoaddedtonewchatroom();
      listentochatroomchanges();
    });
  }

  void ontap(int index) async {
    FocusScope.of(context).requestFocus(FocusNode());
    pauselisteners();
    dynamic data =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatRoomActivity(
        chatroom: chatrooms[index],
        user: user,
      );
    }));
    if (data != null && data.runtimeType == ChatRoom) {
      chatrooms[index] = data;
    }
    if (data == "deleted") {
      chatrooms.removeAt(index);
    }
    sortbynotification();
    setState(() {});
    resumelisteners();
  }

  void floatingbuttonaction() async {
    pauselisteners();
    await Navigator.push(context, MaterialPageRoute<ChatRoom?>(
      builder: (context) {
        return FabActions(profile!, chatrooms, user);
      },
    )).then((newchatroom) {
      if (newchatroom == null) {
        return;
      }
      chatrooms.add(newchatroom);
      setState(() {});
      resumelisteners();
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
          sortbynotification();
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
      return currentchatroom.getlatestchat().fileinfo?.filename == null
          ? "🖼️"
          : "📄";
    } else {
      return (currentchatroom.getlatestchat().fileinfo?.url != null
              ? "🖼️  "
              : "") +
          currentchatroom.getlatestchat().text!;
    }
  }

  void initfirebaseuser() async {
    user = await Database.readMediavisibility(auth.currentUser!.uid);
  }

  void listentoaddedtonewchatroom() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    addedtochatroom = db
        .collection("connectedchatrooms")
        .doc(auth.currentUser!.uid)
        .snapshots()
        .listen((event) {
      Database.chatroomidsListener(event.data(), chatrooms, profile!)
          .then((value) {
        initialized = true;
        chatrooms = value;
        sortbynotification();
        setState(() {});
      });
    });
  }

  void sortbynotification() {
    chatrooms.sort(
      (a, b) {
        int fora = 0;
        int forb = 0;
        if (a.chats.isEmpty && b.chats.isEmpty) {
          return 0;
        }
        if (a.chats.isEmpty) {
          return 1;
        } else if (b.chats.isEmpty) {
          return -1;
        }

        fora = a.chats.last.sentFrom == profile!.getPhoneNumber
            ? 3
            : !a.chats.last.isread
                ? 2
                : 1;
        forb = b.chats.last.sentFrom == profile!.getPhoneNumber
            ? 3
            : !b.chats.last.isread
                ? 2
                : 1;
        if (fora == 2 && forb == 2) {
          return b
              .getnotificationcount(
                  myphoneno: profile!.getPhoneNumber, isread: false)
              .compareTo(
                a.getnotificationcount(
                    myphoneno: profile!.getPhoneNumber, isread: false),
              );
        }

        if (fora == 3 && forb == 3) {
          return b.chats.last.time.compareTo(a.chats.last.time);
        }
        return forb.compareTo(fora);
      },
    );
  }

  void resumelisteners() {
    if (listener == null) {
      listentochatroomchanges();
    }
    listener?.resume();
    addedtochatroom.resume();
  }

  void pauselisteners() {
    listener?.pause();
    addedtochatroom.resume();
  }

  void cancellisteners() {
    listener?.cancel();
    addedtochatroom.cancel();
  }

  void deleteAccount() async {
    // first of all we have to check if he is the only admin of any group or not
    for (int i = 0; i < chatrooms.length; i++) {
      if (chatrooms[i].isitgroup) {
        if (chatrooms[i].groupinfo!.admins.contains(profile!.getPhoneNumber) &&
            chatrooms[i].groupinfo!.admins.length == 1) {
          showbasicdialog(context, "Operation failed",
              "You are the only admin of some of the groups, so you have to either make someone admin or delete the group to proceed the operation !!");
          return;
        }
        if (chatrooms[i].connectedPersons.length == 2) {
          showbasicdialog(context, "Operation failed",
              "You are in some groups which can become invalid if you leave, leading to deleting group. make sure you leave those groups before proceeding !!");
          return;
        }
      }
    }
    EasyLoading.show(status: "deleting..", dismissOnTap: false);
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseStorage storage = FirebaseStorage.instance;

    // delete the chatrooms first
    for (int i = 0; i < chatrooms.length; i++) {
      if (chatrooms[i].isitgroup) {
        chatrooms[i].connectedPersons.remove(profile);
        await Database.updateparticipants(
            auth.currentUser!.uid, chatrooms[i].id, false);
      } else {
        await Database.deletechatroom(chatrooms[i], isItGroup: false);
      }
    }

    // then delete the user, status, userquickinfo, connectedchatrooms collections
    // user collecton
    await firestore.collection("users").doc(auth.currentUser!.uid).delete();
    // status
    await firestore.collection("status").doc(profile?.getPhoneNumber).delete();
    // userquickinfo
    await firestore
        .collection("userquickinfo")
        .doc(profile?.getPhoneNumber)
        .delete();
    // connectedchatrooms
    await firestore
        .collection("connectedchatrooms")
        .doc(auth.currentUser!.uid)
        .delete();
    // then delete the user account from firebase
    // with profile also
    if (profile?.photourl != null) {
      await storage.refFromURL(profile!.photourl!).delete();
    }
    await AuthFirebase.deleteAccount(profile!, uid: auth.currentUser!.uid);
    EasyLoading.dismiss();
    Toast("user has been deleted !!");
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (context) {
        return const LoginView();
      },
    ), (_) => false);
  }
}
