import 'package:chatty/assets/colors/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget getuserprofile() {
  String? url = FirebaseAuth.instance.currentUser?.photoURL;
  if (url == null) {
    return const Icon(Icons.face, color: MyColors.primarySwatch);
  } else {
    return Image.network(url);
  }
}
