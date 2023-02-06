import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';
import 'getprofilecircle.dart';

Widget chatroomitem({
  String? url,
  String? bio,
  Widget? endactions,
  required bool isitgroup,
  bool amIadmin = false,
  required String name,
  required MediaQueryData md,
  VoidCallback? onitemtap,
}) {
  return Container(
    color: Colors.white,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        highlightColor: Colors.transparent,
        splashColor: Colors.black26,
        onTap: amIadmin ? onitemtap : null,
        child: Container(
            padding: const EdgeInsets.all(10),
            width: md.size.width,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profilewidget(url, md.size.width * 0.12, isitgroup),
                SizedBox(width: md.size.width * 0.08),
                middleactions(bio, name, md),
                if (endactions != null) endactions,
              ],
            )),
      ),
    ),
  );
}

Widget middleactions(String? bio, String name, MediaQueryData md) {
  return Container(
    constraints: BoxConstraints.tightFor(width: md.size.width * 0.45),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // item name
        Text(
          name,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: const TextStyle(
            fontSize: 19,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        // item bio
        if (bio != null)
          Text(
            bio,
            softWrap: false,
            style: const TextStyle(
              fontSize: 15,
              color: MyColors.textsecondary,
              fontWeight: FontWeight.normal,
            ),
          ),
      ],
    ),
  );
}
