import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatdate(DateTime dateTime, MediaQueryData md) {
  return md.alwaysUse24HourFormat
      ? DateFormat("HH:mm a").format(dateTime)
      : DateFormat("hh:mm a").format(dateTime);
}

String formatdatebyday(DateTime dateTime) {
  return DateFormat("d MMMM yyyy").format(dateTime);
}
