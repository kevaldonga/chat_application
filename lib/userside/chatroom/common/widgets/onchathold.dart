import 'dart:developer';

import 'package:chatty/assets/SystemChannels/toast.dart';
import 'package:chatty/assets/alertdialog/alertdialog_action_button.dart';
import 'package:chatty/userside/chatroom/common/functions/isreaction_empty.dart';
import 'package:chatty/userside/profiles/common/widgets/groupinfoitem.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../assets/colors/colors.dart';
import '../../../../assets/logic/profile.dart';

enum ExtraOperations {
  addReaction,
  viewReactions,
}

void onchathold({
  required List<Profile> profiles,
  required String whattocopy,
  required String toasttextoncopied,
  required BuildContext context,
  required bool isitme,
  required String myphoneno,
  required Profile sentFrom,
  VoidCallback? onchatdelete,
  required Map<String, int> reactionCount,
  required Map<String, List<String>> reactions,
  required Function(String emoji) onReacted,
  required void Function(String currentEmoji) onReactionRemoved,
}) async {
  FocusScope.of(context).requestFocus(FocusNode());
  ExtraOperations? data = await showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return BottomSheetView(
        reactionCount: reactionCount,
        reactions: reactions,
        isitme: isitme,
        sentFrom: sentFrom,
        onchatdelete: onchatdelete,
        onReacted: onReacted,
        whattocopy: whattocopy,
        toasttextoncopied: toasttextoncopied,
      );
    },
  );
  if (data == ExtraOperations.addReaction) {
    // ignore: use_build_context_synchronously
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return EmojiPickerView(
          sentFrom: sentFrom,
          onReacted: onReacted,
        );
      },
    );
  } else if (data == ExtraOperations.viewReactions) {
    // ignore: use_build_context_synchronously
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return ViewReactions(
            onReactionRemoved: onReactionRemoved,
            myphoneno: myphoneno,
            profiles: profiles,
            reactionCount: reactionCount,
            reactions: reactions);
      },
    );
  }
}

class BottomSheetView extends StatelessWidget {
  BottomSheetView({
    super.key,
    this.onchatdelete,
    required this.isitme,
    required this.sentFrom,
    required this.onReacted,
    required this.whattocopy,
    required this.toasttextoncopied,
    required this.reactionCount,
    required this.reactions,
  });

  final Color backemojipanel = Colors.grey.shade100;
  final List<String> emojiList = [
    "😊",
    "😃",
    "😂",
    "👍",
    "🥰",
  ];

  final Map<String, List<String>> reactions;
  final Map<String, int> reactionCount;
  final String whattocopy;
  final String toasttextoncopied;
  final bool isitme;
  final Profile sentFrom;
  final VoidCallback? onchatdelete;
  final Function(String emoji) onReacted;
  late final MediaQueryData md;

  @override
  Widget build(BuildContext context) {
    md = MediaQuery.of(context);
    return Container(
      padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              width: md.size.width * 0.3,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          emojiPanel(context),

          SizedBox(height: md.size.width * 0.05),

          // sent from profile
          sentFromOperation(),

          SizedBox(height: md.size.width * 0.05),

          // copy
          operationItem(
            start: const Icon(Icons.copy_rounded,
                color: MyColors.textsecondary, size: 30),
            text: "copy text",
            onclicked: () {
              context.pop();
              Clipboard.setData(ClipboardData(text: whattocopy)).then((value) {
                Toast(toasttextoncopied);
              });
            },
          ),

          const SizedBox(height: 5),

          // view reactions
          if (reactions.isReactionNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: operationItem(
                  start: const Icon(Icons.face_rounded),
                  text: "view reactions",
                  onclicked: () {
                    context.pop(ExtraOperations.viewReactions);
                  }),
            ),

          // delete
          if (isitme)
            operationItem(
                start: const Icon(Icons.delete_rounded,
                    color: Colors.redAccent, size: 30),
                text: "delete",
                onclicked: () {
                  ondeleteclicked(context);
                }),
        ],
      ),
    );
  }

  void ondeleteclicked(BuildContext context) async {
    context.pop();
    bool result = await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (alertcontext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: const Text("Are you sure ?"),
          content: const Text("Are you sure you want to delete this chat ?"),
          actions: [
            alertdialogactionbutton("YES", () => alertcontext.pop(true)),
            alertdialogactionbutton("NO", () => alertcontext.pop(false)),
          ],
        );
      },
    );

    if (result) {
      onchatdelete?.call();
    }
  }

  Widget emojiPanel(BuildContext context) {
    return SizedBox(
      width: md.size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ...List.generate(emojiList.length,
              (index) => emojiCircle(emojiList[index], context)),
          emojiadd(context),
        ],
      ),
    );
  }

  Widget sentFromOperation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text("Sent from"),
        ),
        chatroomitem(
          isitgroup: false,
          name: isitme ? "me" : sentFrom.getName,
          md: md,
          amIadmin: false,
          bio: sentFrom.bio,
          url: sentFrom.photourl,
        ),
      ],
    );
  }

  Widget operationItem({
    required Icon start,
    required String text,
    required VoidCallback? onclicked,
  }) {
    return GestureDetector(
      onTap: onclicked,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.shade100,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            start,
            const SizedBox(width: 20),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget emojiadd(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pop(ExtraOperations.addReaction);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ClipOval(
          child: Container(
            width: md.size.width * 0.12,
            height: md.size.width * 0.12,
            color: backemojipanel,
            child: const Icon(Icons.add_rounded, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget emojiCircle(String emoji, BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("${sentFrom.getPhoneNumber} reacted with $emoji");
        onReacted(emoji);
        context.pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ClipOval(
          child: Container(
            width: md.size.width * 0.11,
            height: md.size.width * 0.11,
            color: backemojipanel,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmojiPickerView extends StatelessWidget {
  const EmojiPickerView({
    super.key,
    required this.onReacted,
    required this.sentFrom,
  });

  final Function(String emoji) onReacted;
  final Profile sentFrom;

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return SizedBox(
      width: md.size.width,
      height: md.size.height * 0.35,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          log("${sentFrom.getPhoneNumber} reacted with new emoji ${emoji.emoji}");
          onReacted(emoji.emoji);
          context.pop();
        },
        config: const Config(
          buttonMode: ButtonMode.MATERIAL,
          enableSkinTones: true,
          columns: 8,
          emojiSizeMax: 26,
          iconColorSelected: MyColors.primarySwatch,
          checkPlatformCompatibility: true,
          initCategory: Category.SMILEYS,
          indicatorColor: MyColors.primarySwatch,
          recentTabBehavior: RecentTabBehavior.POPULAR,
        ),
      ),
    );
  }
}

class ViewReactions extends StatelessWidget {
  final Map<String, int> reactionCount;
  final Map<String, List<String>> reactions;
  final List<Profile> profiles;
  final String myphoneno;
  final Function(String emoji) onReactionRemoved;
  const ViewReactions({
    super.key,
    required this.onReactionRemoved,
    required this.myphoneno,
    required this.profiles,
    required this.reactions,
    required this.reactionCount,
  });

  @override
  Widget build(BuildContext context) {
    MediaQueryData md = MediaQuery.of(context);
    return DefaultTabController(
      animationDuration: const Duration(milliseconds: 300),
      length: reactionCount.length,
      child: Container(
        height: md.size.height * 0.4,
        padding:
            const EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: MyColors.primarySwatch,
              tabs: reactionCount.entries
                  .map(
                    (entry) => Tab(
                      child: Container(
                        height: md.size.height * 0.04,
                        width: md.size.height * 0.04,
                        decoration: const BoxDecoration(),
                        child: Column(
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: reactionCount.entries.map(
                  (entry) {
                    List<Profile> profileList = getList(entry.key);
                    return ListView(
                      children: List.generate(
                        entry.value,
                        (index) {
                          return chatroomitem(
                            constraints: BoxConstraints.tightFor(
                                width: md.size.width * 0.6),
                            isitgroup: false,
                            name: profileList[index].getPhoneNumber == myphoneno
                                ? "me"
                                : profileList[index].getName,
                            bio: profileList[index].getPhoneNumber == myphoneno
                                ? "Tap to remove the reaction"
                                : null,
                            endactions: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 20),
                            ),
                            url: profileList[index].photourl,
                            onitemtap: () {
                              if (profileList[index].getPhoneNumber ==
                                  myphoneno) {
                                onReactionRemoved(entry.key);
                                context.pop();
                              }
                            },
                            md: md,
                          );
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Profile> getList(String emoji) {
    List<Profile> mylist = [];
    reactions.forEach((key, value) {
      if (value.contains(emoji)) {
        mylist.add(getProfile(key));
      }
    });
    return mylist;
  }

  Profile getProfile(String phoneno) {
    for (int i = 0; i < profiles.length; i++) {
      if (profiles[i].getPhoneNumber == phoneno) {
        return profiles[i];
      }
    }
    throw ("cannot find profile from given number $phoneno");
  }
}
