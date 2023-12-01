import 'dart:developer';
import 'dart:io';

import 'package:chatty/assets/SystemChannels/path.dart';
import 'package:chatty/assets/logic/chat.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/firebase/messaging/fcmoperations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

class FCMService {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static void setup() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    final String token = await messaging.getToken() ?? "";
    await FCMOperations.update(token);

    messaging.onTokenRefresh
        .listen((token) async => await FCMOperations.update(token));

    FirebaseMessaging.onMessage.listen(
      (remoteMessage) => onMessage(remoteMessage, false),
    );
    FirebaseMessaging.onBackgroundMessage(
      (remoteMessage) => onMessage(remoteMessage, true),
    );
  }

  static Future<void> onMessage(RemoteMessage message, bool from) async {
    log("${message.messageId} received from ${from ? "background" : "foreground"}");

    final data = message.data;

    Profile sentFrom = Profile.fromMap(data: data["sentFrom"]);
    Chat chat = Chat.fromMap(chat: data["chat"]);
    final String? url = sentFrom.photourl;
    String? path;

    if (url != null) {
      final String? tempPath = await PathProvider.tempDirectory();
      if (tempPath == null) throw ErrorDescription("error getting temp path");

      Response response = await get(Uri.parse(url));
      File file = await File("$tempPath/$url").writeAsBytes(response.bodyBytes);
      path = file.path;
    }

    // create notification
    NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
      "14112",
      "messaging_notification_channel",
      icon: path,
    ));
  }
}
