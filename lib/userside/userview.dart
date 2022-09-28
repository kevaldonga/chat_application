import 'dart:developer';

import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:chatty/assets/common/widgets/alertdialog.dart';
import 'package:chatty/assets/common/widgets/alertdialog_action_button.dart';
import 'package:chatty/assets/common/widgets/chatroomitem.dart';
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
  List<ChatRoom> items = [];
  List<ChatRoom> searchitems = [];
  Map<String, dynamic>? snapshot;

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
        ? Container()
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
                    title: SizedBox(
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
                            itemBuilder: (context) {
                              return [
                                popupMenuItem(
                                    value: Profileop.myprofile,
                                    height: 20,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.person,
                                            color: MyColors.seconadaryswatch),
                                        SizedBox(width: 30),
                                        Text("profile")
                                      ],
                                    )),
                                popupMenuItem(
                                    value: Profileop.refresh,
                                    height: 20,
                                    child: Row(
                                      children: const [
                                        Icon(Icons.refresh,
                                            color: MyColors.seconadaryswatch),
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
                                            color:
                                                auth.currentUser!.emailVerified
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
                                        Icon(Icons.logout,
                                            color: MyColors.seconadaryswatch),
                                        SizedBox(width: 30),
                                        Text("sign out"),
                                      ],
                                    )),
                              ];
                            },
                            onSelected: (value) async {
                              switch (value) {
                                case Profileop.myprofile:
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return MyProfile(profile: profile);
                                  }));
                                  setState(() {});
                                  break;

                                case Profileop.refresh:
                                  await AuthFirebase.refresh();
                                  break;
                                case Profileop.verify:
                                  await showbasicdialog(
                                      context,
                                      "are you sure ?",
                                      "you will sent link to verify your email");
                                  await AuthFirebase.verify();
                                  break;
                                case Profileop.updatepassword:
                                  break;
                                case Profileop.signout:
                                  bool yousure = await showdialog(
                                      context,
                                      const Text("Are you sure ?"),
                                      const Text(
                                          "Are you sure you want to sign out ? "),
                                      [
                                        alertdialogactionbutton("go back", () {
                                          Navigator.of(context).pop(false);
                                        }),
                                        alertdialogactionbutton("yes", () {
                                          Navigator.of(context).pop(true);
                                        }),
                                      ]);
                                  if (yousure) {
                                    await AuthFirebase.signout();
                                    if (!mounted) return;
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        Routes.loginview, (_) => false);
                                  }
                              }
                            },
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: MyColors.textsecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabled: true,
                          ),
                          hintText: "search...",
                          contentPadding:
                              const EdgeInsets.only(bottom: 15, top: 15),
                          controller: searchcontroller),
                    ),
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

  void populatechatrooms() async {
    items = await Database.retrivechatrooms(auth.currentUser!.uid) ?? [];
    if (items.isEmpty) {
      log("no chatrooms found !!");
    }
  }

  void setsearcheditems() {
    setState(() {
      searchitems = [];
      if (searchcontroller.text.isEmpty) {
        return;
      }
      String title, description;
      String searchtext = searchcontroller.text.toLowerCase();
      for (int i = 0; i < items.length; i++) {
        title =
            getotherprofile(items[i].connectedPersons).getName.toLowerCase();
        description = items[i].getlatestchat().text;
        if (title.contains(searchtext) || description.contains(searchtext)) {
          searchitems.add(items[i]);
        }
      }
    });
  }

  void init() async {
    await getpersonalinfo(auth.currentUser!.uid).then((value) {
      snapshot = value;
      populatechatrooms();
      profile = Profile.fromMap(data: snapshot!);
      EasyLoading.dismiss();
      setState(() {});
    });
  }

  void ontap() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChatRoomActivity(profiles: [profile]);
    }));
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
            context, "forbidden", "you cannot add your own phone no");
        return;
      }
      showbasicdialog(
          context, "added", "given phone number was added successfully !");
    } else {
      if (phone.length < 10) return;
      showbasicdialog(context, "failed", "given number doesnt exist yet !!");
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

  buildlistview(BuildContext context) {
    if (items.isEmpty) {
      return buildblankview("you are not connected to any Chatgroups");
    }
    if (searchitems.isEmpty && searchcontroller.text.isNotEmpty) {
      return buildblankview("we couldn't find specified chatroom");
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        ChatRoom currentchatroom =
            searchcontroller.text.isEmpty ? items[index] : searchitems[index];
        return ChatRoomItem(
          top: index == 0 ? true : null,
          notificationcount: null,
          read: true,
          searchcontroller: searchcontroller,
          ontap: ontap,
          date: DateTime.now(),
          title: getotherprofile(currentchatroom.connectedPersons).getName,
          description: currentchatroom.getlatestchat().text,
        );
      },
          childCount: searchcontroller.text.isEmpty
              ? items.length
              : searchitems.length),
    );
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
}
