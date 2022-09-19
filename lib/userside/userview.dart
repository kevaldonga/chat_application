import 'package:chatty/assets/colors/colors.dart';
import 'package:chatty/assets/common/functions/getpersonalinfo.dart';
import 'package:chatty/assets/common/widgets/chatroomitem.dart';
import 'package:chatty/assets/common/widgets/textfield_main.dart';
import 'package:chatty/assets/logic/firebaseuser.dart';
import 'package:chatty/assets/logic/profile.dart';
import 'package:chatty/userside/chatroom_activity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  TextEditingController searchcontroller = TextEditingController();
  late FirebaseAuth auth;
  late Profile profile;
  late FirebaseUser user;
  @override
  void initState() {
    auth = FirebaseAuth.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getpersonalinfo(auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          profile = Profile.fromMap(data: snapshot.data!);
          MediaQueryData md = MediaQuery.of(context);
          EasyLoading.dismiss();
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              backgroundColor: MyColors.scaffoldbackground,
              body: SizedBox(
                width: md.size.width,
                height: md.size.height,
                child: CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: md.padding.top)),
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: SizedBox(
                        height: 55,
                        child: TextFieldmain(
                            leading: const Icon(
                              Icons.search_rounded,
                              color: MyColors.textsecondary,
                            ),
                            ending: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: MyColors.textsecondary,
                                )),
                            hintText: "search...",
                            contentPadding:
                                const EdgeInsets.only(bottom: 15, top: 15),
                            controller: searchcontroller),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverList(delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ChatRoomItem(
                          top: index == 0 ? true : null,
                          ontap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ChatRoomActivity(profiles: [profile]);
                            }));
                          },
                          date: DateTime.now(),
                          title: "hello",
                          description: "hii",
                          notificationcount: index != 0 ? 1 : null,
                          read: index == 0 ? true : null,
                        );
                      },
                      childCount: 10,
                    )),
                  ],
                ),
              ),
              extendBody: true,
            ),
          );
        } else {
          EasyLoading.show();
          return Container();
        }
      },
    );
  }
}
