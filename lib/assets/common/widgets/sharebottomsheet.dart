import 'package:flutter/material.dart';

void showbottomsheet(
    {required BuildContext context, required List<Widget> items}) {
  FocusScope.of(context).unfocus();
  showModalBottomSheet(
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              direction: Axis.horizontal,
              children: items,
            ),
          ),
        );
      });
}

Material shareItem({
  required BuildContext context,
  required Color backgroundcolor,
  required IconData icon,
  required VoidCallback ontap,
}) {
  MediaQueryData md = MediaQuery.of(context);
  return Material(
    color: Colors.transparent,
    child: InkWell(
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundcolor,
            ),
            width: md.size.height * 0.1,
            height: md.size.height * 0.1,
            child: Icon(
              size: 35,
              icon,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
