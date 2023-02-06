import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';

CircleAvatar getProfileCircleAvatar(bool isitgroup) {
  return CircleAvatar(
    backgroundColor: MyColors.profilebackground,
    child: Icon(
      isitgroup ? Icons.groups_rounded : Icons.person_rounded,
      color: MyColors.profileforeground,
    ),
  );
}
