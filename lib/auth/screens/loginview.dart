import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/layout/login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 47, top: 82),
              child: const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Welcome!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 400),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextfieldAuth(
                    controller: email,
                    autofill: AutofillHints.email,
                    errorText: "",
                    hintText: "email",
                    keyboardtype: TextInputType.emailAddress,
                    bordercolor: MyColors.textfieldborder1,
                  ),
                  TextfieldAuth(
                    bordercolor: MyColors.textfieldborder2,
                    controller: password,
                    autofill: AutofillHints.password,
                    errorText: "",
                    hintText: "password",
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text("new user? sign up!"),
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
