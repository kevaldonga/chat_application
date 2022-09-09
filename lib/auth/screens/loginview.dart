import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/widgets/button_auth.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/constants/validate.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
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
                      onclick: () {
                        setState(() {
                          erroremail = validate(Validate.email, email.text);
                          errorpassword =
                              validate(Validate.password, password.text);
                        });
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
    );
  }
}
