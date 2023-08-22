import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/global/functions/unfocus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../../chatroom/common/functions/formatdate.dart';
import '../../../profiles/common/widgets/getprofilecircle.dart';
import 'notificationbubble.dart';

class ChatRoomItem extends StatelessWidget {
  final bool isitgroup;
  final String id;
  final String title, description;
  final DateTime? date;
  final bool? read;
  final bool? top;
  final String? url;
  final int notificationcount;
  final TextEditingController searchcontroller;
  final VoidCallback ontap;
  const ChatRoomItem({
    super.key,
    required this.isitgroup,
    required this.id,
    required this.url,
    required this.read,
    required this.top,
    required this.notificationcount,
    required this.searchcontroller,
    required this.ontap,
    required this.date,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: top != null
            ? const BorderRadius.vertical(top: Radius.circular(35))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          borderRadius: top != null
              ? const BorderRadius.vertical(top: Radius.circular(35))
              : null,
          onTap: ontap,
          child: Container(
            width: md.size.width,
            height: md.size.height * 0.1,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
              borderRadius: top != null
                  ? const BorderRadius.vertical(top: Radius.circular(35))
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Hero(
                  tag: id,
                  child: GestureDetector(
                    onTap: () {
                      if (url == null || url == "null" || url == "") {
                        return;
                      }
                      unfocus(context);
                      context.push(Routes.imageView, extra: {
                        "tag": id,
                        "title": title,
                        "url": url!,
                        "description":
                            "${isitgroup ? "group" : "$title's"} profile",
                      });
                    },
                    child: profilewidget(url, md.size.width * 0.12, isitgroup),
                  ),
                ),
                SizedBox(width: md.size.width * 0.08),
                middleactions(),
                endactions(md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Flexible endactions(MediaQueryData md) {
    return Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (date != null)
            Center(
                widthFactor: 0,
                child: Text(
                  formatdate(date!, md),
                  softWrap: false,
                  overflow: TextOverflow.visible,
                )),
          notificationcount == 0 && read == null
              ? Container()
              : notificationcount == 0
                  ? Icon(Icons.check,
                      color:
                          read! ? MyColors.primarySwatch : MyColors.textprimary)
                  : notificationbubble(notificationcount,
                      Size(md.size.width * 0.07, md.size.width * 0.07)),
        ],
      ),
    );
  }

  Flexible middleactions() {
    return Flexible(
      flex: 5,
      fit: FlexFit.tight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SubstringHighlight(
              overflow: TextOverflow.ellipsis,
              caseSensitive: false,
              maxLines: 1,
              term: searchcontroller.text,
              textStyleHighlight: const TextStyle(
                color: MyColors.seconadaryswatch,
              ),
              text: title,
              textStyle: const TextStyle(
                  fontSize: 19,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            SubstringHighlight(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              caseSensitive: false,
              term: searchcontroller.text,
              textStyleHighlight: const TextStyle(
                color: MyColors.seconadaryswatch,
              ),
              text: description,
              textStyle: const TextStyle(
                fontSize: 15,
                color: MyColors.textsecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
