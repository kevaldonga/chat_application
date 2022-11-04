import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
  UploadTask? upload;
  DownloadTask? download;
  double _progress = 0;
  Directory? dir;
  late bool fileexist;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    if (dir == null) {
      return const SizedBox();
    }
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
                  child: getcorrespondingbubble(),
                ),
              ),
              if (widget.chat.text != null && widget.chat.text != "")
                Padding(
                  padding:
                      (!(widget.chat.file == null && widget.chat.url == null))
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

  Widget fileBubble() {
    fileexist =
        File("${dir!.path}/images/${widget.chat.filename}").existsSync();
    final contentcolor =
        widget.issentfromme ? Colors.white : MyColors.primarySwatch;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 3,
            // icon
            child: GestureDetector(
              onTap: !fileexist && !widget.issentfromme
                  ? download == null
                      ? filedownloadtostorage
                      : null
                  : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_progress != 1)
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 4,
                      color: contentcolor,
                    ),
                  Icon(
                    !fileexist ? Icons.download : Icons.description,
                    color: contentcolor,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          // file name
          Flexible(
            flex: 7,
            child: Text(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              widget.chat.filename ?? "unknown file",
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

  Future<void> writefile(File file, String id) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    upload = storage.ref("/chats/$id").putFile(file);
    upload?.snapshotEvents.listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      setState(() {});
    });
    final snapshot = await upload?.whenComplete(() {});
    widget.chat.url = await snapshot?.ref.getDownloadURL();
    await Database.updatechat(widget.chat);
  }

  Widget getcorrespondingbubble() {
    switch (widget.chat.type) {
      case null:
        return const SizedBox();
      case FileType.any:
        return fileBubble();
      case FileType.media:
        return imageBubble();
      case FileType.image:
      case FileType.video:
      case FileType.audio:
      case FileType.custom:
        break;
    }
    return const SizedBox();
  }

  Widget imageBubble() {
    if (widget.issentfromme) {
      return widget.chat.url == null
          ? loadingcontainer(MediaQuery.of(context))
          : widget.chat.file != null
              ? Image.file(
                  widget.chat.file!,
                  fit: BoxFit.fitWidth,
                )
              : CachedNetworkImage(
                  imageUrl: widget.chat.url!,
                  fit: BoxFit.fitWidth,
                );
    }
    return CachedNetworkImage(
      imageUrl: widget.chat.url!,
      fit: BoxFit.fitWidth,
    );
  }

  void filedownloadtostorage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    final mydir = "${dir!.path}/images/${widget.chat.filename}";
    File file = File(mydir);
    // creates the file first before writing anything
    file = await file.create(recursive: true);
    fileexist = true;
    download = storage.ref("/chats/${widget.chat.id}").writeToFile(file);
    download!.snapshotEvents.listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      setState(() {});
    });
  }

  void init() async {
    dir = await getApplicationDocumentsDirectory();
    if (widget.chat.filename != null) {
      widget.chat.type = FileType.any;
    } else if (widget.chat.url != null) {
      widget.chat.type = FileType.media;
    }
    if (widget.chat.file != null &&
        (widget.chat.url == null || widget.chat.url == "null")) {
      writefile(widget.chat.file!, widget.chat.id);
    }
  }

  void initdir() async {
    dir = await getApplicationDocumentsDirectory();
  }
}
