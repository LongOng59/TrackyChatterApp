import 'package:flutter/material.dart'; // Import the Flutter Material package for UI components
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication package
import 'package:trackychatter/screen/main_screen.dart';
import 'registration_screen.dart'; // Import the registration screen

class LoginScreen extends StatefulWidget {
  // This class represents the login screen, which is stateful
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey =
      GlobalKey<FormState>(); // A key to identify the form and validate inputs
  final TextEditingController _emailController =
      TextEditingController(); // Controller for the email input field
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for the password input field
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Instance of Firebase Authentication

  // Function to handle user login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Validate the form inputs
      try {
        // Attempt to sign in with email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, // Get the email from the controller
          password:
              _passwordController.text, // Get the password from the controller
        );

        // If login is successful
        if (userCredential.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Login successful!')), // Show a success message
          );
          // Navigate to MainScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
          // You can navigate to the main screen of the app here
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        }
      } catch (e) {
        // If an error occurs during login, display the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${e.toString()}')), // Show an error message
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method builds the UI for the login screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'), // Set the title of the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the content
        child: SingleChildScrollView(
          // Allow scrolling if the content is too long for the screen
          child: Form(
            key: _formKey, // Assign the form key to the form
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: [
                // Email input field
                TextFormField(
                  controller:
                      _emailController, // Connect the controller to the email input field
                  decoration: InputDecoration(
                    labelText: 'Email', // Set the label for the input field
                    border:
                        OutlineInputBorder(), // Add a border around the input field
                  ),
                  validator: (value) {
                    // Validate the input
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email'; // Error if email is empty
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email'; // Error if email format is invalid
                    }
                    return null; // No error
                  },
                ),
                SizedBox(height: 16), // Add space between the fields
                // Password input field
                TextFormField(
                  controller:
                      _passwordController, // Connect the controller to the password input field
                  decoration: InputDecoration(
                    labelText: 'Password', // Set the label for the input field
                    border:
                        OutlineInputBorder(), // Add a border around the input field
                  ),
                  obscureText: true, // Hide the text for password security
                  validator: (value) {
                    // Validate the input
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password'; // Error if password is empty
                    }
                    return null; // No error
                  },
                ),
                SizedBox(height: 32), // Add space between the fields
                // Login button
                ElevatedButton(
                  onPressed: _login, // Call the _login function when pressed
                  child: Text('Login'), // Set the button text
                ),
                SizedBox(
                    height:
                        16), // Add space between the button and the text button
                // Button to navigate to the registration screen
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      // Push the registration screen onto the navigation stack
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: Text(
                      'Don\'t have an account? Register here'), // Set the button text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
