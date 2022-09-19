import 'package:flutter/material.dart';


Widget profilewidget(String url,double size){
  return ClipOval(
      child: Container(
        color: Colors.white,
        width: size,
        height: size,
        child: Image.network(url, fit: BoxFit.cover)
      ),
    );
}