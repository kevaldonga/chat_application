class FirebaseUser {
  Map<String, bool> mediavisibility;
  // {
  // "publicemailid" : true,
  // "privateemailid"  : false,
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
