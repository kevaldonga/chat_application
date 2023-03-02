import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerChatRoomActivity extends StatelessWidget {
  final highlightColor = Colors.grey.shade300;
  final baseColor = Colors.grey.shade50;

  ShimmerChatRoomActivity({super.key});
  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      width: md.size.width,
      child: ListView(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(20, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Shimmer.fromColors(
              enabled: true,
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Align(
                alignment: Random().nextBool()
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: (md.size.width * (Random().nextDouble() * 50 / 100)) +
                      md.size.width * 0.2,
                  height: md.size.height * 0.035,
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
