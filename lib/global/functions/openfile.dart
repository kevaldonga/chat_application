import 'dart:io';

import '../SystemChannels/intent.dart' as intent;
import '../SystemChannels/toast.dart';

void openfile(File file) {
  // if file exist in at the moment open it
  if (file.existsSync()) {
    intent.Intent.openfile(file);
    return;
  } else {
    Toast("file doesnt exist !!");
  }
}
