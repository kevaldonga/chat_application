import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/functions/formatdate.dart';
import 'package:flutter/material.dart';

import 'notificationbubble.dart';

class ChatRoomItem extends StatefulWidget {
  final String title, description;
  final DateTime date;
  final bool? read;
  final bool? top;
  final String? url;
  final int? notificationcount;
  final VoidCallback ontap;
  const ChatRoomItem({
    this.url,
    super.key,
    this.read,
    this.top,
    this.notificationcount,
    required this.ontap,
    required this.date,
    required this.title,
    required this.description,
  });

  @override
  State<ChatRoomItem> createState() => _ChatRoomItemState();
}

class _ChatRoomItemState extends State<ChatRoomItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return GestureDetector(
      onTap: widget.ontap,
      child: Container(
        width: md.size.width,
        height: md.size.height * 0.1,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12, width: 1),
          borderRadius: widget.top != null
              ? const BorderRadius.vertical(top: Radius.circular(35))
              : null,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            widget.url == null ? 
            const CircleAvatar(
              child: Icon(Icons.face,color: MyColors.primarySwatch),
            ) : 
            Image.network(widget.url!),
            SizedBox(width: md.size.width * 0.08),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(widget.description,
                    style: const TextStyle(
                        fontSize: 15,
                        color: MyColors.textsecondary,
                        fontWeight: FontWeight.normal)),
              ],
            ),
            SizedBox(width: md.size.width * 0.4),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(formatdate(widget.date)),
                widget.notificationcount == null
                    ? Icon(Icons.check,
                        color: widget.read!
                            ? MyColors.primarySwatch
                            : MyColors.textprimary)
                    : notificationbubble(
                        widget.notificationcount!, Size(md.size.width * 0.08, md.size.width * 0.08)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
