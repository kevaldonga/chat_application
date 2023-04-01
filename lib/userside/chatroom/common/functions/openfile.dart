import 'dart:io';

import '../../../../assets/SystemChannels/intent.dart' as intent;
import '../../../../assets/SystemChannels/toast.dart';

void openfile(File file) {
  // if file exist in at the moment open it
  if (file.existsSync()) {
    intent.Intent.openfile(file);
    return;
  } else {
    Toast("file doesnt exist !!");
  }
}
