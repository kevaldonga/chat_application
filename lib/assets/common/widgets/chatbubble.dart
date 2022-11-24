import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../logic/chat.dart';
import '../../logic/profile.dart';
import '../functions/formatdate.dart';

class ChatBubble extends StatefulWidget {
  static Chat? expandedbubble;
  final EdgeInsetsGeometry? margin;
  final ChatBubblePosition position;
  bool issentfromme;
  Chat chat;
  Profile? profile;
  final Directory dir;
  ChatBubble({
    super.key,
    this.profile,
    this.margin,
    required this.dir,
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
  late MediaQueryData md;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: widget.issentfromme
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints:
              BoxConstraints.loose(Size.fromWidth(md.size.width * 0.75)),
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
              if (widget.profile != null && !widget.issentfromme)
                Padding(
                  padding: widget.chat.type != null
                      ? EdgeInsets.symmetric(
                          horizontal:
                              widget.chat.type == FileType.media ? 10 : 0,
                          vertical: widget.chat.type == FileType.media ? 5 : 0,
                        )
                      : EdgeInsets.zero,
                  child: Text(
                    widget.profile!.getName,
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

  Widget imageBubble() {
    initimageexist();
    if (widget.chat.file?.lengthSync() == 0) return cachedimage();
    return widget.chat.file != null ? fileimage() : cachedimage();
  }

  Image fileimage() {
    return Image.file(
      widget.chat.file!,
      fit: BoxFit.fitWidth,
      gaplessPlayback: true,
    );
  }

  CachedNetworkImage cachedimage() {
    return CachedNetworkImage(
      cacheKey: widget.chat.url!,
      imageUrl: widget.chat.url!,
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
    String path = "${widget.dir.path}/files/${widget.chat.filename}";
    widget.chat.fileexist = File(path).existsSync();
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
              onTap: !widget.chat.fileexist && !widget.issentfromme
                  ? download == null
                      ? filedownloadtostorage
                      : null
                  : null,
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
                    widget.issentfromme || widget.chat.fileexist
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

  Future<void> writefiletocloud(File file, String id) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    upload = storage.ref("/chats/$id").putFile(file);
    upload?.snapshotEvents.listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      log(_progress.toString());
      setState(() {});
    });
    final snapshot = await upload?.whenComplete(() {});
    widget.chat.url = await snapshot?.ref.getDownloadURL();
    setState(() {});
    await Database.updatechat(widget.chat);
  }

  Widget getcorrespondingbubble() {
    switch (widget.chat.type) {
      case null:
        return const SizedBox();
      case FileType.any:
        // files
        return fileBubble();
      case FileType.media:
        // image
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Hero(
                tag: widget.chat.url.toString(),
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
      case FileType.image:
      case FileType.video:
      case FileType.audio:
      case FileType.custom:
        break;
    }
    throw Error();
  }

  void filedownloadtostorage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    final mydir = "${widget.dir.path}/files/${widget.chat.filename}";
    File file = File(mydir);
    // creates the file first before writing anything
    file = await file.create(recursive: true);
    download = storage.ref("/chats/${widget.chat.id}").writeToFile(file);
    download!.snapshotEvents.listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> imagedownloadtostorage() async {
    initimageexist();
    if (widget.chat.fileexist) return;
    FirebaseStorage storage = FirebaseStorage.instance;
    File file = File("${widget.dir.path}/images/IMG${widget.chat.id}.jpg");
    file = await file.create(recursive: true);
    storage
        .ref("/chats/${widget.chat.id}")
        .writeToFile(file)
        .snapshotEvents
        .listen((event) {
      _progress = event.bytesTransferred / event.totalBytes;
      if (!mounted) return;
      setState(() {});
    }).onDone(() {
      log("file has been stored");
      widget.chat.fileexist = true;
      Database.updatechat(widget.chat);
      widget.chat.file = file;
      if (!mounted) return;
      setState(() {});
    });
  }

  void init() async {
    if (widget.chat.file != null &&
        (widget.chat.url == null || widget.chat.url == "null")) {
      writefiletocloud(widget.chat.file!, widget.chat.id);
    }
    if (widget.chat.filename != null) {
      widget.chat.type = FileType.any;
    } else if (widget.chat.url != null) {
      imagedownloadtostorage();
      widget.chat.type = FileType.media;
    }
  }

  void initimageexist() {
    String path = "${widget.dir.path}/images/IMG${widget.chat.id}.jpg";
    final File file = File(path);
    widget.chat.fileexist = file.existsSync();
    if (widget.chat.fileexist) {
      widget.chat.file = file;
    }
  }
}
