import 'package:chatty/assets/common/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';
import 'package:chatty/assets/colors/colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phoneno = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    phoneno.dispose();
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
                  "Register.",
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
                    controller: name,
                    autofill: AutofillHints.name,
                    errorText: "",
                    hintText: "name",
                    keyboardtype: TextInputType.emailAddress,
                    bordercolor: MyColors.textfieldborder1,
                  ),
                  TextfieldAuth(
                    bordercolor: MyColors.textfieldborder2,
                    controller: phoneno,
                    keyboardtype: TextInputType.phone,
                    errorText: "",
                    hintText: "phone no",
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
