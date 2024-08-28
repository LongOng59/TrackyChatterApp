class Group {
  String id; // Unique identifier for the group
  String name; // Name of the group
  String avatar; // Avatar or image representing the group
  int limit; // Maximum number of members allowed in the group
  bool isPublic; // Whether the group is public or private
  String? passcode; // Passcode required to join the group if private

  Group({
    required this.id,
    required this.name,
    required this.avatar,
    required this.limit,
    required this.isPublic,
    this.passcode,
  });

  // Create a Group object from JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      limit: json['limit'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      passcode: json['passcode'],
    );
  }

  // Convert a Group object to JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['limit'] = limit;
    data['isPublic'] = isPublic;
    data['passcode'] = passcode;
    return data;
  }
}
