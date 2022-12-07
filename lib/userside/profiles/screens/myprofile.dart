import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../assets/alertdialog/alertdialog.dart';
import '../../../assets/alertdialog/alertdialog_action_button.dart';
import '../../../assets/logic/profile.dart';
import '../../../firebase/database/my_database.dart';
import '../common/functions/compressimage.dart';
import '../common/functions/setprofileimage.dart';

enum TextFieldType {
  name,
  phone,
  bio,
}

class MyProfile extends StatefulWidget {
  Profile profile;
  MyProfile({super.key, required this.profile});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String? url;
  File? file;
  late TextEditingController name;
  late TextEditingController bio;
  late MediaQueryData md;

  @override
  void initState() {
    name = TextEditingController(text: widget.profile.getName);
    bio = TextEditingController(
        text: widget.profile.bio == null || widget.profile.bio == "null"
            ? ""
            : widget.profile.bio);
    url = widget.profile.photourl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    md = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        bool a = await showdialog(
          context,
          const Text("Are you sure ?"),
          const Text("are you sure you want to update your profile ?"),
          [
            alertdialogactionbutton(
                "yes", () => Navigator.of(context).pop(true)),
            alertdialogactionbutton(
                "no", () => Navigator.of(context).pop(false)),
          ],
        );
        if (a) {
          onBackPressed();
        }
        return !a;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          leading: BackButton(
              color: MyColors.seconadaryswatch, onPressed: onBackPressed),
          backgroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(child: _profilewidget(md)),
            SizedBox(height: md.size.height * 0.07),
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 25,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  listItem(TextFieldType.name),
                  listItem(TextFieldType.bio),
                  listItem(TextFieldType.phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilewidget(MediaQueryData md) {
    return Stack(
      children: [
        _buildimage(md),
        Positioned(
          bottom: 0,
          right: 4,
          child: _buildcircle(
            color: Colors.white,
            padding: 4,
            child: _buildcircle(
              color: MyColors.primarySwatch,
              padding: 10,
              child: GestureDetector(
                  onTap: () async {
                    FilePickerResult? picker;
                    picker = await FilePicker.platform
                        .pickFiles(allowMultiple: false, type: FileType.image);
                    if (picker == null) return;
                    file = await compressimage(
                        File(picker.files.single.path!), 80);
                    setState(() {});
                  },
                  child: const Icon(Icons.edit, size: 20, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildimage(MediaQueryData md) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        width: md.size.width / 3,
        height: md.size.width / 3,
        child: file == null
            ? url == null || url == "null"
                ? const Icon(Icons.person,
                    size: 70, color: MyColors.primarySwatch)
                : CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover)
            : Image.file(file!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildcircle(
      {required color, required double padding, Widget? child}) {
    return ClipOval(
      child: Container(
        color: color,
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }

  void onBackPressed() async {
    EasyLoading.show(status: "saving");
    if (name.text != widget.profile.getName) {
      widget.profile.setName = name.text;
    }
    if (bio.text != widget.profile.bio) {
      widget.profile.bio = bio.text;
    }
    if (file != null) {
      await setuserprofile(file!).then((value) {
        widget.profile.photourl = value;
        EasyLoading.dismiss();
        if (!mounted) return;
        Database.writepersonalinfo(widget.profile).whenComplete(() {
          EasyLoading.dismiss();
          Navigator.of(context).pop(widget.profile);
        });
      });
    } else {
      Database.writepersonalinfo(widget.profile).whenComplete(() {
        EasyLoading.dismiss();
        Navigator.of(context).pop(widget.profile);
      });
    }
  }

  Widget listItem(TextFieldType type) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Icon(
              type == TextFieldType.name
                  ? Icons.person_rounded
                  : type == TextFieldType.phone
                      ? Icons.phone_rounded
                      : Icons.info_outline_rounded,
              color: MyColors.textsecondary,
            ),
          ),
          Flexible(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type == TextFieldType.name
                      ? "Name"
                      : type == TextFieldType.bio
                          ? "About"
                          : "Phone",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: MyColors.textsecondary,
                  ),
                ),
                type != TextFieldType.phone
                    ? SizedBox(
                        width: md.size.width * 0.6,
                        child: TextField(
                          controller: type == TextFieldType.name ? name : bio,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: MyColors.focusColor,
                                width: 2,
                              ),
                            ),
                            enabledBorder: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : Flexible(
                        flex: 8,
                        child: Text(
                          widget.profile.getPhoneNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
