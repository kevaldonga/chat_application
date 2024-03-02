import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/userside/profiles/widgets/getprofilecircleavatar.dart';
import 'package:flutter/material.dart';

Widget profilewidget(String? url, final double size, bool isitgroup) {
  return ClipOval(
    clipBehavior: Clip.antiAlias,
    child: SizedBox(
        width: size,
        height: size,
        child: url == null || url == "null"
            ? getProfileCircleAvatar(isitgroup)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                useOldImageOnUrlChange: true,
              )),
  );
}
