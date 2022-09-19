import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/widgets/alertdialog.dart';
import 'package:chatty/assets/common/widgets/button_auth.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/constants/validate.dart';
import 'package:chatty/firebase/auth/firebase_auth.dart';
import 'package:chatty/firebase/exceptions/auth_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../assets/common/widgets/textfield_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  String? erroremail, errorpassword;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: MyColors.scaffoldbackground,
        resizeToAvoidBottomInset: false,
        body: Container(
          width: md.size.width,
          height: md.size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage("lib/assets/layout/login.png"),
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 35, top: 82),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Welcome!",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: md.size.height * 0.5 - md.viewInsets.bottom),
              Container(
                margin: EdgeInsets.only(bottom: md.viewInsets.bottom),
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  children: [
                    // email id
                    TextfieldAuth(
                      controller: email,
                      autofill: AutofillHints.email,
                      errorText: erroremail ?? "",
                      hintText: "email",
                      keyboardtype: TextInputType.emailAddress,
                      bordergradient: MyGradients.maingradient,
                    ),
                    const SizedBox(height: 15),
                    // password
                    TextfieldAuth(
                      bordergradient: MyGradients.secondarygradient,
                      controller: password,
                      autofill: AutofillHints.password,
                      errorText: errorpassword ?? "",
                      hintText: "password",
                    ),
                    const SizedBox(height: 20),
                    ButtonAuth(
                        text: "Login",
                        onclick: () async {
                          setState(() {
                            erroremail = validate(Validate.email, email.text);
                            errorpassword =
                                validate(Validate.password, password.text);
                          });
                          if (erroremail!.isEmpty && errorpassword!.isEmpty) {
                            var e = await AuthFirebase.signin(
                                email.text, password.text);
                            if (e == null) {
                              if (!mounted) return;
                              await showbasicdialog(context, "Signed in",
                                  "you have signed in successfully!!");
                              if (!mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                  context, Routes.userview, (_) => false);
                            } else {
                              if (e[0].isNotEmpty) {
                                var a = ExceptionAuth.handleExceptions(e[0]);
                                if (!mounted) return;
                                showbasicdialog(context, a[0], a[1]);
                              } else {
                                if (!mounted) return;
                                showbasicdialog(context, "fatal error",
                                    "unexpected error occured please try again later.");
                              }
                            }
                          }
                        }),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.registerview);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "new user?",
                            style: TextStyle(
                                color: MyColors.seconadaryswatch, fontSize: 16),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "sign up!",
                            style: TextStyle(
                                color: MyColors.primarySwatch, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
