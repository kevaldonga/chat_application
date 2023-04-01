import 'package:chatty/assets/logic/groupInfo.dart';
import 'package:chatty/firebase/database/my_database.dart';
import 'package:chatty/userside/dashview/common/widgets/chatroomitem_shimmer.dart';
import 'package:flutter/material.dart';

import 'groupinfoitem.dart';

class CommonGroupList extends StatefulWidget {
  final List<String> phonenos;
  // [myphoneno , userprofile phoneno]
  const CommonGroupList({super.key, required this.phonenos});

  @override
  State<CommonGroupList> createState() => _CommonGroupListState();
}

class _CommonGroupListState extends State<CommonGroupList> {
  List<GroupInfo>? commongroups;
  late MediaQueryData md;
  bool intialized = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "groups in common",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (!intialized)
            SizedBox(
              height: md.size.height * 0.3,
              child: ListView.builder(
                itemCount: 10,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => const ShimmerChatRoomItem(),
              ),
            ),
          if (intialized)
            ...List.generate(commongroups!.length, (index) {
              return chatroomitem(
                  isitgroup: true,
                  url: commongroups![index].photourl,
                  name: commongroups![index].name,
                  bio: commongroups![index].bio,
                  md: md);
            }),
        ],
      ),
    );
  }

  void init() async {
    // get uid by phoneno
    List<String> uids = [];
    uids.add(await Database.getuid(widget.phonenos[0]));
    uids.add(await Database.getuid(widget.phonenos[1]));

    // get common chatrooms by both uids
    Database.getCommonGroupChatRoomids(uids).then((groupinfos) {
      commongroups = groupinfos;
      intialized = true;
      if (!mounted) return;
      setState(() {});
    });
  }
}
