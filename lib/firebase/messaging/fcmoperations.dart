import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../private/fcm.dart';

class FCMOperations {
  static Future<void> update(String token) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("fcmTokens")
        .doc(uid)
        .set({"token": token});

    log("token updated to $token");
  }

  static Future<String?> get(String uid) async {
    final snapshot =
        await FirebaseFirestore.instance.collection("fcmTokens").doc(uid).get();

    return snapshot.exists ? snapshot.data()!["token"] : null;
  }

  static Future<bool> send(
      List<String> tokens, Map<String, dynamic> data) async {
    final Uri uri = Uri.parse("https://fcm.googleapis.com/fcm/send");
    final http.Response response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${FCM.serverKey}'
        },
        body: jsonEncode({
          "registration_ids": tokens,
          "data": data,
        }));

    return response.statusCode == 200;
  }
}
