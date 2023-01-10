class GroupInfo {
  String name;
  String? photourl;
  String? bio;
  List<String> admins;
  // [
  // admin phoneno, admin phoneno2,
  // ]

  GroupInfo({
    this.bio,
    required this.photourl,
    required this.name,
    required this.admins,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      if (photourl != null) "photourl": photourl,
      if (bio != null) "bio": bio,
      "admins": admins,
      if (bio != "" && bio != null) "bio": bio,
    };
  }

  GroupInfo.fromMap(Map<String, dynamic>? data)
      : name = data!["name"],
        photourl = data["photourl"] != "null" ? data["photourl"] : null,
        bio = data["bio"] != "null" && data["bio"] != null ? data["bio"] : null,
        admins = data["admins"]!.cast<String>();

  @override
  String toString() {
    return "name = $name || photourl = $photourl || bio = $bio || admins = $admins";
  }
}
