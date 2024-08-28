import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // If using Firestore

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: user != null
              ? FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Welcome, ${data['name']}!',
                              style: TextStyle(fontSize: 24)),
                          SizedBox(height: 16),
                          Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 16),
                          Text('Phone: ${data['phone']}', style: TextStyle(fontSize: 18)),
                          SizedBox(height: 16),
                          Text('Birthday: ${data['birthday']}', style: TextStyle(fontSize: 18)),
                        ],
                      );
                    } else {
                      return Text('No user data available.');
                    }
                  },
                )
              : Text('No user logged in.'),
        ),
      ),
    );
  }
}
