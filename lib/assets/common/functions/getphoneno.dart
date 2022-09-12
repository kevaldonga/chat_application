import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getphoneno() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.get(FirebaseAuth.instance.currentUser?.email ?? "").toString();
}