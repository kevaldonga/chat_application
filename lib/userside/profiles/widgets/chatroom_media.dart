import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/routing/routes.dart';
import 'package:chatty/global/functions/formatdate.dart';
import 'package:chatty/utils/chat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatroomMedia extends StatelessWidget {
  final List<Chat> chats;
  final Map<String, String> sentdata; // {"phoneno" : "name"}
  final double height;
  const ChatroomMedia({
    super.key,
    required this.chats,
    required this.height,
    required this.sentdata,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, top: 10),
            child: Text(
              "Media",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: height + 10,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: chats.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 10 : 3,
                    right: index == chats.length - 1 ? 10 : 3,
                  ),
                  height: height,
                  width: height,
                  child: item(context, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget item(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => context.push(Routes.imageView, extra: {
        "tag": chats[index].fileinfo!.url!,
        "url": chats[index].fileinfo!.url!,
        "file": chats[index].fileinfo!.file,
        "description": formatdate(chats[index].time, MediaQuery.of(context)),
        "title": sentdata[chats[index].sentFrom]!,
      }),
      child: Hero(
        tag: chats[index].fileinfo!.url!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: chats[index].fileinfo!.file != null &&
                  chats[index].fileinfo!.file?.lengthSync() != 0
              ? Image.file(
                  chats[index].fileinfo!.file!,
                  gaplessPlayback: true,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: chats[index].fileinfo!.url!,
                  fit: BoxFit.cover,
                  useOldImageOnUrlChange: true,
                ),
        ),
      ),
    );
  }
}
