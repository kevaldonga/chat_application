import 'dart:io';

import 'package:chatty/userside/auth/screens/login_view.dart';
import 'package:chatty/userside/auth/screens/register_view.dart';
import 'package:chatty/routing/routes.dart';
import 'package:chatty/main.dart';
import 'package:chatty/userside/chatroom/screens/chatroom_activity.dart';
import 'package:chatty/userside/dashview/widgets/imageview.dart';
import 'package:chatty/userside/dashview/screens/create_group_activity.dart';
import 'package:chatty/userside/dashview/screens/fabactions.dart';
import 'package:chatty/userside/dashview/screens/userview.dart';
import 'package:chatty/userside/profiles/screens/groupprofile.dart';
import 'package:chatty/userside/profiles/screens/myprofile.dart';
import 'package:chatty/userside/profiles/screens/userprofile.dart';
import 'package:chatty/utils/chat.dart';
import 'package:chatty/utils/chatroom.dart';
import 'package:chatty/utils/firebase_user.dart';
import 'package:chatty/utils/profile.dart';
import 'package:go_router/go_router.dart';

final GoRouter router =
    GoRouter(initialLocation: Routes.homePage, routes: <GoRoute>[
  GoRoute(
    name: "Homepage",
    path: Routes.homePage,
    builder: (context, state) => const MyHomePage(),
  ),
  GoRoute(
    name: "Loginview",
    path: Routes.loginView,
    builder: (context, state) => const LoginView(),
  ),
  GoRoute(
    name: "Registerview",
    path: Routes.registerView,
    builder: (context, state) => const RegisterView(),
  ),
  GoRoute(
    name: "Userview",
    path: Routes.userView,
    builder: (context, state) => const UserView(),
  ),
  GoRoute(
    name: "Myprofile",
    path: Routes.myProfile,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final Profile profile = data["myprofile"] as Profile;
      return MyProfile(profile: profile);
    },
  ),
  GoRoute(
    name: "Imageview",
    path: Routes.imageView,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final tag = data["tag"] as String;
      final title = data["title"] as String;
      final description = data["description"] as String;
      final url = data["url"] as String;
      final file = data["file"] as File?;

      return ImageView(
        file: file,
        tag: tag,
        title: title,
        description: description,
        url: url,
      );
    },
  ),
  GoRoute(
    name: "Userprofile",
    path: Routes.userProfile,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final sentData = data["sentData"] as Map<String, String>;
      final user = data["user"] as FirebaseUser;
      final myprofile = data["myprofile"] as Profile;
      final profile = data["profile"] as Profile;
      final blockedBy = data["blockedBy"] as Map<String, bool>;
      final chatroomid = data["chatroomid"] as String;
      final chats = data["chats"] as List<Chat>;

      return UserProfile(
        chats: chats,
        chatroomid: chatroomid,
        user: user,
        blockedby: blockedBy,
        sentData: sentData,
        profile: profile,
        myprofile: myprofile,
      );
    },
  ),
  GoRoute(
    name: "Groupprofile",
    path: Routes.groupProfile,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final myphoneno = data["myphoneno"] as String;
      final mediachats = data["mediachats"] as List<Chat>;
      final sentData = data["sentData"] as Map<String, String>;
      final user = data["user"] as FirebaseUser;
      final chatroom = data["chatroom"] as ChatRoom;

      return GroupProfile(
        myphoneno: myphoneno,
        mediachats: mediachats,
        chatroom: chatroom,
        sentData: sentData,
        user: user,
      );
    },
  ),
  GoRoute(
      name: "FABactions",
      path: Routes.fabActions,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final profile = data["profile"] as Profile;
        final chatrooms = data["chatrooms"] as List<ChatRoom>;
        final user = data["user"] as FirebaseUser;

        return FabActions(profile, chatrooms, user);
      }),
  GoRoute(
    name: "Chatroomactivity",
    path: Routes.chatroomActivity,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final user = data["user"] as FirebaseUser;
      final chatroom = data["chatroom"] as ChatRoom;

      return ChatRoomActivity(user: user, chatroom: chatroom);
    },
  ),
  GoRoute(
    name: "Creategroupactivity",
    path: Routes.createGroupActivity,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final users = data["users"] as List<Profile>;
      final admins = data["admins"] as List<Profile>;

      return CreateGroup(users: users, admins: admins);
    },
  ),
]);
