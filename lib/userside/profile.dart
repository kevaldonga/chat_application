import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/functions/compressimage.dart';
import 'package:chatty/assets/common/functions/setprofileimage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../assets/logic/profile.dart';
import '../firebase/database/my_database.dart';

class MyProfile extends StatefulWidget {
  Profile profile;
  MyProfile({super.key, required this.profile});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String? url;
  File? file;

  @override
  void initState() {
    url = widget.profile.getPhotourl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    MediaQueryData md = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        onBackPressed();
        return false;
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
        body: ListView(
          children: [
            Center(child: _profilewidget(md)),
            const SizedBox(height: 20),
            Center(
                child: Text(widget.profile.getName,
                    style: const TextStyle(
                        fontSize: 27, fontWeight: FontWeight.w500),
                    softWrap: true)),
            const SizedBox(height: 20),
            Center(
                child: Text(widget.profile.getPhoneNumber,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black45))),
            const SizedBox(height: 20),
            Center(
                child: Text(widget.profile.getEmail,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black45))),
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
    if (file == null) {
      EasyLoading.dismiss();
      Navigator.of(context).pop(widget.profile);
    } else {
      await setuserprofile(file!).then((value) {
        widget.profile.setPhotourl = value;
        EasyLoading.dismiss();
        if (!mounted) return;
        Database.writepersonalinfo(widget.profile).whenComplete(() {
          Navigator.of(context).pop(widget.profile);
        });
      });
    }
  }
}
