import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> setuserprofile(File file) async{
  final uid = FirebaseAuth.instance.currentUser?.uid;
  FirebaseStorage ref = FirebaseStorage.instance;
  final task = ref.ref("/profileImages/$uid").putFile(file);
  final snapshot = await task.whenComplete((){});
  return await snapshot.ref.getDownloadURL();
}