import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/widgets/chatbubble.dart';
import 'package:chatty/assets/logic/chat.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:chatty/firebase/auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/common/functions/getprofileimage.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  late FirebaseAuth auth;
  List<Chat> chats = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: MyColors.scaffoldbackground,
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await AuthFirebase.signout();
        if (!mounted) return;
        Navigator.pop(context);
      }),
      body: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          itemBuilder: (context, index) {
            return Align(
              alignment: Alignment.centerRight,
              child: ChatBubble(
                  key: ValueKey(chats[index].toString()),
                  position: ChatBubblePosition.top,
                  issentfromme:
                      chats[index].sentFrom == auth.currentUser?.phoneNumber,
                  text: chats[index].text),
            );
          },
          itemCount: chats.length),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: md.size.width,
        decoration: const BoxDecoration(
            color: MyColors.scaffoldbackground,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(child: getuserprofile()),
            SizedBox(
              width: 283,
              child: TextField(
                autocorrect: true,
                autofillHints: null,
                autofocus: false,
                expands: true,
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "type something...",
                  helperStyle: TextStyle(fontSize: 0),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                sendmessage();
              },
              icon: const Icon(Icons.send),
              color: MyColors.primarySwatch,
            )
          ],
        ),
      ),
    );
  }

  void sendmessage() {
    setState(() {
      chats.add(Chat(
          id: "randomly generated id",
          time: DateTime.now(),
          text: controller,
          sentFrom: auth.currentUser?.phoneNumber));
      controller.clear();
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });
  }
}
