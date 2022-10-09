import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final ChatBubblePosition position;
  final bool issentfromme;
  final String text;
  const ChatBubble(
      {super.key,
      required this.margin,
      required this.position,
      required this.issentfromme,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.loose(
          Size.fromWidth(MediaQuery.of(context).size.width * 0.6)),
      padding: const EdgeInsets.only(left: 22, right: 22, top: 8, bottom: 12),
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: _getraduisbyposition(),
        gradient: issentfromme ? MyGradients.maingradientvertical : null,
        color: !issentfromme ? Colors.white : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: issentfromme ? Colors.white : MyColors.textprimary,
          fontSize: 20,
        ),
      ),
    );
  }

  BorderRadius _getraduisbyposition() {
    switch (position) {
      case ChatBubblePosition.top:
        if (issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(7));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.middle:
        if (issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(7),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(7));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(7),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.bottom:
        if (issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(7),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(7),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.alone:
        return const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20));
    }
  }
}
