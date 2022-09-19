import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>> getpersonalinfo(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentSnapshot snapshot = await db
      .collection("users")
      .doc(uid)
      .get();
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  log("retrived data - ${data.toString()}");
  return data;
}
