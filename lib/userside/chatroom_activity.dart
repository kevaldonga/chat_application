import 'dart:developer';

import 'package:chatty/assets/common/functions/generateid.dart';
import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:chatty/assets/common/widgets/getprofilewidget.dart';
import 'package:chatty/assets/common/widgets/textfield_main.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/colors/colors.dart';
import '../assets/common/widgets/chatbubble.dart';
import '../assets/logic/chat.dart';
import '../constants/chatbubble_position.dart';

class ChatRoomActivity extends StatefulWidget {
  final ChatRoom chatroom;
  const ChatRoomActivity({super.key, required this.chatroom});

  @override
  State<ChatRoomActivity> createState() => _ChatRoomActivityState();
}

class _ChatRoomActivityState extends State<ChatRoomActivity> {
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  late Profile myprofile;
  late bool canishowfab;
  late VoidCallback scrollcontrollerlistener;
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollcontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    canishowfab = false;
    scrollcontrollerlistener = () {
      if (_scrollcontroller.position.atEdge) {
        if (_scrollcontroller.position.pixels ==
            _scrollcontroller.position.maxScrollExtent) {
          canishowfab = false;
        }
      }
      else{
        canishowfab = true;
      }
      setState(() {});
    };
    _scrollcontroller.addListener(scrollcontrollerlistener);
    init();
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollcontroller.removeListener(scrollcontrollerlistener);
    _scrollcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData md = MediaQuery.of(context);
    if (_scrollcontroller.hasClients &&
        !canishowfab &&
        _scrollcontroller.position.pixels == 0) {
      scrolltobottom(md);
    }
    if (md.viewInsets.bottom > 0) {
      scrolltobottom(md);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                    scrolltobottom(md);
                  });
                },
              ),
            )
          : null,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Hero(
            tag: getotherprofile().getPhotourl.toString(),
            child: Container(
              height: md.size.height * 0.11,
              width: md.size.width,
              padding: EdgeInsets.only(
                  top: md.viewPadding.top, bottom: 12, left: 10),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 10,
                      offset: Offset.fromDirection(12),
                    )
                  ],
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: topactions(context),
            ),
          ),
          chatslistview(md),
          bottomaction(md),
          SizedBox(height: md.viewInsets.bottom),
        ],
      ),
    );
  }

  Expanded bottomaction(MediaQueryData md) {
    return Expanded(
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
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () async {
                  myprofile = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return MyProfile(profile: myprofile);
                  }));
                  setState(() {});
                },
                child: myprofile.getPhotourl == null &&
                        myprofile.getPhotourl == "null"
                    ? const CircleAvatar(
                        child:
                            Icon(Icons.person, color: MyColors.primarySwatch),
                      )
                    : profilewidget(myprofile.getPhotourl!, 45),
              ),
              const SizedBox(width: 15),
              Flexible(
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
              const SizedBox(width: 10),
              Flexible(
                flex: 3,
                child: IconButton(
                  onPressed: () {
                    sendmessage();
                  },
                  icon: const Icon(Icons.send,
                      color: MyColors.primarySwatch, size: 30),
                ),
              ),
            ],
          )),
    );
  }

  Container chatslistview(MediaQueryData md) {
    return Container(
      width: md.size.width,
      height: md.size.height * 0.78 - md.viewInsets.bottom,
      padding: const EdgeInsets.only(left: 16, right: 16),
      alignment: Alignment.bottomCenter,
      child: ListView.builder(
          controller: _scrollcontroller,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          itemBuilder: (context, index) {
            Chat currentchat = widget.chatroom.chats[index];
            bool issentfromme =
                currentchat.sentFrom == myprofile.getPhoneNumber;
            return Align(
              alignment:
                  issentfromme ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: index == widget.chatroom.chats.length - 1 ? 10 : 0),
                child: ChatBubble(
                    position: getpositionofbubble(index),
                    margin: getmarginofbubble(index),
                    issentfromme: issentfromme,
                    text: widget.chatroom.chats[index].text),
              ),
            );
          },
          itemCount: widget.chatroom.chats.length),
    );
  }

  Row topactions(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.of(context).pop(widget.chatroom);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: MyColors.primarySwatch)),
        const SizedBox(width: 20),
        getotherprofile().getPhotourl == null &&
                getotherprofile().getPhotourl == "null"
            ? const CircleAvatar(
                child: Icon(Icons.person, color: MyColors.primarySwatch),
              )
            : profilewidget(getotherprofile().getPhotourl!, 45),
        const SizedBox(width: 20),
        Text(getotherprofile().getName,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 20)),
      ],
    );
  }

  Profile getotherprofile() {
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

  void sendmessage() async {
    if (controller.text.isEmpty) {
      return;
    }
    late Chat newchat;
    setState(() {
      newchat = Chat(
          id: generatedid(15),
          time: DateTime.now(),
          text: controller.text,
          sentFrom: myprofile.getPhoneNumber);

      widget.chatroom.chats.add(newchat);
      log("chat - ${controller.text} has been send");

      scrolltobottom(MediaQuery.of(context));

      controller.clear();
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });

    await Database.writechat(chat: newchat, chatroomid: widget.chatroom.id);
  }

  ChatBubblePosition getpositionofbubble(int index) {
    if (index == 0) {
      if (widget.chatroom.chats.length == 1) return ChatBubblePosition.alone;
      if (widget.chatroom.chats[index].sentFrom !=
          widget.chatroom.chats[index + 1].sentFrom) {
        return ChatBubblePosition.alone;
      }
      return ChatBubblePosition.top;
    }
    if (widget.chatroom.chats.length - 1 == index) {
      if (widget.chatroom.chats[index].sentFrom !=
          widget.chatroom.chats[index - 1].sentFrom) {
        return ChatBubblePosition.alone;
      }
      return ChatBubblePosition.bottom;
    }
    if (widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index - 1].sentFrom &&
        widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index + 1].sentFrom) {
      return ChatBubblePosition.alone;
    }
    if (widget.chatroom.chats[index].sentFrom ==
            widget.chatroom.chats[index - 1].sentFrom &&
        widget.chatroom.chats[index].sentFrom !=
            widget.chatroom.chats[index + 1].sentFrom) {
      return ChatBubblePosition.bottom;
    }
    if (widget.chatroom.chats[index].sentFrom !=
        widget.chatroom.chats[index - 1].sentFrom) {
      return ChatBubblePosition.top;
    }
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
      return const EdgeInsets.symmetric(vertical: 3);
    }
    return EdgeInsets.only(
        top: widget.chatroom.chats[index - 1].sentFrom ==
                widget.chatroom.chats[index].sentFrom
            ? 3
            : 12);
  }

  void scrolltobottom(MediaQueryData md) async {
    await _scrollcontroller.animateTo(
      _scrollcontroller.position.maxScrollExtent + md.size.height * 0.2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    canishowfab = false;
  }

  void setpersonalinfo() async {
    await getpersonalinfo(auth.currentUser!.uid).then((value) {
      myprofile = Profile.fromMap(data: value);
    });
  }

  void init() {
    myprofile = getmyprofile();
    markasallread();
    listentochatroomchanges();
  }

  void markasallread() {
    for (int i = 0; i < widget.chatroom.chats.length; i++) {
      if (widget.chatroom.chats[i].sentFrom != myprofile.getPhoneNumber) {
        widget.chatroom.chats[i].setread = true;
      }
    }
    Database.markchatsread(widget.chatroom.chats, myprofile.getPhoneNumber);
  }

  void listentochatroomchanges() {
    db
        .collection("chatrooms")
        .doc(widget.chatroom.id)
        .snapshots()
        .listen((event) async {
      await Database.refreshchatroom(event.data()!, widget.chatroom.chats)
          .then((value) {
        scrolltobottom(MediaQuery.of(context));
        setState(() {
          widget.chatroom.chats = value;
          widget.chatroom.sortchats();
        });
      });
    });
  }
}
