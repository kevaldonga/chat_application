import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/widgets/button_auth.dart';
import 'package:chatty/constants/validate.dart';
import 'package:flutter/material.dart';

import '../../assets/common/widgets/textfield_auth.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  String? erroremail, errorpassword, errorphone;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Scaffold(
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
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 35, top: 82),
              child: const Text(
                "Register.",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 200 - (md.viewInsets.bottom / 2)),
            Container(
              margin: EdgeInsets.only(bottom: md.viewInsets.bottom),
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // name
                  TextfieldAuth(
                    bordergradient: MyGradients.secondarygradient,
                    controller: name,
                    autofill: null,
                    errorText: "",
                    hintText: "name",
                  ),
                  const SizedBox(height: 15),
                  // phone no
                  TextfieldAuth(
                    controller: phone,
                    autofill: AutofillHints.telephoneNumber,
                    errorText: errorphone ?? "",
                    hintText: "phone no",
                    maxlength: 10,
                    keyboardtype: TextInputType.phone,
                    bordergradient: MyGradients.maingradient,
                  ),
                  const SizedBox(height: 15),
                  // email id
                  TextfieldAuth(
                    bordergradient: MyGradients.primaryGradient,
                    controller: email,
                    keyboardtype: TextInputType.emailAddress,
                    autofill: AutofillHints.email,
                    errorText: erroremail ?? "",
                    hintText: "email",
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
                      text: "Sign up",
                      onclick: () {
                        setState(() {
                          erroremail = validate(Validate.email, email.text);
                          errorpassword =
                              validate(Validate.password, password.text);
                          errorphone = validate(Validate.phone, phone.text);
                        });
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
