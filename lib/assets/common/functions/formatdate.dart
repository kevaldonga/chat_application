import 'package:intl/intl.dart';

String formatdate(DateTime dateTime){
  return DateFormat("hh:mm a").format(dateTime);
}