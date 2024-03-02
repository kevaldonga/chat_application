import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/global/variables/colors.dart';
import 'package:chatty/routing/routes.dart';
import 'package:chatty/global/variables/chatbubble_position.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/chatroom/functions/isreaction_empty.dart';
import 'package:chatty/userside/chatroom/functions/reaction_count_op.dart';
import 'package:chatty/utils/chat.dart';
import 'package:chatty/utils/profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../assets/SystemChannels/toast.dart';
import '../../../global/variables/enum_file_type.dart';
import '../../../global/functions/unfocus.dart';
import '../../../global/functions/formatdate.dart';
import '../../../global/functions/openfile.dart';
import 'onchathold.dart';

class ChatBubble extends StatefulWidget {
  final String chatroomid;
  static Chat? expandedbubble;
  final EdgeInsetsGeometry? margin;
  final ChatBubblePosition position;
  final bool issentfromme;
  final Chat chat;
  final Profile myprofile, otherprofile;
  final bool mediavisibility;
  final bool isitgroup;
  final String documentpath, mediapath;
  final VoidCallback onchatdelete;
  final List<Profile> profiles;
  const ChatBubble({
    super.key,
    this.margin,
    required this.profiles,
    required this.chatroomid,
    required this.onchatdelete,
    required this.isitgroup,
    required this.myprofile,
    required this.otherprofile,
    required this.mediavisibility,
    required this.documentpath,
    required this.mediapath,
    required this.chat,
    required this.position,
    required this.issentfromme,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController onreactcontroller;
  late Animation<double> animation;
  UploadTask? upload;
  DownloadTask? download;
  double _progress = 0;
  late MediaQueryData md;

  @override
  void initState() {
    super.initState();
    onreactcontroller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        setState(() {});
      });
    animation = Tween<double>(begin: 0, end: 0.075).animate(onreactcontroller);
    onreactcontroller.forward();
    init();
  }

  @override
  void dispose() {
    onreactcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String toasttext = widget.chat.fileinfo != null
        ? widget.chat.fileinfo?.filename != null
            ? "file name"
            : "image"
        : "text";
    Alignment bubblealignment =
        widget.issentfromme ? Alignment.centerRight : Alignment.centerLeft;
    md = MediaQuery.of(context);
    return GestureDetector(
      onTap: () {
        onchatbubbletap();
      },
      onDoubleTap: () {
        onchatbubbledoubletap();
      },
      onLongPress: () {
        unfocus(context);
        widget.chat.sortReactionCount();
        onchathold(
          profiles: widget.profiles,
          myphoneno: widget.myprofile.getPhoneNumber,
          reactionCount: widget.chat.reactioncount,
          reactions: widget.chat.reactions,
          onReactionRemoved: removeReaction,
          onReacted: (emoji) {
            bool didIReactToCurrentemoji = widget
                    .chat.reactions[widget.myprofile.getPhoneNumber]
                    ?.contains(emoji) ??
                false;
            if (didIReactToCurrentemoji) {
              return;
            }
            onReacted(emoji);
          },
          onchatdelete: widget.onchatdelete,
          whattocopy: (widget.chat.fileinfo != null
                  ? widget.chat.fileinfo?.filename ?? widget.chat.fileinfo?.url
                  : widget.chat.text) ??
              "",
          toasttextoncopied: "$toasttext copied to your clipboard !",
          context: context,
          isitme: widget.issentfromme,
          sentFrom:
              widget.issentfromme ? widget.myprofile : widget.otherprofile,
        );
      },
      child: Align(
        alignment: bubblealignment,
        child: Column(
          crossAxisAlignment: widget.issentfromme
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints:
                  BoxConstraints.loose(Size.fromWidth(md.size.width * 0.75)),
              padding: widget.chat.fileinfo?.file != null ||
                      widget.chat.fileinfo?.url != null
                  ? const EdgeInsets.all(7)
                  : const EdgeInsets.only(
                      left: 22, right: 22, top: 8, bottom: 12),
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: _getraduisbyposition(),
                gradient: widget.issentfromme
                    ? MyGradients.maingradientvertical
                    : null,
                color: !widget.issentfromme ? Colors.white : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isitgroup && !widget.issentfromme)
                    Padding(
                      padding: widget.chat.fileinfo?.type != null
                          ? EdgeInsets.symmetric(
                              horizontal:
                                  widget.chat.fileinfo?.type == FileType.image
                                      ? 10
                                      : 15,
                              vertical:
                                  widget.chat.fileinfo?.type == FileType.image
                                      ? 5
                                      : 0,
                            )
                          : EdgeInsets.zero,
                      child: Text(
                        widget.otherprofile.getName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  getcorrespondingbubble(),
                  if (widget.chat.text != null && widget.chat.text != "")
                    Padding(
                      padding: widget.chat.fileinfo?.file != null ||
                              widget.chat.fileinfo?.url != null
                          ? const EdgeInsets.only(left: 7, top: 5, bottom: 5)
                          : EdgeInsets.zero,
                      child: Text(
                        widget.chat.text!,
                        style: TextStyle(
                          color: widget.issentfromme
                              ? Colors.white
                              : MyColors.textprimary,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  // reactions panel
                  reactionPanel(),
                ],
              ),
            ),
            AnimatedContainer(
              height: widget.chat == ChatBubble.expandedbubble ? 20 : 0,
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                  left: widget.issentfromme ? 0 : 10,
                  right: widget.issentfromme ? 10 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.issentfromme)
                    Icon(Icons.check,
                        color: widget.chat.isread
                            ? MyColors.primarySwatch
                            : MyColors.textprimary,
                        size:
                            widget.chat == ChatBubble.expandedbubble ? 22 : 0),
                  const SizedBox(width: 5),
                  Text(formatdate(widget.chat.time, md)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reactionPanel() {
    return Opacity(
      opacity: animation.value / 0.075,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.chat.reactioncount.length,
          (index) {
            String currentEmoji =
                widget.chat.reactioncount.keys.elementAt(index);
            bool didIReactToCurrentemoji = widget
                    .chat.reactions[widget.myprofile.getPhoneNumber]
                    ?.contains(currentEmoji) ??
                false;
            return GestureDetector(
              onTap: () {
                onReacted(currentEmoji);
              },
              child: Container(
                height: md.size.width * animation.value,
                width: md.size.width * animation.value,
                margin: const EdgeInsets.only(top: 4, left: 3, right: 3),
                decoration: BoxDecoration(
                    color: didIReactToCurrentemoji
                        ? widget.issentfromme
                            ? Colors.white38
                            : Colors.grey.shade300
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: didIReactToCurrentemoji
                          ? widget.issentfromme
                              ? Colors.white70
                              : Colors.black54
                          : Colors.transparent,
                      width: 0.5,
                    )),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // emoji
                      Text(currentEmoji, style: const TextStyle(fontSize: 12)),
                      // emoji count
                      Text(widget.chat.reactioncount[currentEmoji]!.toString(),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void onReacted(String currentEmoji) async {
    bool didIReactToCurrentemoji = widget
            .chat.reactions[widget.myprofile.getPhoneNumber]
            ?.contains(currentEmoji) ??
        false;
    if (didIReactToCurrentemoji) {
      removeReaction(currentEmoji);
    } else {
      if (widget.chat.reactions.isReactionEmpty) {
        onreactcontroller.forward(from: 0);
      }
      widget.chat.reactioncount.increment(currentEmoji);
      //  add the reaction
      widget.chat.reactions[widget.myprofile.getPhoneNumber] ??= [];
      widget.chat.reactions[widget.myprofile.getPhoneNumber]!.add(currentEmoji);
    }

    widget.chat.sortReactionCount();
    setState(() {});

    // have to write the chat cause update wont work
    // when we try to remove the last emoji it wont be removed
    // as we are trying to update doc with {}
    // which will be merged into doc and not override it

    await Database.writechat(chat: widget.chat, chatroomid: widget.chatroomid);
  }

  Widget imageBubble() {
    initimageexist();
    return widget.chat.fileinfo!.file != null &&
            widget.chat.fileinfo!.file?.lengthSync() != 0
        ? fileimage()
        : cachedimage();
  }

  Widget fileimage() {
    return Image.file(
      widget.chat.fileinfo!.file!,
      fit: BoxFit.fitWidth,
      gaplessPlayback: true,
    );
  }

  CachedNetworkImage cachedimage() {
    return CachedNetworkImage(
      cacheKey: widget.chat.fileinfo!.url!,
      imageUrl: widget.chat.fileinfo!.url!,
      fit: BoxFit.fitWidth,
    );
  }

  Widget loadingcontainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Container(
            padding: EdgeInsets.all(md.size.width * 0.02),
            height: md.size.width * 0.15,
            width: md.size.width * 0.15,
            color: Colors.black38,
            child: CircularProgressIndicator(
              color: Colors.white,
              value: _progress,
              strokeWidth: 3,
            ),
          ),
        ),
        const Icon(
          Icons.download_rounded,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget fileBubble() {
    initfilepath();
    String path = widget.issentfromme
        ? widget.chat.fileinfo!.path!
        : widget.mediavisibility
            ? "${widget.mediapath}/files/FILE${widget.chat.fileinfo!.filename}"
            : "${widget.documentpath}/files/FILE${widget.chat.fileinfo!.filename}";
    widget.chat.fileinfo!.fileexist = File(path).existsSync();
    if (widget.chat.fileinfo!.fileexist) {
      widget.chat.fileinfo!.file = File(path);
    }
    bool shoulddownload =
        widget.chat.fileinfo!.file == null && download == null;
    final contentcolor =
        widget.issentfromme ? Colors.white : MyColors.primarySwatch;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Flex(
        mainAxisSize: MainAxisSize.min,
        direction: Axis.horizontal,
        children: [
          Flexible(
            flex: 3,
            // icon
            child: GestureDetector(
              onTap: shoulddownload ? filedownloadtostorage : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    opacity: _progress != 1 ? 1 : 0,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 3,
                      color: contentcolor,
                    ),
                  ),
                  Icon(
                    widget.chat.fileinfo!.fileexist
                        ? Icons.description
                        : Icons.download,
                    color: contentcolor,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: md.size.width * 0.04),
          // file name
          Flexible(
            flex: 7,
            child: Text(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              widget.chat.fileinfo!.filename ?? "unknown file",
              style: TextStyle(color: contentcolor, fontSize: 19),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius _getraduisbyposition() {
    switch (widget.position) {
      case ChatBubblePosition.top:
        if (widget.issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(7));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.middle:
        if (widget.issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(7),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(7));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.bottom:
        if (widget.issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(7),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.alone:
        return const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20));
    }
  }

  Future<void> writefiletocloud(String id) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    upload = storage.ref("/chats/$id").putFile(widget.chat.fileinfo!.file!);
    upload?.snapshotEvents.listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      log(_progress.toString());
      setState(() {});
    });
    final snapshot = await upload?.whenComplete(() {});
    widget.chat.fileinfo!.url = await snapshot?.ref.getDownloadURL();
    if (!context.mounted) return;
    setState(() {});
    await Database.writechat(chat: widget.chat, chatroomid: widget.chatroomid);
    if (widget.chat.fileinfo!.type == FileType.image) {
      // only for images cause file havent been downloaded yet !
      widget.chat.fileinfo!.fileexist = true;
    }
  }

  Widget getcorrespondingbubble() {
    switch (widget.chat.fileinfo?.type) {
      case null:
        return const SizedBox();
      case FileType.media:
        // files
        return fileBubble();
      case FileType.image:
        // image
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Hero(
                tag: widget.chat.fileinfo!.url.toString(),
                child: imageBubble(),
              ),
            ),
            AnimatedOpacity(
                opacity: _progress == 1 || _progress == 0 ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: loadingcontainer()),
          ],
        );
      case FileType.any:
      case FileType.video:
      case FileType.audio:
      case FileType.custom:
        break;
    }
    throw Error();
  }

  void filedownloadtostorage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String mydir = widget.mediavisibility
        ? "${widget.mediapath}/files/FILE${widget.chat.fileinfo!.filename}"
        : "${widget.documentpath}/files/FILE${widget.chat.fileinfo!.filename}";
    File file = File(mydir);
    // creates the file first before writing anything
    file = await file.create(recursive: true);
    download = storage.ref("/chats/${widget.chat.id}").writeToFile(file)
      ..snapshotEvents.listen(
        (event) {
          _progress = event.bytesTransferred / event.totalBytes;
          log(_progress.toString());
          setState(() {});
          if (_progress == 1) {
            widget.chat.fileinfo!.file = file;
            widget.chat.fileinfo!.fileexist = true;
            if (widget.issentfromme) {
              widget.chat.fileinfo!.path = mydir;
            }
            Database.updatechat(widget.chat);
            setState(() {});
          }
        },
      );
  }

  Future<void> imagedownloadtostorage() async {
    initimageexist();
    if (widget.chat.fileinfo!.fileexist) return;
    FirebaseStorage storage = FirebaseStorage.instance;
    String path = widget.issentfromme
        ? widget.chat.fileinfo!.path!
        : widget.mediavisibility
            ? "${widget.mediapath}/images/IMG${widget.chat.id}.jpg"
            : "${widget.documentpath}/images/IMG${widget.chat.id}.jpg";
    File file = File(path);
    file = await file.create(recursive: true);
    storage
        .ref("/chats/${widget.chat.id}")
        .writeToFile(file)
        .snapshotEvents
        .listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      if (!context.mounted) return;
      setState(() {});
    }).onDone(() {
      log("file has been stored");
      widget.chat.fileinfo!.fileexist = true;
      if (widget.issentfromme) {
        widget.chat.fileinfo!.path = path;
      }
      Database.updatechat(widget.chat);
      widget.chat.fileinfo!.file = file;
      if (!context.mounted) return;
      setState(() {});
    });
  }

  void init() async {
    if (!widget.chat.isread && !widget.issentfromme) {
      Database.markchatread(widget.chat).whenComplete(() {
        widget.chat.setread = true;
      });
    }
    if (widget.chat.fileinfo?.file != null &&
        (widget.chat.fileinfo?.url == null ||
            widget.chat.fileinfo?.url == "null")) {
      writefiletocloud(widget.chat.id);
    }
    if (widget.chat.fileinfo?.filename != null) {
      widget.chat.fileinfo?.type = FileType.media;
    } else if (widget.chat.fileinfo?.url != null) {
      widget.chat.fileinfo?.type = FileType.image;
      imagedownloadtostorage();
    }
  }

  void initimageexist() {
    String path = widget.issentfromme
        ? widget.chat.fileinfo!.path!
        : widget.mediavisibility
            ? "${widget.mediapath}/images/IMG${widget.chat.id}.jpg"
            : "${widget.documentpath}/images/IMG${widget.chat.id}.jpg";
    final File file = File(path);
    widget.chat.fileinfo!.fileexist = file.existsSync();
    if (widget.chat.fileinfo!.fileexist) {
      widget.chat.fileinfo!.file = file;
    }
  }

  void initfilepath() {
    if (widget.chat.fileinfo!.file != null && widget.issentfromme) {
      widget.chat.fileinfo!.path = widget.chat.fileinfo!.file!.path;
    }
  }

  void onchatbubbletap() {
    if (widget.chat.fileinfo?.url == null) {
      expandbubble();
    } else if (widget.chat.fileinfo?.type == FileType.image) {
      openImage();
    } else {
      if (widget.chat.fileinfo?.file == null) {
        Toast("File appears to be missing");
        return;
      }
      openfile(widget.chat.fileinfo!.file!);
    }
  }

  void onchatbubbledoubletap() {
    if (widget.chat.fileinfo?.url == null) {
      return;
    }
    expandbubble();
  }

  void expandbubble() {
    setState(() {
      if (ChatBubble.expandedbubble == widget.chat) {
        ChatBubble.expandedbubble = null;
        return;
      }
      ChatBubble.expandedbubble = widget.chat;
    });
  }

  void openImage() async {
    unfocus(context);
    context.push(Routes.imageView, extra: {
      "tag": widget.chat.fileinfo!.url!,
      "url": widget.chat.fileinfo!.url!,
      "file": widget.chat.fileinfo!.file,
      "description": formatdate(widget.chat.time, md),
      "title": widget.chat.sentFrom == widget.myprofile.getPhoneNumber
          ? widget.myprofile.getName
          : widget.otherprofile.getName,
    });
  }

  void removeReaction(String currentEmoji) async {
    // remove the reaction
    widget.chat.reactions[widget.myprofile.getPhoneNumber]!
        .remove(currentEmoji);
    if (widget.chat.reactions.isReactionEmpty) {
      await onreactcontroller.reverse(from: 1);
    }
    widget.chat.reactioncount.decrement(currentEmoji);
    if (widget.chat.reactioncount[currentEmoji] == 0) {
      widget.chat.reactioncount.remove(currentEmoji);
    }
    widget.chat.sortReactionCount();
    setState(() {});

    await Database.writechat(chat: widget.chat, chatroomid: widget.chatroomid);
  }
}
