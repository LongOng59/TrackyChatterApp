import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core for initialization
import 'package:flutter/material.dart'; // Import Flutter Material package for UI components
import 'package:trackychatter/screen/splash_screen.dart';
import 'screen/login_screen.dart'; // Import the login screen

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter is properly initialized before running the app
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor for the MyApp class

  @override
  Widget build(BuildContext context) {
    // Build method defines the app's widget tree
    return MaterialApp(
      title: 'TrackyChatter', // Set the title of the app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary theme color
      ),
      home: SplashScreen(), // Set the home screen to the login screen
    );
  }
}
