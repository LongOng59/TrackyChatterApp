import 'dart:developer';

import 'package:trackychatter/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for store self info
  static late ChatUser me;

  //return current user
  static User get user => auth.currentUser!;

  //for checking if user exists or not?
  static Future<bool> UserExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My Data: ${user.data()!}');
      } else {
        log('User not found in Firestore. Please complete registration.');
      }
    });
  }

  //for creating a new user
  static Future<void> createUser(
      String userName, String phoneNumber, DateTime birthday) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      userName: userName,
      phoneNumber:
          phoneNumber, // Set an initial value or use an input from registration
      birthday:
          birthday, // Set an initial value or use an input from registration
      address: '', // Set an initial value or use an input from registration
      isPublic: true, // Set based on user preference
      email: auth.currentUser!.email.toString(),
      about: 'Hello! I love chatting and exploring new places.',
      avatar: user.photoURL.toString(),
      createdAt: DateTime.now(),
      isOnline: false,
      lastActive: DateTime.now(),
      pushToken: '',
      location: GeoPoint(37.7749, -122.4194),
      groups: [],
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating user information
  static Future<void> updateUserInfo({
    String? userName,
    String? about,
    String? phoneNumber,
    String? birthday,
    String? address,
    bool? isPublic,
  }) async {
    final updatedData = <String, dynamic>{};
    if (userName != null) updatedData['user_name'] = userName;
    if (about != null) updatedData['about'] = about;
    if (phoneNumber != null) updatedData['phone_number'] = phoneNumber;
    if (birthday != null) updatedData['birthday'] = birthday;
    if (address != null) updatedData['address'] = address;
    if (isPublic != null) updatedData['is_public'] = isPublic;

    await firestore.collection('users').doc(user.uid).update(updatedData);
  }

  //joingroup for current user
  void joinGroup(String userId, String groupId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'groups': FieldValue.arrayUnion([groupId]),
    });

    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }
}
