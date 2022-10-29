import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/common/functions/formatdate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets/logic/chat.dart';

class ImageView extends StatefulWidget {
  final Chat chat;
  final String sentFrom;
  const ImageView({super.key, required this.chat, required this.sentFrom});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
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
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          constrained: true,
          clipBehavior: Clip.none,
          child: Hero(
            tag: widget.chat.url!,
            child: CachedNetworkImage(
              imageUrl: widget.chat.url!,
            ),
          ),
        ),
      ),
    );
  }
}
