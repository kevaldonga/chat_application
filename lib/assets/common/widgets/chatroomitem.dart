import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/functions/formatdate.dart';
import 'package:chatty/assets/common/widgets/getprofilewidget.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';

import 'notificationbubble.dart';

class ChatRoomItem extends StatefulWidget {
  final String title, description;
  final DateTime? date;
  final bool? read;
  final bool? top;
  final String? url;
  int? notificationcount = 0;
  final TextEditingController searchcontroller;
  final VoidCallback ontap;
  ChatRoomItem({
    this.url,
    super.key,
    this.read,
    this.top,
    this.notificationcount,
    required this.searchcontroller,
    required this.ontap,
    this.date,
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
    widget.searchcontroller.addListener(onchanged);
  }

  @override
  void dispose() {
    if (!mounted) return;
    widget.searchcontroller.removeListener(onchanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.top != null
            ? const BorderRadius.vertical(top: Radius.circular(35))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          borderRadius: widget.top != null
              ? const BorderRadius.vertical(top: Radius.circular(35))
              : null,
          onTap: widget.ontap,
          child: Container(
            width: md.size.width,
            height: md.size.height * 0.1,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
              borderRadius: widget.top != null
                  ? const BorderRadius.vertical(top: Radius.circular(35))
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                widget.url == null && widget.url == "null"
                    ? const CircleAvatar(
                        child: Icon(Icons.face, color: MyColors.primarySwatch),
                      )
                    : profilewidget(widget.url!, md.size.width * 0.12),
                SizedBox(width: md.size.width * 0.08),
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubstringHighlight(
                          caseSensitive: false,
                          term: widget.searchcontroller.text,
                          textStyleHighlight: const TextStyle(
                            color: MyColors.seconadaryswatch,
                          ),
                          text: widget.title,
                          textStyle: const TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      SubstringHighlight(
                        caseSensitive: false,
                        term: widget.searchcontroller.text,
                        textStyleHighlight: const TextStyle(
                          color: MyColors.seconadaryswatch,
                        ),
                        text: widget.description,
                        textStyle: const TextStyle(
                            fontSize: 15,
                            color: MyColors.textsecondary,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.date != null)
                        Center(
                            widthFactor: 0,
                            child: Text(formatdate(widget.date!))),
                      widget.notificationcount == 0 && widget.read == null
                          ? Container()
                          : widget.notificationcount == 0
                              ? Icon(Icons.check,
                                  color: widget.read!
                                      ? MyColors.primarySwatch
                                      : MyColors.textprimary)
                              : notificationbubble(
                                  widget.notificationcount!,
                                  Size(md.size.width * 0.08,
                                      md.size.width * 0.08)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onchanged() {
    setState(() {});
  }
}
