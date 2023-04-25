import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/Routes.dart';
import 'package:chatty/constants/validate.dart';
import 'package:chatty/firebase/auth/firebase_auth.dart';
import 'package:chatty/firebase/exceptions/auth_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../assets/alertdialog/alertdialog.dart';
import '../../assets/logic/profile.dart';
import '../widgets/button_auth.dart';
import '../widgets/textfield_auth.dart';

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
  String? erroremail, errorpassword, errorphone, errorname;
  Profile? profile;

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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SvgPicture.asset(
            width: md.size.width,
            "lib/assets/layout/register.svg",
            fit: BoxFit.fitWidth,
          ),
          SizedBox(
            width: md.size.width,
            height: md.size.height,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 20),
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
                          autofocus: true,
                          bordergradient: MyGradients.secondarygradient,
                          controller: name,
                          autofill: null,
                          maxlength: 10,
                          errorText: "",
                          hintText: "username",
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
                            onclick: () async {
                              setState(() {
                                erroremail =
                                    validate(Validate.email, email.text);
                                errorpassword =
                                    validate(Validate.password, password.text);
                                errorphone =
                                    validate(Validate.phone, phone.text);
                                errorname = validate(Validate.name, name.text);
                              });
                              if (erroremail!.isEmpty &&
                                  errorpassword!.isEmpty &&
                                  errorphone!.isEmpty) {
                                var e = await AuthFirebase.signup(
                                    Profile(
                                        email: email.text,
                                        name: name.text,
                                        phoneNumber: phone.text,
                                        photourl: ""),
                                    password.text);
                                if (e == null) {
                                  if (!mounted) return;
                                  await showbasicdialog(context, "Signed up",
                                      "you have signed up successfully!!");
                                  if (!mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, Routes.userview, (_) => false);
                                } else {
                                  if (e[0].isNotEmpty) {
                                    var a =
                                        ExceptionAuth.handleExceptions(e[0]);
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
