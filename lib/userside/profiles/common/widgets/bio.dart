import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';

Widget bioWidget({required String? bio, required String name}) {
  return Container(
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.only(top: 25, left: 10, right: 10),
    width: double.maxFinite,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(13),
      color: Colors.white,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bio",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          bio != null && bio != "null" && bio != ""
              ? bio
              : "bio haven't been specified yet.",
          softWrap: true,
          style: const TextStyle(
            fontSize: 15,
            color: MyColors.textsecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
