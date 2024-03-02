import 'package:chatty/global/SystemChannels/toast.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/utils/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthFirebase {
  static FirebaseAuth? _auth;
  static Future<List<String>?> signin(String email, String password) async {
    Toast("signing in...");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return ["", e.toString()];
    }
    return null;
  }

  static Future<List<String>?> signup(Profile profile, String password) async {
    Toast("signing up...");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.createUserWithEmailAndPassword(
          email: profile.getEmail, password: password);
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return [e.toString(), ""];
    }
    Database.writepersonalinfo(profile);
    Database.setuid(
        profile.getPhoneNumber, FirebaseAuth.instance.currentUser!.uid);
    return null;
  }

  static Future<List<String>?> signout() async {
    Toast("signing out...");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.signOut();
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return ["", e.toString()];
    }
    return null;
  }

  static Future<List<String>?> changeemail(String newEmail) async {
    Toast("changing email...");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return ["", e.toString()];
    }
    return null;
  }

  static Future<List<String>?> changepassword(String newPassword) async {
    Toast("updating...");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return ["", e.toString()];
    }
    return null;
  }

  static Future<List<String>?> verify() async {
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return ["", e.toString()];
    }
    return null;
  }

  static Future<List<Object?>?> refresh() async {
    Toast("refrshing...");
    _auth ??= FirebaseAuth.instance;
    try {
      await _auth?.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      return [e.code, ""];
    } on Exception catch (e) {
      return ["", e.toString()];
    }
    return null;
  }

  static Future<void> deleteAccount(Profile profile,
      {required String uid}) async {
    _auth ??= FirebaseAuth.instance;
    // remove the profile photo from storage
    if (profile.photourl != null) {
      FirebaseStorage.instance.refFromURL(profile.photourl!);
    }

    await _auth?.currentUser?.delete();
  }
}
