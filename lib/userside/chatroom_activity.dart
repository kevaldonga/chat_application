import 'dart:io';
import 'dart:math' as math;

import 'package:chatty/assets/common/functions/compressimage.dart';
import 'package:chatty/assets/common/functions/formatdate.dart';
import 'package:chatty/assets/common/functions/generateid.dart';
import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:chatty/assets/common/functions/sameday.dart';
import 'package:chatty/assets/common/widgets/getprofilewidget.dart';
import 'package:chatty/assets/common/widgets/textfield_main.dart';
import 'package:chatty/assets/logic/chatroom.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/imageview.dart';
import 'package:chatty/userside/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../assets/colors/colors.dart';
import '../assets/common/widgets/chatbubble.dart';
import '../assets/common/widgets/sharebottomsheet.dart';
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
  File? file;
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollcontroller = ScrollController();
  bool animationrunning = false;

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
    controller.dispose();
    _scrollcontroller.removeListener(scrollcontrollerlistener);
    _scrollcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData md = MediaQuery.of(context);
    bool iskeyboardvisible = md.viewInsets.bottom > 0;
    if (_scrollcontroller.hasClients &&
        !canishowfab &&
        _scrollcontroller.position.pixels == 0 &&
        !animationrunning) {
      scrolltobottom();
    } else if (iskeyboardvisible && !animationrunning) {
      scrolltobottom();
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(widget.chatroom);
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
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
              bottomaction(md, iskeyboardvisible),
              SizedBox(height: md.viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Expanded bottomaction(MediaQueryData md, bool iskeyboardvisible) {
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
      child: ListView.separated(
          separatorBuilder: (context, index) {
            return !atSameDay(widget.chatroom.chats[index].time,
                    widget.chatroom.chats[index + 1].time)
                ? dateseparator(index)
                : Container(
                    margin: index != 0 &&
                            index != widget.chatroom.chats.length - 1 &&
                            !atSameDay(widget.chatroom.chats[index - 1].time,
                                widget.chatroom.chats[index].time) &&
                            !atSameDay(widget.chatroom.chats[index + 1].time,
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
            Alignment bubblealignment =
                issentfromme ? Alignment.centerRight : Alignment.centerLeft;
            return Align(
              alignment: bubblealignment,
              child: GestureDetector(
                onTap: () {
                  if (widget.chatroom.chats[index].url == null) {
                    return;
                  }
                  openImage(widget.chatroom.chats[index]);
                },
                onDoubleTap: () async {
                  setState(() {
                    if (ChatBubble.expandedbubble == currentchat) {
                      ChatBubble.expandedbubble = null;
                      return;
                    }
                    ChatBubble.expandedbubble = currentchat;
                  });
                  if (index == widget.chatroom.chats.length - 1) {
                    Future.delayed(const Duration(milliseconds: 200))
                        .whenComplete(() {
                      _scrollcontroller.animateTo(
                          curve: Curves.bounceInOut,
                          duration: const Duration(milliseconds: 200),
                          _scrollcontroller.position.maxScrollExtent + 30);
                    });
                  }
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom:
                          index == widget.chatroom.chats.length - 1 ? 10 : 0),
                  child: ChatBubble(
                      position: getpositionofbubble(index),
                      issentfromme: issentfromme,
                      chat: currentchat),
                ),
              ),
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

  void sendmessage({bool isitfile = false}) async {
    if (controller.text.isEmpty && file == null) return;
    late Chat newchat;
    String id = generatedid(15);
    setState(() {
      newchat = Chat(
          file: file,
          isiturl: isitfile,
          id: id,
          time: DateTime.now(),
          text: controller.text,
          sentFrom: myprofile.getPhoneNumber);

      widget.chatroom.chats.add(newchat);

      scrolltobottom();

      controller.clear();
      SystemChannels.textInput.invokeMethod("TextInput.hide");
    });
    await Database.writechat(chat: newchat, chatroomid: widget.chatroom.id);
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
    // only which are not sent by me
    Database.markchatsread(widget.chatroom.chats, myprofile.getPhoneNumber);
    for (int i = 0; i < widget.chatroom.chats.length; i++) {
      if (widget.chatroom.chats[i].sentFrom != myprofile.getPhoneNumber) {
        widget.chatroom.chats[i].setread = true;
      }
    }
  }

  void listentochatroomchanges() {
    db
        .collection("chatrooms")
        .doc(widget.chatroom.id)
        .snapshots()
        .listen((event) {
      Database.refreshchatroom(event.data()!, widget.chatroom.chats)
          .then((value) {
        widget.chatroom.chats = value;
        markasallread();
        widget.chatroom.sortchats();
        scrolltobottom();
        if (mounted) setState(() {});
      });
    });
  }

  void pickfromgallery() async {
    Navigator.pop(context);
    FilePickerResult? result;
    result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result == null) return;
    file = await compressimage(File(result.files.first.path!), 80);
    sendmessage(isitfile: true);
  }

  void pickfromcamera() async {
    Navigator.pop(context);
    final image =
        // ignore: invalid_use_of_visible_for_testing_member
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if (image == null) return;
    file = await compressimage(File(image.path), 80);
    sendmessage(isitfile: true);
  }

  void openImage(Chat chat) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ImageView(
          chat: chat,
          sentFrom: chat.sentFrom == myprofile.getPhoneNumber
              ? myprofile.getName
              : getotherprofile().getName);
    }));
  }
}
