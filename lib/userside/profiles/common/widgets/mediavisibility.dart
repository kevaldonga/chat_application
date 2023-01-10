import 'package:chatty/assets/alertdialog/alertdialog.dart';
import 'package:chatty/assets/alertdialog/alertdialog_action_button.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/logic/FirebaseUser.dart';

class MediaVisibility extends StatefulWidget {
  String id;
  FirebaseUser user;
  MediaVisibility({super.key, required this.user, required this.id});

  @override
  State<MediaVisibility> createState() => _MediaVisibilityState();
}

class _MediaVisibilityState extends State<MediaVisibility> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 10, right: 10),
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.black12,
          borderRadius: BorderRadius.circular(13),
          onTap: () async {
            await showdialog(
              context: context,
              title: const Text(
                "Do you want your media to be displayed in gallery ?",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
              contents: StatefulBuilder(
                builder: (context, insidestate) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // yes
                      customRadioListTile(
                        activeColor: MyColors.primarySwatch,
                        title: const Text("Yes"),
                        value: true,
                        groupValue:
                            widget.user.mediavisibility[widget.id] ?? true,
                        onChanged: (newvalue) {
                          if (newvalue == null) return;
                          insidestate(() {
                            widget.user.mediavisibility[widget.id] = newvalue;
                          });
                        },
                      ),
                      // no
                      customRadioListTile(
                        activeColor: MyColors.primarySwatch,
                        title: const Text("No"),
                        value: false,
                        groupValue:
                            widget.user.mediavisibility[widget.id] ?? true,
                        onChanged: (newvalue) {
                          if (newvalue == null) return;
                          insidestate(() {
                            widget.user.mediavisibility[widget.id] = newvalue;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              actions: [
                alertdialogactionbutton("OK", () {
                  setState(() {
                    Navigator.of(context)
                        .pop(widget.user.mediavisibility[widget.id] ?? true);
                  });
                  Database.setmediavisibility(
                      FirebaseAuth.instance.currentUser!.uid, widget.user);
                }),
                alertdialogactionbutton("CANCEL", () {
                  Navigator.of(context).pop(null);
                }),
              ],
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Media visibility",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.user.mediavisibility[widget.id] ?? true ? "On" : "Off",
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                    color: MyColors.textsecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customRadioListTile({
    required Color activeColor,
    required Widget title,
    required bool value,
    required bool groupValue,
    required Function(bool?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.black12,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onChanged(value);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Radio(
                activeColor: MyColors.primarySwatch,
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
              ),
              title,
            ],
          ),
        ),
      ),
    );
  }
}
