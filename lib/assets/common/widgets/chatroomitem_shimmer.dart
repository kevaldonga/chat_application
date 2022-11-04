import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerChatRoomItem extends StatefulWidget {
  const ShimmerChatRoomItem({super.key});

  @override
  State<ShimmerChatRoomItem> createState() => ShimmerChatRoomItemState();
}

class ShimmerChatRoomItemState extends State<ShimmerChatRoomItem> {
  final highlightColor = Colors.grey.shade300;
  final baseColor = Colors.grey.shade50;
  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return Container(
      height: md.size.height * 0.1,
      width: md.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // profile
          profile(md),
          SizedBox(width: md.size.width * 0.08),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // title
              title(md),
              SizedBox(height: md.size.height * 0.01),
              // content
              content(md),
            ],
          ),
        ],
      ),
    );
  }

  Shimmer profile(MediaQueryData md) {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: ShimmerDirection.ltr,
      child: ClipOval(
          child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        height: md.size.height * 0.07,
        width: md.size.height * 0.07,
      )),
    );
  }

  Shimmer content(MediaQueryData md) {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: ShimmerDirection.ltr,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          width: md.size.width * 0.5,
          height: md.size.height * 0.017),
    );
  }

  Shimmer title(MediaQueryData md) {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: baseColor,
      highlightColor: highlightColor,
      direction: ShimmerDirection.ltr,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          width: md.size.width * 0.3,
          height: md.size.height * 0.017),
    );
  }
}
