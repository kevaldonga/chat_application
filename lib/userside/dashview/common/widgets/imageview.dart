import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/SystemChannels/path.dart';
import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/userside/chatroom/common/functions/openfile.dart';
import 'package:chatty/userside/dashview/common/widgets/popupmenuitem.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/logic/chat.dart';
import '../../../chatroom/common/functions/formatdate.dart';

class ImageView extends StatefulWidget {
  final Chat chat;
  final String sentFrom;
  const ImageView({super.key, required this.chat, required this.sentFrom});

  @override
  State<ImageView> createState() => _ImageViewState();
}

enum popupmenu {
  save,
  viewinGallery,
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
                    height: 20,
                  ),
                  popupMenuItem(
                    value: popupmenu.viewinGallery,
                    child: Row(
                      children: const [
                        Icon(Icons.remove_red_eye,
                            color: MyColors.seconadaryswatch),
                        SizedBox(width: 30),
                        Text("view in gallery"),
                      ],
                    ),
                    height: 20,
                  ),
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case popupmenu.save:
                    if (widget.chat.fileinfo!.file != null) {
                      // save image to gallery
                      saveimage(widget.chat.fileinfo!.file!.path);
                    } else {
                      // save image first to temp directory from cloud
                      downloadimagetotemp(whenComplete: (file) {
                        saveimage(file.path);
                      });
                    }
                    break;
                  case popupmenu.viewinGallery:
                    if (widget.chat.fileinfo!.file != null) {
                      // open the file
                      openfile(widget.chat.fileinfo!.file!);
                    } else {
                      // download image to temporary directory
                      downloadimagetotemp(whenComplete: (file) {
                        openfile(file);
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
          statusBarColor: Colors.black,
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
            tag: widget.chat.fileinfo!.url.toString(),
            child: widget.chat.fileinfo!.file == null
                ? CachedNetworkImage(
                    imageUrl: widget.chat.fileinfo!.url!,
                    fit: BoxFit.fitWidth,
                  )
                : Image.file(
                    widget.chat.fileinfo!.file!,
                    fit: BoxFit.fitWidth,
                  ),
          ),
        ),
      ),
    );
  }

  void saveimage(String path) {
    GallerySaver.saveImage(path).then((value) {
      Toast("image saved successfully!");
    }).onError((error, stackTrace) {
      Toast("There was error occured - $error");
    });
  }

  Future<File> savetoTempPath() async {
    String? temppath = await PathProvider.tempDirectory();
    String path = "$temppath/IMG${widget.chat.id}.jpg";
    File file = File(path);
    return file;
  }

  void downloadimagetotemp({required Function(File file) whenComplete}) async {
    File file = await savetoTempPath();
    file = await file.create(recursive: true);
    FirebaseStorage.instance
        .ref("chats/${widget.chat.id}")
        .writeToFile(file)
        .whenComplete(() {
      whenComplete(file);
    });
  }
}
