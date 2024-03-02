import 'package:flutter/material.dart';

import '../../../global/variables/colors.dart';

CircleAvatar getProfileCircleAvatar(bool isitgroup) {
  return CircleAvatar(
    backgroundColor: MyColors.profilebackground,
    child: Icon(
      isitgroup ? Icons.groups_rounded : Icons.person_rounded,
      color: MyColors.profileforeground,
    ),
  );
}
