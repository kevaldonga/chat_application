import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';
import 'getprofilecircle.dart';

class CustomAppbar extends SliverPersistentHeaderDelegate {
  final Object herotag;
  final String name;
  final String? url;
  final String phoneno;
  double screenWidth;
  Tween<double>? profilePicTranslateTween;
  final VoidCallback onbackpressed;

  CustomAppbar({
    required this.onbackpressed,
    required this.herotag,
    required this.screenWidth,
    this.url,
    required this.phoneno,
    required this.name,
  }) {
    profilePicTranslateTween =
        Tween<double>(begin: screenWidth / 2 - 45 - 40 + 15, end: 50);
  }
  static final appBarColorTween = ColorTween(
      begin: MyColors.scaffoldbackground, end: MyColors.primarySwatch);

  static final appbarIconColorTween =
      ColorTween(begin: MyColors.primarySwatch, end: Colors.white);

  static final phoneNumberTranslateTween = Tween<double>(begin: 20.0, end: 0.0);

  static final phoneNumberFontSizeTween = Tween<double>(begin: 20.0, end: 16.0);

  static final profileImageRadiusTween = Tween<double>(begin: 3.5, end: 1.0);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final relativeScroll = min(shrinkOffset, 45) / 45;
    final relativeScroll70px = min(shrinkOffset, 70) / 70;

    return Container(
      color: appBarColorTween.transform(relativeScroll),
      child: Stack(
        children: [
          Stack(
            children: [
              // back
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: onbackpressed,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 25),
                  color: appbarIconColorTween.transform(relativeScroll),
                ),
              ),
              // more
              Positioned(
                right: 0,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 25),
                  color: appbarIconColorTween.transform(relativeScroll),
                ),
              ),
              // name
              Positioned(
                  top: 15,
                  left: 90,
                  child: displayName(relativeScroll70px, name)),
              // profile picture
              Positioned(
                  top: 5,
                  left: profilePicTranslateTween!.transform(relativeScroll70px),
                  child:
                      displayProfilePicture(relativeScroll70px, url, herotag)),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayProfilePicture(
      double relativeFullScrollOffset, String? url, Object herotag) {
    return Transform(
        transform: Matrix4.identity()
          ..scale(
            profileImageRadiusTween.transform(relativeFullScrollOffset),
          ),
        child: Hero(tag: herotag, child: profilewidget(url, 40)));
  }

  Widget displayName(double relativeFullScrollOffset, String name) {
    if (relativeFullScrollOffset >= 0.8) {
      return Transform(
        transform: Matrix4.identity()
          ..translate(
            0.0,
            phoneNumberTranslateTween
                .transform((relativeFullScrollOffset - 0.8) * 5),
          ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            name,
            style: TextStyle(
              fontSize: phoneNumberFontSizeTween
                  .transform((relativeFullScrollOffset - 0.8) * 5),
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(CustomAppbar oldDelegate) {
    return true;
  }
}

class PhoneAndName extends StatelessWidget {
  final String phoneno, name;
  const PhoneAndName({Key? key, required this.phoneno, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 35),
        Text(
          "~$name",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          phoneno,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
