import 'dart:io';

import 'package:chatty/assets/colors/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../assets/logic/profile.dart';
import '../../profiles/common/functions/compressimage.dart';

enum MemberType {
  admin,
  rookie,
}

class CreateGroup extends StatefulWidget {
  final List<Profile> users;
  final List<Profile> admins;

  const CreateGroup({
    super.key,
    required this.users,
    required this.admins,
  });

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  File? file;
  late MediaQueryData md;
  TextEditingController groupname = TextEditingController();
  TextEditingController groupdescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "New Group",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: MyColors.primarySwatch,
        leading: IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.white38,
          splashRadius: 30,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // profile
              _profilewidget(md),
              // group name
              const TextField(
                maxLines: 1,
                decoration: InputDecoration(
                  label: Text("name"),
                  hintText: "give Group a name",
                ),
              ),
            ],
          ),
          // group description
          const TextField(
            maxLines: 10,
            decoration: InputDecoration(
              label: Text("description..."),
              hintText: "give Group a descrption",
            ),
          ),
          const Text("admins"),
          ListView.builder(
            itemBuilder: (context, index) =>
                memberItem(MemberType.admin, widget.admins[index]),
          ),
          const Text("members"),
          ListView.builder(
            itemBuilder: (context, index) =>
                memberItem(MemberType.rookie, widget.users[index]),
          ),
        ],
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
            ? const Icon(Icons.person, size: 70, color: MyColors.primarySwatch)
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

  memberItem(MemberType admin, Profile profile) {}
}
