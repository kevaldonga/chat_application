import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../logic/chat.dart';
import '../functions/formatdate.dart';

class ChatBubble extends StatefulWidget {
  static Chat? expandedbubble;
  final EdgeInsetsGeometry? margin;
  final ChatBubblePosition position;
  bool issentfromme;
  Chat chat;
  ChatBubble({
    super.key,
    this.margin,
    required this.chat,
    required this.position,
    required this.issentfromme,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  UploadTask? task;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    if (widget.chat.url != null || widget.chat.url != "null") {
      widget.chat.isiturl = true;
    }
    if (widget.chat.file != null &&
        (widget.chat.url == null || widget.chat.url == "null")) {
      writefile(widget.chat.file!, widget.chat.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: widget.issentfromme
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints.loose(
              Size.fromWidth(MediaQuery.of(context).size.width * 0.75)),
          padding: widget.chat.file != null || widget.chat.url != null
              ? const EdgeInsets.all(7)
              : const EdgeInsets.only(left: 22, right: 22, top: 8, bottom: 12),
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: _getraduisbyposition(),
            gradient:
                widget.issentfromme ? MyGradients.maingradientvertical : null,
            color: !widget.issentfromme ? Colors.white : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Hero(
                  tag: widget.chat.url.toString(),
                  child: widget.chat.file != null
                      ? widget.chat.url != null || widget.chat.url != "null"
                          ? Image.file(widget.chat.file!, fit: BoxFit.fitWidth)
                          : loadingcontainer(md)
                      : widget.chat.url != null
                          ? CachedNetworkImage(
                              imageUrl: widget.chat.url!,
                              fit: BoxFit.fitWidth,
                            )
                          : const SizedBox(),
                ),
              ),
              if (widget.chat.text.isNotEmpty)
                Padding(
                  padding:
                      (!(widget.chat.file == null && widget.chat.url == null))
                          ? const EdgeInsets.only(left: 7, top: 5, bottom: 5)
                          : EdgeInsets.zero,
                  child: Text(
                    widget.chat.text,
                    style: TextStyle(
                      color: widget.issentfromme
                          ? Colors.white
                          : MyColors.textprimary,
                      fontSize: 20,
                    ),
                  ),
                ),
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
                    size: widget.chat == ChatBubble.expandedbubble ? 22 : 0),
              const SizedBox(width: 5),
              Text(formatdate(widget.chat.time, md)),
            ],
          ),
        ),
      ],
    );
  }

  Container loadingcontainer(MediaQueryData md) {
    return Container(
      color: Colors.white,
      height: md.size.width * 0.4,
      width: md.size.width * 0.4,
      padding: EdgeInsets.all(md.size.width * 0.4),
      child: CircularProgressIndicator(
        color: MyColors.primarySwatch,
        value: _progress,
        strokeWidth: 4,
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

  Future<void> writefile(File file, String id) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    task = storage.ref("/chats/$id").putFile(file);
    task?.snapshotEvents.listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      log(_progress.toString());
      if (!mounted) return;
      setState(() {});
    });
    final snapshot = await task?.whenComplete(() {});
    widget.chat.url = await snapshot?.ref.getDownloadURL();
    widget.chat.isiturl = true;
    await Database.updatechat(widget.chat);
  }
}
