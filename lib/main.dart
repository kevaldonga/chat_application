import 'package:chatty/global/SystemChannels/path.dart';
import 'package:chatty/global/variables/colors.dart';
import 'package:chatty/firebase/database/firebase_options.dart';
import 'package:chatty/routing/router.dart';
import 'package:chatty/userside/dashview/screens/userview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive/hive.dart';

import 'userside/auth/screens/login_view.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // preserving bindings
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // data caching with local storage
  Hive.init(await PathProvider.documentDirectory());

  // status bar decoration
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));

  // firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'chatty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: MyColors.splashColor,
        highlightColor: MyColors.highlightColor,
        focusColor: MyColors.focusColor,
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
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dialogTheme: const DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: MyColors.scaffoldbackground),
      ),
      builder: EasyLoading.init(),
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
