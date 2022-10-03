
import 'package:flutter/material.dart';


Widget profilewidget(String url,final double size){
  return ClipOval(
    clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        width: size,
        height: size,
        child: Image.network(url, fit: BoxFit.cover)
      ),
    );
}