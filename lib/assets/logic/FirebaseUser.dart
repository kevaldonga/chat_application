class FirebaseUser {
  Map<String, bool> mediavisibility;
  // {
  // "chatroomid" : true,
  // "chatroomid2"  : false,
  // }

  FirebaseUser({
    required this.mediavisibility,
  });

  Map<String, dynamic> toMap() {
    return {
      "mediavisibility": mediavisibility,
    };
  }

  @override
  String toString() {
    return "mediavisibility = $mediavisibility";
  }
}
