import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/userside/chatroom/common/functions/openfile.dart';
import 'package:chatty/userside/dashview/common/widgets/popupmenuitem.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../../../../assets/SystemChannels/path.dart';
import '../../../../assets/colors/colors.dart';

class ImageView extends StatefulWidget {
  final String title, description;
  final File? file;
  final String url;
  final String tag;
  const ImageView({
    super.key,
    this.file,
    required this.tag,
    required this.title,
    required this.description,
    required this.url,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

enum popupmenu {
  save,
  viewinGallery,
}

class _ImageViewState extends State<ImageView> {
  bool progress = false;
  @override
  Widget build(BuildContext context) {
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
                    child: const Row(
                      children: [
                        Icon(Icons.save, color: MyColors.seconadaryswatch),
                        SizedBox(width: 30),
                        Text("save"),
                      ],
                    ),
                    height: 20,
                  ),
                  popupMenuItem(
                    value: popupmenu.viewinGallery,
                    child: const Row(
                      children: [
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
              onSelected: (value) {
                switch (value) {
                  case popupmenu.save:
                    if (widget.file != null) {
                      // save image to gallery
                      saveimage(widget.file!.path);
                    } else {
                      // save image first to temp directory from cloud
                      downloadimage(whenComplete: (file) {
                        saveimage(file.path);
                      });
                    }
                    break;
                  case popupmenu.viewinGallery:
                    if (widget.file != null) {
                      // open the file
                      openfile(widget.file!);
                    } else {
                      // download image to temporary directory
                      downloadimage(whenComplete: (file) {
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
              widget.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
            Text(
              widget.description,
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
            tag: widget.tag,
            child: widget.file == null
                ? CachedNetworkImage(
                    imageUrl: widget.url,
                    fit: BoxFit.fitWidth,
                  )
                : Image.file(
                    widget.file!,
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
    String? docpath = await PathProvider.documentDirectory();
    String path = "$docpath/profile/IMG.jpg";
    File file = File(path);
    return file;
  }

  void downloadimage({required Function(File file) whenComplete}) async {
    File file = await savetoTempPath();
    file = await file.create(recursive: true);
    FirebaseStorage.instance
        .refFromURL(widget.url)
        .writeToFile(file)
        .whenComplete(() {
      whenComplete(file);
    });
  }
}
