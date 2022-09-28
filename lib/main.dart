import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/auth/screens/register_view.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/firebase/generated/firebase_options.dart';
import 'package:chatty/userside/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'auth/screens/login_view.dart';
import 'userside/userview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chatty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // ignore: deprecated_member_use
        accentColor: MyColors.scaffoldbackground,
        brightness: Brightness.light,
        hintColor: MyColors.textsecondary,
        dialogBackgroundColor: Colors.white,
        platform: TargetPlatform.android,
        primaryColor: MyColors.seconadaryswatch,
        scaffoldBackgroundColor: MyColors.scaffoldbackground,
        appBarTheme: const AppBarTheme(
          color: MyColors.primarySwatch,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          shadowColor: Colors.black12,
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          iconColor: MyColors.primarySwatch,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
      home: const MyHomePage(),
      builder: EasyLoading.init(),
      routes: {
        Routes.loginview: (context) => const LoginView(),
        Routes.registerview: (context) => const RegisterView(),
        Routes.userview: (context) => const UserView(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
        ? const UserView()
        : const LoginView();
  }
}
