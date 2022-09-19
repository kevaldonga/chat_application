import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
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
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.loose(
          Size.fromWidth(MediaQuery.of(context).size.width * 0.6)),
      padding: const EdgeInsets.only(left: 22, right: 22, top: 8, bottom: 12),
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: _getraduisbyposition(),
        gradient: widget.issentfromme ? MyGradients.maingradientvertical : null,
        color: !widget.issentfromme ? Colors.white : null,
      ),
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.issentfromme ? Colors.white : MyColors.textprimary,
          fontSize: 20,
        ),
      ),
    );
  }

  BorderRadius _getraduisbyposition() {
    switch (widget.position) {
      case ChatBubblePosition.top:
        if (widget.issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(0));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.middle:
        if (widget.issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(0));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(20));
        }
      case ChatBubblePosition.bottom:
        if (widget.issentfromme) {
          return const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(0),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20));
        } else {
          return const BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20));
        }
    }
  }
}
