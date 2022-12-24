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
import '../common/widgets/buildcircle.dart';

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
  late FocusNode namefocusnode, biofocusnode;
  int focusedindex = 0;

  @override
  void initState() {
    setupfocuslisteners();
    initcontrollers();
    super.initState();
  }

  @override
  void dispose() {
    biofocusnode.dispose();
    namefocusnode.dispose();
    bio.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    md = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        isdatachanged();
        bool a = await showdialog(
          context,
          const Text("Are you sure ?"),
          const Text("are you sure you want to update your profile ?"),
          [
            alertdialogactionbutton(
                "YES", () => Navigator.of(context).pop(true)),
            alertdialogactionbutton(
                "NO", () => Navigator.of(context).pop(false)),
          ],
        );
        if (a) {
          onBackPressed();
        }
        return !a;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.only(top: md.viewPadding.top + 60),
                child: Center(child: _profilewidget(md)),
              ),
              SizedBox(height: md.size.height * 0.07),
              listItem(TextFieldType.name, 1),
              listItem(TextFieldType.bio, 2),
              listItem(TextFieldType.phone, 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profilewidget(MediaQueryData md) {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? picker;
        picker = await FilePicker.platform
            .pickFiles(allowMultiple: false, type: FileType.image);
        if (picker == null) return;
        file = await compressimage(File(picker.files.single.path!), 80);
        setState(() {});
      },
      child: Stack(
        children: [
          _buildimage(md),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildcircle(
              color: Colors.white,
              padding: 4,
              child: buildcircle(
                color: MyColors.primarySwatch,
                padding: 10,
                child: const Icon(Icons.edit, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildimage(MediaQueryData md) {
    return Hero(
      tag: url.toString(),
      transitionOnUserGestures: true,
      child: ClipOval(
        child: Container(
          color: MyColors.profilebackground,
          width: md.size.width / 3,
          height: md.size.width / 3,
          child: file == null
              ? url == null || url == "null"
                  ? const Icon(Icons.person_rounded,
                      size: 70, color: MyColors.profileforeground)
                  : CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover)
              : Image.file(file!, fit: BoxFit.cover),
        ),
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

  Widget listItem(TextFieldType type, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: md.size.width,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
            width: 2,
            color: focusedindex == index
                ? MyColors.primarySwatch
                : Colors.black38),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Icon(
              type == TextFieldType.name
                  ? Icons.person_rounded
                  : type == TextFieldType.phone
                      ? Icons.call_rounded
                      : Icons.info_outline_rounded,
              color: focusedindex == index
                  ? MyColors.primarySwatch
                  : Colors.black38,
            ),
          ),
          Expanded(
            flex: 20,
            child: type != TextFieldType.phone
                ? TextField(
                    maxLength: type == TextFieldType.name ? 10 : 50,
                    maxLines: type == TextFieldType.bio ? 4 : 1,
                    focusNode: type == TextFieldType.name
                        ? namefocusnode
                        : biofocusnode,
                    controller: type == TextFieldType.name ? name : bio,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      helperStyle: TextStyle(
                        fontSize: 0,
                      ),
                      counterStyle: TextStyle(
                        fontSize: 0,
                      ),
                      isCollapsed: true,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    widget.profile.getPhoneNumber,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void initcontrollers() {
    name = TextEditingController(text: widget.profile.getName);
    bio = TextEditingController(
        text: widget.profile.bio == null || widget.profile.bio == "null"
            ? ""
            : widget.profile.bio);
    url = widget.profile.photourl;
  }

  void setupfocuslisteners() {
    namefocusnode = FocusNode();
    biofocusnode = FocusNode();
    namefocusnode.addListener(() {
      if (namefocusnode.hasFocus) {
        focusedindex = 1;
      } else {
        focusedindex = 0;
      }
      setState(() {});
    });
    biofocusnode.addListener(() {
      if (biofocusnode.hasFocus) {
        focusedindex = 2;
      } else {
        focusedindex = 0;
      }
      setState(() {});
    });
  }

  void isdatachanged() {
    if (widget.profile.getName != name.text &&
        widget.profile.bio != bio.text &&
        file == null) {
      Navigator.of(context).pop(widget.profile);
    }
  }
}
