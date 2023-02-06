import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../../assets/logic/chat.dart';
import '../../../../assets/logic/profile.dart';
import '../../../../constants/enumFIleType.dart';
import '../functions/formatdate.dart';

class ChatBubble extends StatefulWidget {
  static Chat? expandedbubble;
  final EdgeInsetsGeometry? margin;
  final ChatBubblePosition position;
  bool issentfromme;
  Chat chat;
  Profile? profile;
  bool mediavisibility;
  final String documentpath, mediapath;
  ChatBubble({
    super.key,
    this.profile,
    this.margin,
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
          padding: widget.chat.fileinfo?.file != null ||
                  widget.chat.fileinfo?.url != null
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
                  padding: widget.chat.fileinfo?.type != null
                      ? EdgeInsets.symmetric(
                          horizontal:
                              widget.chat.fileinfo?.type == FileType.image
                                  ? 10
                                  : 15,
                          vertical: widget.chat.fileinfo?.type == FileType.image
                              ? 5
                              : 0,
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
    bool shoulddownload = !widget.chat.fileinfo!.fileexist && download == null;
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
    if (!mounted) return;
    setState(() {});
    await Database.updatechat(widget.chat);
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
      if (!mounted) return;
      setState(() {});
    }).onDone(() {
      log("file has been stored");
      widget.chat.fileinfo!.fileexist = true;
      if (widget.issentfromme) {
        widget.chat.fileinfo!.path = path;
      }
      Database.updatechat(widget.chat);
      widget.chat.fileinfo!.file = file;
      if (!mounted) return;
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
    } else {
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
}
