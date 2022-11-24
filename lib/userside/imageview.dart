import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/common/functions/formatdate.dart';
import 'package:chatty/assets/common/widgets/popupmenuitem.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../assets/colors/colors.dart';
import '../assets/logic/chat.dart';

class ImageView extends StatefulWidget {
  final Chat chat;
  final String sentFrom;
  const ImageView({super.key, required this.chat, required this.sentFrom});

  @override
  State<ImageView> createState() => _ImageViewState();
}

enum popupmenu {
  save,
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: PopupMenuButton(
              clipBehavior: Clip.antiAlias,
              splashRadius: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              enabled: true,
              itemBuilder: (context) {
                return [
                  popupMenuItem(
                      value: popupmenu.save,
                      child: Row(
                        children: const [
                          Icon(Icons.save, color: MyColors.seconadaryswatch),
                          SizedBox(width: 30),
                          Text("save"),
                        ],
                      ),
                      height: 20),
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case popupmenu.save:
                    final dir = await getDownloadsDirectory();
                    String path =
                        "${dir!.path}/chatty/images/IMG${widget.chat.id}.jpg";
                    File file = File(path);
                    file = await file.create(recursive: true);
                    if (file.existsSync()) return;
                    if (widget.chat.file == null) {
                      urltostorage(file);
                    } else {
                      await widget.chat.file!.copy(path).then((value) {
                        log("${value.path} has been saved to storage");
                      });
                    }
                    break;
                }
              },
              child: const Icon(Icons.more_vert_rounded, color: Colors.white),
            ),
          ),
        ],
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sentFrom,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
            Text(
              formatdate(widget.chat.time, md),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
            ),
          ],
        ),
        backgroundColor: Colors.black26,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          constrained: true,
          clipBehavior: Clip.none,
          child: Hero(
            tag: widget.chat.url.toString(),
            child: widget.chat.file == null
                ? CachedNetworkImage(
                    imageUrl: widget.chat.url!,
                    fit: BoxFit.fitWidth,
                  )
                : Image.file(
                    widget.chat.file!,
                    fit: BoxFit.fitWidth,
                  ),
          ),
        ),
      ),
    );
  }

  void urltostorage(File file) async {
    FirebaseStorage.instance.ref("chats/${widget.chat.id}").writeToFile(file);
  }
}
