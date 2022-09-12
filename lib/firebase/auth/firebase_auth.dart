import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthFirebase {
  static FirebaseAuth? _auth;
  static Future<List<String>?> signin(String email, String password) async {
    EasyLoading.show(status: "signing");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      return [e.code,""];
    } on Exception catch (e) {
      EasyLoading.dismiss();
      return ["",e.toString()];
    }
    EasyLoading.dismiss();
    return null;
  }

  static Future<List<String>?> signup(String email, String password,String phone,String name) async {
    EasyLoading.show(status: "signing up");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      return [e.code,""];
    } on Exception catch (e) {
      EasyLoading.dismiss();
      return [e.toString(),""];
    }
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setStringList(email, [
      email,
      phone,
    ]);
    EasyLoading.dismiss();
    return null;
  }

  static Future<List<String>?> signout() async {
    EasyLoading.show(status: "signing out");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.signOut();
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      return [e.code,""];
    } on Exception catch (e) {
      EasyLoading.dismiss();
      return ["",e.toString()];
    }
    EasyLoading.dismiss();
    return null;
  }

  static Future<List<String>?> changeemail(String newEmail) async {
    EasyLoading.show(status: "changing");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      return [e.code,""];
    } on Exception catch (e) {
      EasyLoading.dismiss();
      return ["",e.toString()];
    }
    EasyLoading.dismiss();
    return null;
  }

  static Future<List<String>?> changepassword(String newPassword) async {
    EasyLoading.show(status: "updating");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      return [e.code,""];
    } on Exception catch (e) {
      EasyLoading.dismiss();
      return ["",e.toString()];
    }
    EasyLoading.dismiss();
    return null;
  }

  static Future<List<String>?> verify() async {
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      return [e.code,""];
    } on Exception catch (e) {
      return ["",e.toString()];
    }
    return null;
  }

  static Future<List<Object?>?> refresh() async {
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      return [e.code,""];
    } on Exception catch (e) {
      return ["",e.toString()];
    }
    return null;
  }
}
