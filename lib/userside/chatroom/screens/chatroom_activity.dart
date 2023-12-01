import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:chatty/assets/SystemChannels/path.dart';
import 'package:chatty/assets/SystemChannels/picker.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/firebase/messaging/fcmoperations.dart';
import 'package:chatty/userside/chatroom/common/widgets/topactions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../assets/SystemChannels/intent.dart' as intent;
import '../../../assets/SystemChannels/toast.dart';
import '../../../assets/colors/colors.dart';
import '../../../assets/logic/FirebaseUser.dart';
import '../../../assets/logic/chat.dart';
import '../../../constants/chatbubble_position.dart';
import '../../../constants/enumFIleType.dart';
import '../../../global/functions/unfocus.dart';
import '../../dashview/common/widgets/textfield_main.dart';
import '../../profiles/common/functions/compressimage.dart';
import '../../profiles/common/widgets/getprofilecircle.dart';
import '../common/functions/formatdate.dart';
import '../common/functions/generateid.dart';
import '../common/functions/sameday.dart';
import '../common/widgets/chatbubble.dart';
import '../common/widgets/chatroomactivity_shimmer.dart';
import '../common/widgets/sharebottomsheet.dart';

class ChatRoomActivity extends StatefulWidget {
  ChatRoom chatroom;
  FirebaseUser user;
  ChatRoomActivity({
    super.key,
    required this.user,
    required this.chatroom,
  });

  @override
  State<ChatRoomActivity> createState() => _ChatRoomActivityState();
}

class Status {
  static const int online = 1, offline = 0, typing = 2;
}

class _ChatRoomActivityState extends State<ChatRoomActivity>
    with WidgetsBindingObserver {
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  late Profile myprofile;
  late bool canishowfab;
  String? documentpath;
  String? mediapath;
  late VoidCallback scrollcontrollerlistener;
  File? file;
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollcontroller = ScrollController();
  bool animationrunning = false;
  bool firsttime = true;
  late Map<String, int> statuses = {}; // also include my status

  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      listener; // {"myphoneno" : online(1)/typing(2)/offline(0)}
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> chatslistener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    canishowfab = false;
    scrollcontrollerlistener = () {
      if (_scrollcontroller.position.pixels + 200 >=
          _scrollcontroller.position.maxScrollExtent) {
        canishowfab = false;
      } else {
        canishowfab = true;
      }
      setState(() {});
    };
    _scrollcontroller.addListener(scrollcontrollerlistener);
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    _scrollcontroller.removeListener(scrollcontrollerlistener);
    _scrollcontroller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // if you close app with keybaord on it would stay on typing status
        // so have to hide the keyboard first
        unfocus(context);
        statuses[myprofile.getPhoneNumber] = Status.offline;
        Database.updatestatus(
            myprofile.getPhoneNumber, Status.offline); // set to offline
        break;
      case AppLifecycleState.resumed:
        statuses[myprofile.getPhoneNumber] = Status.online;
        Database.updatestatus(myprofile.getPhoneNumber, Status.online);
        break; // set to online
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData md = MediaQuery.of(context);
    bool iskeyboardvisible = md.viewInsets.bottom > 0;
    if (_scrollcontroller.hasClients &&
        !canishowfab &&
        _scrollcontroller.position.pixels == 0 &&
        !animationrunning &&
        !firsttime) {
      scrolltobottom();
      firsttime = false;
    } else if (iskeyboardvisible && !animationrunning) {
      scrolltobottom();
    }
    String myphoneno = myprofile.getPhoneNumber;
    if (iskeyboardvisible &&
        (statuses[myphoneno] ?? Status.online) == Status.online) {
      statuses[myphoneno] = Status.typing; // set to typing
      Database.updatestatus(myphoneno, Status.typing);
    } else if (!iskeyboardvisible &&
        (statuses[myphoneno] ?? Status.online) == Status.typing) {
      statuses[myphoneno] = Status.online;
      Database.updatestatus(myphoneno, Status.online);
    }
    String? photourl;
    String title;
    String? status;
    Profile otherprofile;
    if (widget.chatroom.isitgroup) {
      photourl = widget.chatroom.groupinfo!.photourl;
      title = widget.chatroom.groupinfo!.name;
      status = decodegroupstatus();
    } else {
      otherprofile = getotherprofile();
      photourl = otherprofile.photourl;
      title = otherprofile.getName;
      status = decodestatus(statuses[otherprofile.getPhoneNumber]);
    }
    return WillPopScope(
      onWillPop: () async {
        onbackpressed();
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: canishowfab && md.viewInsets.bottom == 0
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: FloatingActionButton(
                    highlightElevation: 0,
                    backgroundColor: Colors.white,
                    splashColor: MyColors.splashColor,
                    focusColor: MyColors.focusColor,
                    foregroundColor: MyColors.primarySwatch,
                    child: const Icon(Icons.arrow_downward_rounded),
                    onPressed: () {
                      setState(() {
                        canishowfab = false;
                        scrolltobottom();
                      });
                    },
                  ),
                )
              : null,
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              topactions(context, md, title, status, photourl),
              chatslistview(md),
              bottomaction(md, iskeyboardvisible),
              SizedBox(height: md.viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget topactions(BuildContext context, MediaQueryData md, String title,
      String? status, String? photourl) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 10,
            offset: Offset.fromDirection(12),
          )
        ],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            pauselisteners();
            unfocus(context);
            Profile otherprofile = getotherprofile();
            final String route = widget.chatroom.isitgroup
                ? Routes.groupProfile
                : Routes.userProfile;
            final Map<String, dynamic> extra = widget.chatroom.isitgroup
                ? {
                    "myphoneno": myprofile.getPhoneNumber,
                    "mediachats": getchatroomfiles(),
                    "sentData": getsentfromdata(),
                    "user": widget.user,
                    "chatroom": widget.chatroom,
                  }
                : {
                    "blockedBy": widget.chatroom.blockedby,
                    "chatroomid": widget.chatroom.id,
                    "myprofile": myprofile,
                    "user": widget.user,
                    "chats": getchatroomfiles(),
                    "profile": otherprofile,
                    "sentData": getsentfromdata(),
                  };

            context.push(route, extra: extra).then((data) {
              if (data == "pop") {
                context.pop();
              }
              if (data == null) return;
              if (data == "deleted") {
                context.pop("deleted");
              }
              final value = data as Map<String, dynamic>;
              if (value["firebaseuser"] != null) {
                widget.user = value["firebaseuser"];
              }
              if (value["chatroom"] != null) {
                widget.chatroom = value["chatroom"];
              }
              resumelisteners();
            });
          },
          focusColor: MyColors.focusColor,
          highlightColor: Colors.transparent,
          splashColor: MyColors.splashColor,
          child: Container(
            height: md.size.height * 0.11,
            width: md.size.width,
            padding:
                EdgeInsets.only(top: md.viewPadding.top, bottom: 12, left: 10),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: TopActions(
              herotag: widget.chatroom.id,
              title: title,
              status: status,
              photourl: photourl,
              onbackpressed: onbackpressed,
              isitgroup: widget.chatroom.isitgroup,
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomaction(MediaQueryData md, bool iskeyboardvisible) {
    bool amIBlocked =
        widget.chatroom.blockedby[getotherprofile().getPhoneNumber] ?? false;
    bool didIBlock =
        widget.chatroom.blockedby[myprofile.getPhoneNumber] ?? false;
    return Expanded(
      child: IgnorePointer(
        ignoring: amIBlocked || didIBlock,
        child: Container(
            height: md.size.height * 0.09,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            width: md.size.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                )),
            child: Stack(
              children: [
                Opacity(
                  opacity: amIBlocked || didIBlock ? 1 : 0,
                  child: Center(
                    child: Text(
                      didIBlock
                          ? "You have blocked ${getotherprofile().getName}."
                          : "You have been blocked.",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Opacity(
                  opacity: amIBlocked || didIBlock ? 0 : 1,
                  child: Flex(
                    direction: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      GestureDetector(
                          onTap: () async {
                            pauselisteners();
                            unfocus(context);
                            Object? data =
                                await context.push(Routes.myProfile, extra: {
                              "myprofile": myprofile,
                            });

                            myprofile = data as Profile;
                            resumelisteners();
                            setState(() {});
                          },
                          child: Hero(
                            transitionOnUserGestures: true,
                            tag: myprofile.photourl.toString(),
                            child: profilewidget(myprofile.photourl, 45, false),
                          )),
                      const SizedBox(width: 15),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 17,
                        child: TextFieldmain(
                          scrollble: true,
                          onchanged: null,
                          contentPadding: const EdgeInsets.only(
                              top: 10, bottom: 15, left: 5, right: 10),
                          controller: controller,
                          hintText: "type something...",
                        ),
                      ),
                      const SizedBox(width: 5),
                      Transform.rotate(
                        angle: -math.pi / 4,
                        child: IconButton(
                            onPressed: () {
                              showbottomsheet(
                                context: context,
                                items: [
                                  // camera
                                  shareItem(
                                    context: context,
                                    backgroundcolor: Colors.red.shade500,
                                    icon: Icons.camera_alt_rounded,
                                    ontap: pickfromcamera,
                                  ),
                                  // gallery
                                  shareItem(
                                    context: context,
                                    backgroundcolor: Colors.green.shade500,
                                    icon: Icons.image,
                                    ontap: pickfromgallery,
                                  ),
                                  // contact
                                  if (!widget.chatroom.isitgroup)
                                    shareItem(
                                      context: context,
                                      backgroundcolor: MyColors.primarySwatch,
                                      icon: Icons.person_add_alt_rounded,
                                      ontap: addcontact,
                                    ),
                                  // files
                                  shareItem(
                                    context: context,
                                    backgroundcolor: Colors.blue.shade500,
                                    icon: Icons.description_outlined,
                                    ontap: pickfromfiles,
                                  ),
                                ],
                              );
                            },
                            icon: const Icon(
                              size: 27,
                              Icons.attach_file,
                              color: MyColors.textprimary,
                            )),
                      ),
                      Flexible(
                        flex: 3,
                        child: IconButton(
                          onPressed: () {
                            if (controller.text.isEmpty) {
                              return;
                            }
                            sendmessage();
                          },
                          icon: const Icon(Icons.send,
                              color: MyColors.primarySwatch, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Container chatslistview(MediaQueryData md) {
    return Container(
      width: md.size.width,
      height: md.size.height * 0.78 - md.viewInsets.bottom,
      padding: const EdgeInsets.only(left: 16, right: 16),
      alignment: Alignment.bottomCenter,
      child: documentpath == null || mediapath == null
          ? ShimmerChatRoomActivity()
          : ListView.separated(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              separatorBuilder: (context, index) {
                return !atSameDay(widget.chatroom.chats[index].time,
                        widget.chatroom.chats[index + 1].time)
                    ? dateseparator(index)
                    : Container(
                        margin: index != 0 &&
                                index != widget.chatroom.chats.length - 1 &&
                                !atSameDay(
                                    widget.chatroom.chats[index - 1].time,
                                    widget.chatroom.chats[index].time) &&
                                !atSameDay(
                                    widget.chatroom.chats[index + 1].time,
                                    widget.chatroom.chats[index].time)
                            ? null
                            : getmarginofbubble(index + 1),
                      );
              },
              controller: _scrollcontroller,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) {
                Chat currentchat = widget.chatroom.chats[index];
                bool issentfromme =
                    currentchat.sentFrom == myprofile.getPhoneNumber;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom:
                          index == widget.chatroom.chats.length - 1 ? 10 : 0),
                  child: ChatBubble(
                      profiles: widget.chatroom.connectedPersons,
                      chatroomid: widget.chatroom.id,
                      onchatdelete: () {
                        onchatdelete(index);
                      },
                      isitgroup: widget.chatroom.isitgroup,
                      mediavisibility:
                          widget.user.mediavisibility[widget.chatroom.id] ??
                              true,
                      documentpath: documentpath!,
                      mediapath: mediapath!,
                      myprofile: myprofile,
                      otherprofile: getotherprofile(currentchat.sentFrom),
                      position: getpositionofbubble(index),
                      issentfromme: issentfromme,
                      chat: currentchat),
                );
              },
              itemCount: widget.chatroom.chats.length),
    );
  }

  Center dateseparator(int index) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              blurStyle: BlurStyle.normal,
              spreadRadius: 1,
              offset: Offset(6, 3),
            )
          ],
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(formatdatebyday(widget.chatroom.chats[index + 1].time),
            style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Profile getotherprofile([String? sentFrom]) {
    if (sentFrom != null) {
      for (int i = 0; i < widget.chatroom.connectedPersons.length; i++) {
        if (sentFrom == widget.chatroom.connectedPersons[i].getPhoneNumber) {
          return widget.chatroom.connectedPersons[i];
        }
      }
    }
    String? myemail = auth.currentUser!.email;
    for (int i = 0; i < widget.chatroom.connectedPersons.length; i++) {
      if (myemail != widget.chatroom.connectedPersons[i].getEmail) {
        return widget.chatroom.connectedPersons[i];
      }
    }
    throw Error();
  }

  Profile getmyprofile() {
    String? myemail = auth.currentUser!.email;
    for (int i = 0; i < widget.chatroom.connectedPersons.length; i++) {
      if (myemail == widget.chatroom.connectedPersons[i].getEmail) {
        return widget.chatroom.connectedPersons[i];
      }
    }
    throw Error();
  }

  void sendmessage({FileType? type, String? name}) async {
    if (controller.text.isEmpty && file == null) return;
    late Chat newchat;
    String id = generatedid(15);
    setState(() {
      newchat = Chat(
        fileinfo: type != null
            ? FileInfo(
                filename: name,
                type: type,
                file: file,
                path: file!.path,
              )
            : null,
        id: id,
        time: DateTime.now(),
        text: type != FileType.any ? controller.text : "",
        sentFrom: myprofile.getPhoneNumber,
      );

      widget.chatroom.chats.add(newchat);

      scrolltobottom();
      controller.clear();
      FocusScope.of(context).requestFocus(FocusNode());
    });

    final List<String>? tokens =
        await getTokens(widget.chatroom.connectedPersons);
    if (tokens == null || tokens.isEmpty) return;
    bool result = await FCMOperations.send(tokens, {
      "chat": newchat.toMap(),
      "sentFrom": myprofile.toMap(),
    });

    if (!result) log("error sending notification");

    if (type == null) {
      await Database.writechat(chat: newchat, chatroomid: widget.chatroom.id);
    }
  }

  ChatBubblePosition getpositionofbubble(int index) {
    // to cover corner cases
    // where item may be first or last
    // first
    if (index == 0) {
      if (widget.chatroom.chats.length == 1) return ChatBubblePosition.alone;
      if (widget.chatroom.chats[index].sentFrom !=
          widget.chatroom.chats[index + 1].sentFrom) {
        return ChatBubblePosition.alone;
      }
      return ChatBubblePosition.top;
    }
    // last
    if (widget.chatroom.chats.length - 1 == index) {
      if (widget.chatroom.chats[index].sentFrom !=
          widget.chatroom.chats[index - 1].sentFrom) {
        return ChatBubblePosition.alone;
      }
      return ChatBubblePosition.bottom;
    }
    // to check if it is surrounded by divider
    bool topofdivider = !atSameDay(widget.chatroom.chats[index].time,
        widget.chatroom.chats[index + 1].time);
    bool bottomofdivider = !atSameDay(widget.chatroom.chats[index].time,
        widget.chatroom.chats[index - 1].time);
    bool surrounded = topofdivider && bottomofdivider;
    if (surrounded) return ChatBubblePosition.alone;
    if (widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index - 1].sentFrom &&
        widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index + 1].sentFrom) {
      return ChatBubblePosition.alone;
    }
    if (widget.chatroom.chats[index].sentFrom ==
            widget.chatroom.chats[index - 1].sentFrom &&
        widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index + 1].sentFrom &&
        !bottomofdivider) {
      return ChatBubblePosition.bottom;
    }
    if (widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index - 1].sentFrom &&
        !topofdivider) {
      return ChatBubblePosition.top;
    }
    if (bottomofdivider) return ChatBubblePosition.top;
    if (topofdivider) return ChatBubblePosition.bottom;
    return ChatBubblePosition.middle;
  }

  EdgeInsetsGeometry getmarginofbubble(int index) {
    if (index == 0) {
      return const EdgeInsets.only(top: 3);
    }
    if (index == widget.chatroom.chats.length - 1) {
      if (widget.chatroom.chats[index].sentFrom !=
          widget.chatroom.chats[index - 1].sentFrom) {
        return const EdgeInsets.only(top: 12);
      }
      return const EdgeInsets.only(bottom: 3);
    }
    return EdgeInsets.only(
        top: widget.chatroom.chats[index - 1].sentFrom ==
                widget.chatroom.chats[index].sentFrom
            ? 3
            : 12);
  }

  void scrolltobottom() {
    if (!_scrollcontroller.hasClients) {
      return;
    }
    animationrunning = true;
    _scrollcontroller
        .animateTo(
      _scrollcontroller.position.maxScrollExtent + 150,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .whenComplete(() {
      animationrunning = false;
    });
    canishowfab = false;
  }

  void setpersonalinfo() async {
    await Database.getpersonalinfo(auth.currentUser!.uid).then((value) {
      myprofile = value;
    });
  }

  void init() async {
    myprofile = getmyprofile();
    documentpath = await PathProvider.documentDirectory();
    mediapath = await PathProvider.mediaDirectory();
    await Future.delayed(const Duration(milliseconds: 300));
    scrolltobottom();
    statuses[myprofile.getPhoneNumber] = Status.online;
    Database.updatestatus(myprofile.getPhoneNumber, Status.online);
    listentochatroomchanges();
    listentostatuses();
  }

  void listentochatroomchanges() {
    chatslistener = db
        .collection("chatrooms")
        .doc(widget.chatroom.id)
        .snapshots()
        .listen((event) {
      Database.refreshchatroom(event.data()!, widget.chatroom.chats)
          .then((value) {
        widget.chatroom.chats = value;
        widget.chatroom.sortchats();
        scrolltobottom();
        if (mounted) setState(() {});
      });
    });
  }

  void pickfromgallery() async {
    context.pop();
    Picker picker = Picker(onResult: (value) async {
      if (value != null) {
        // compress image is returning cache path
        File myfile = await compressimage(value, 80);
        file = await myfile.copy(value.path);
        log(file!.path);
        sendmessage(type: FileType.image);
      }
    });
    picker.pickimage();
  }

  void pickfromfiles() async {
    context.pop();
    bool isgranted = await Permission.storage.request().isGranted;
    if (!isgranted) {
      Toast("allow the permission to send files");
      return;
    }
    Picker picker = Picker(onResult: (result) {
      if (result == null) {
        return;
      }
      if (result.lengthSync() > 20971520) {
        // files over the 20MB are not allowed for now
        Toast("file is too big too send !!");
      }
      file = result;
      sendmessage(type: FileType.media, name: getfilename(file!));
    });
    picker.pickfile();
  }

  void pickfromcamera() {
    context.pop();
    // ignore: invalid_use_of_visible_for_testing_member
    ImagePicker.platform
        .pickImage(source: ImageSource.camera)
        .then((image) async {
      if (image == null) return;
      log(image.path);
      File myfile = await compressimage(File(image.path), 80);
      file = await myfile.copy(image.path);
      sendmessage(type: FileType.image);
    });
  }

  List<Chat> getchatroomfiles() {
    List<Chat> chats = [];
    for (int i = 0; i < widget.chatroom.chats.length; i++) {
      if (widget.chatroom.chats[i].fileinfo != null &&
          widget.chatroom.chats[i].fileinfo?.type == FileType.image) {
        chats.add(widget.chatroom.chats[i]);
      }
    }
    return chats;
  }

  Map<String, String> getsentfromdata() {
    Map<String, String> sentdata = {};
    for (int i = 0; i < widget.chatroom.connectedPersons.length; i++) {
      sentdata[widget.chatroom.connectedPersons[i].getPhoneNumber] =
          widget.chatroom.connectedPersons[i].getName;
    }
    return sentdata;
  }

  void listentostatuses() {
    // intialize all status to offline first
    for (int i = 0; i < widget.chatroom.connectedPersons.length; i++) {
      statuses[widget.chatroom.connectedPersons[i].getPhoneNumber] = 0;
    }
    statuses.remove(myprofile.getPhoneNumber);
    // listen to changes
    statuses.forEach((key, value) {
      listener = db.collection("status").doc(key).snapshots().listen((event) {
        statuses[key] = event.data()?.cast<String, int>()["status"] ?? 0;
        log("$key : ${statuses[key]} updated");
        if (!mounted) return;
        setState(() {});
      });
    });
  }

  String decodestatus(int? status) {
    if (status == null) {
      return "offline";
    }
    switch (status) {
      case 0:
        return "offline";
      case 1:
        return "online";
      case 2:
        return "typing...";
      default:
        return "offline";
    }
  }

  String? decodegroupstatus() {
    Map<String, int> typingmembers = {};
    statuses.forEach((key, value) {
      if (value == 2) {
        typingmembers[key] = value;
      }
    });
    // remove my profile
    typingmembers.remove(myprofile.getPhoneNumber);

    // if its empty return
    if (typingmembers.isEmpty) {
      return null;
    }

    // get all of their profiles by their phoneno
    List<Profile> typingprofiles = [];
    for (Profile profile in widget.chatroom.connectedPersons) {
      if (typingmembers.containsKey(profile.getPhoneNumber)) {
        typingprofiles.add(profile);
      }
    }
    String finalStatusString = "";
    for (int i = 0; i < typingprofiles.length; i++) {
      finalStatusString += typingprofiles[i].getName;
      if (i != typingprofiles.length - 1) {
        finalStatusString += ", ";
      } else {
        finalStatusString += " ";
      }
    }

    // check if only one member is typing or more that that
    if (typingprofiles.length == 1) {
      finalStatusString += "is typing...";
    } else {
      finalStatusString += "are typing...";
    }
    return finalStatusString;
  }

  String getfilename(File file) {
    return file.uri.pathSegments.last;
  }

  void onbackpressed() {
    cancellisteners();
    statuses[myprofile.getPhoneNumber] = Status.offline;
    Database.updatestatus(myprofile.getPhoneNumber, Status.offline);
    log("canceled status listener");
    context.pop(widget.chatroom);
  }

  void addcontact() {
    Profile profile = getotherprofile();
    intent.Intent.addcontact(profile);
  }

  void pauselisteners() {
    listener.pause();
    chatslistener.pause();
  }

  void resumelisteners() {
    listener.resume();
    chatslistener.resume();
  }

  void cancellisteners() {
    listener.cancel();
    chatslistener.cancel();
  }

  void onchatdelete(int index) async {
    await Database.deleteChat(widget.chatroom.chats[index], widget.chatroom.id);
    widget.chatroom.chats.removeAt(index);
    Toast("chat has been deleted successfully !!");
    setState(() {});
  }

  Future<List<String>?> getTokens(List<Profile> connectedPersons) async {
    List<String> tokens = [];

    for (int i = 0; i < connectedPersons.length; i++) {
      final String phoneno = connectedPersons[i].getPhoneNumber;
      if (phoneno == myprofile.getPhoneNumber) continue;

      final String? uid = await Database.getuid(phoneno);
      if (uid == null) continue;

      final String? token = await FCMOperations.get(uid);
      if (token == null) continue;

      tokens.add(token);
    }

    return tokens.isEmpty ? null : tokens;
  }
}
