import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';

CircleAvatar getProfileCircleAvatar() {
  return const CircleAvatar(
    backgroundColor: MyColors.profilebackground,
    child: Icon(
      Icons.person_rounded,
      color: MyColors.profileforeground,
    ),
  );
}
