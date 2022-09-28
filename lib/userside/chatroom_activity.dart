import 'dart:developer';

import 'package:chatty/assets/common/functions/generateid.dart';
import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:chatty/assets/common/widgets/getprofilewidget.dart';
import 'package:chatty/assets/common/widgets/textfield_main.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/colors/colors.dart';
import '../assets/common/widgets/chatbubble.dart';
import '../assets/logic/chat.dart';
import '../constants/chatbubble_position.dart';

class ChatRoomActivity extends StatefulWidget {
  final List<Profile> profiles;
  const ChatRoomActivity({super.key, required this.profiles});

  @override
  State<ChatRoomActivity> createState() => _ChatRoomActivityState();
}

class _ChatRoomActivityState extends State<ChatRoomActivity> {
  late FirebaseAuth auth;
  List<Chat> chats = [];
  late Profile myprofile;
  TextEditingController controller = TextEditingController();

  final ScrollController _scrollcontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    init();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData md = MediaQuery.of(context);
    if (md.viewInsets.bottom > 0) {
      scrolltobottom();
    }
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: md.size.height * 0.11,
            width: md.size.width,
            padding:
                EdgeInsets.only(top: md.viewPadding.top, bottom: 12, left: 10),
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
          chatslistview(md),
          bottomaction(md),
          SizedBox(height: md.viewInsets.bottom),
        ],
      ),
    );
  }

  Expanded bottomaction(MediaQueryData md) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          myprofile = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return MyProfile(profile: myprofile);
          }));
          setState(() {});
          Database.writepersonalinfo(myprofile);
        },
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 5),
                Flexible(
                  flex: 4,
                  child: myprofile.getPhotourl == null ? 
                  const CircleAvatar(
                    child: Icon(Icons.person,color: MyColors.primarySwatch),
                  )
                  : profilewidget(myprofile.getPhotourl!,45),
                ),
                const SizedBox(width: 15),
                Flexible(
                  flex: 17,
                  child: TextFieldmain(
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
      ),
    );
  }

  Container chatslistview(MediaQueryData md) {
    return Container(
      width: md.size.width,
      height: md.size.height * 0.78 - md.viewInsets.bottom,
      padding: const EdgeInsets.only(left: 16,right: 16),
      alignment: Alignment.bottomCenter,
      child: ListView.builder(
          controller: _scrollcontroller,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          itemBuilder: (context, index) {
            bool issentfromme = chats[index].sentFrom == myprofile.getPhoneNumber;
            return Align(
              alignment:
                  issentfromme ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: index == chats.length - 1 ? 10 : 0),
                child: ChatBubble(
                    key: ValueKey(chats[index].toString()),
                    position: getpositionofbubble(index),
                    margin: getmarginofbubble(index),
                    issentfromme: issentfromme,
                    text: chats[index].text),
              ),
            );
          },
          itemCount: chats.length),
    );
  }

  Row topactions(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: MyColors.primarySwatch)),
        const SizedBox(width: 20),
        const CircleAvatar(child: Icon(Icons.face,color: MyColors.primarySwatch)),
        const SizedBox(width: 20),
        const Text("darshan",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 20)),
      ],
    );
  }

  void sendmessage() {
    if(controller.text.isEmpty){
      return;
    }
    setState(() {
      chats.add(Chat(
          read: true,
          id: "randomly generated id",
          time: DateTime.now(),
          text: controller.text,
          sentFrom: myprofile.getPhoneNumber));
      log("chat - ${controller.text} has been send");
      scrolltobottom();
      controller.clear();
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });
  }

  ChatBubblePosition getpositionofbubble(int index) {
    if (index == 0) {
      return ChatBubblePosition.bottom;
    }
    if (index == chats.length - 1) {
      return ChatBubblePosition.bottom;
    }
    if (chats[index].sentFrom != chats[index - 1].sentFrom &&
        chats[index].sentFrom != chats[index + 1].sentFrom) {
      return ChatBubblePosition.bottom;
    }
    if (chats[index].sentFrom == chats[index - 1].sentFrom &&
        chats[index].sentFrom != chats[index + 1].sentFrom) {
      return ChatBubblePosition.bottom;
    }
    if (chats[index].sentFrom != chats[index - 1].sentFrom) {
      return ChatBubblePosition.top;
    }
    return ChatBubblePosition.middle;
  }

  EdgeInsetsGeometry getmarginofbubble(int index) {
    if (index == 0) {
      return const EdgeInsets.only(top: 3);
    }
    if (index == chats.length - 1) {
      if (chats[index].sentFrom != chats[index - 1].sentFrom) {
        return const EdgeInsets.only(top: 12);
      }
      return const EdgeInsets.symmetric(vertical: 3);
    }
    return EdgeInsets.only(
        top: chats[index - 1].sentFrom == chats[index].sentFrom ? 3 : 12);
  }

  void scrolltobottom() {
    _scrollcontroller.animateTo(_scrollcontroller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void setpersonalinfo() async {
    await getpersonalinfo(auth.currentUser!.uid).then((value) {
      myprofile = Profile.fromMap(data: value);
    });
  }

  void populatechats() {
    chats = [
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "hello",
          sentFrom: myprofile.getPhoneNumber),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "hii",
          sentFrom: "321"),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text:
              "hey there i wanna talk to you about really great re u interested?",
          sentFrom: myprofile.getPhoneNumber),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "yeah lets do it",
          sentFrom: "321"),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "so i need to come on a talkshow",
          sentFrom: myprofile.getPhoneNumber),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "name is racism talks",
          sentFrom: "123"),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "u interested?",
          sentFrom: "123"),
      Chat(
          read: true,
          id: generatedid(10),
          time: DateTime.now(),
          text: "sure i am !!",
          sentFrom: myprofile.getPhoneNumber),
    ];
  }

  void init() {
    myprofile = widget.profiles.first;
    populatechats();
  }
}
