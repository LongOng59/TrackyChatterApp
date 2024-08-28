import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  ChatUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.birthday,
    required this.address,
    required this.isPublic,
    required this.location,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.isOnline,
    required this.avatar,
    required this.pushToken,
    required this.groups,
  });

  String id;
  String userName;
  String email;
  String phoneNumber;
  DateTime birthday;
  String address;
  bool isPublic;
  GeoPoint location;
  String about;
  DateTime createdAt;
  DateTime lastActive;
  bool isOnline;
  String avatar;
  String pushToken;
  List<String> groups;

  /// Factory constructor to create a ChatUser instance from a JSON map
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      birthday: (json['birthday'] != null)
          ? (json['birthday'] as Timestamp).toDate()
          : DateTime.now(),
      address: json['address'] as String? ?? '',
      isPublic: json['is_public'] as bool? ?? true,
      location: json['location'] as GeoPoint? ?? GeoPoint(0, 0),
      about: json['about'] as String? ?? '',
      createdAt: (json['created_at'] != null)
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      lastActive: (json['last_active'] != null)
          ? (json['last_active'] as Timestamp).toDate()
          : DateTime.now(),
      isOnline: json['is_online'] as bool? ?? false,
      avatar: json['avatar'] as String? ?? '',
      pushToken: json['push_token'] as String? ?? '',
      groups: (json['groups'] as List<dynamic>?)
              ?.map((group) => group as String)
              .toList() ??
          [],
    );
  }

  /// Converts the ChatUser instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'email': email,
      'phone_number': phoneNumber,
      'birthday': Timestamp.fromDate(birthday),
      'address': address,
      'is_public': isPublic,
      'location': location,
      'about': about,
      'created_at': Timestamp.fromDate(createdAt),
      'last_active': Timestamp.fromDate(lastActive),
      'is_online': isOnline,
      'avatar': avatar,
      'push_token': pushToken,
      'groups': groups,
    };
  }

  //update user location
  void updateUserLocation(String userId, double latitude, double longitude) async {
  await FirebaseFirestore.instance.collection('users').doc(userId).update({
    'location': GeoPoint(latitude, longitude),
    'last_active': Timestamp.fromDate(DateTime.now()),
  });
}

}
