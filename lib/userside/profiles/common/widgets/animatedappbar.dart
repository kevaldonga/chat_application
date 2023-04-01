import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';
import 'buildcircle.dart';
import 'getprofilecircle.dart';

class CustomAppbar extends SliverPersistentHeaderDelegate {
  bool isitgroup;
  bool areyouadmin;
  final Object herotag;
  final String name;
  final String? url;
  double screenWidth;
  List<PopupMenuItem>? items;
  Function(dynamic value)? onSelected;
  Tween<double>? profilePicTranslateTween;
  final VoidCallback onbackpressed;
  VoidCallback? onprofiletap;
  File? file;

  CustomAppbar({
    this.onprofiletap,
    this.url,
    this.areyouadmin = false,
    this.file,
    this.items,
    this.onSelected,
    required this.isitgroup,
    required this.onbackpressed,
    required this.herotag,
    required this.screenWidth,
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

  static final editIconTween = Tween<double>(begin: 1, end: 0);

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
              if (items != null)
                Positioned(
                  right: 0,
                  child: PopupMenuButton(
                    clipBehavior: Clip.antiAlias,
                    splashRadius: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabled: true,
                    itemBuilder: (context) {
                      return items!;
                    },
                    onSelected: onSelected,
                    icon: Icon(
                      Icons.more_vert,
                      size: 25,
                      color: appbarIconColorTween.transform(relativeScroll),
                    ),
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
        child: GestureDetector(
          onTap: areyouadmin ? onprofiletap : null,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Hero(
                  tag: herotag,
                  child: file != null
                      ? ClipOval(
                          child: SizedBox.fromSize(
                            size: const Size(40, 40),
                            child: Image.file(file!, fit: BoxFit.cover),
                          ),
                        )
                      : profilewidget(url, 40, isitgroup)),
              if (areyouadmin)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Opacity(
                    opacity: editIconTween.transform(relativeFullScrollOffset),
                    child: buildcircle(
                      color: Colors.white,
                      padding: 1,
                      child: buildcircle(
                        color: MyColors.primarySwatch,
                        padding: 3,
                        child: const Icon(Icons.edit,
                            size: 6, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
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
  final String? description;
  final String name;
  const PhoneAndName({Key? key, required this.description, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 35),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (description != null)
          Text(
            description!,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        const SizedBox(height: 30),
      ],
    );
  }
}
