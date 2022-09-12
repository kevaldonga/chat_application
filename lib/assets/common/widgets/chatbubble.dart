import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/constants/chatbubble_position.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  ChatBubblePosition position;
  final bool issentfromme;
  final String text;
  ChatBubble(
      {super.key,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
              widget.position == ChatBubblePosition.top ? 20 : 0),
          topRight: Radius.circular(!widget.issentfromme ? 20 : 0),
          bottomLeft: Radius.circular(
              widget.position != ChatBubblePosition.middle ||
                      widget.issentfromme
                  ? 20
                  : 0),
          bottomRight: Radius.circular(
              widget.position != ChatBubblePosition.middle ||
                      !widget.issentfromme
                  ? 20
                  : 0),
        ),
        gradient: widget.issentfromme ? MyGradients.maingradientvertical : null,
        color: !widget.issentfromme ? Colors.white : null,
      ),
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.issentfromme ? Colors.white : MyColors.textprimary,
          fontSize: 26,
        ),
      ),
    );
  }
}
