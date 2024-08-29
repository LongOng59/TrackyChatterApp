import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackychatter/app_constants.dart';
import 'package:trackychatter/screen/login_screen.dart';
import 'package:trackychatter/screen/logout_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for sliding the square
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _currentOffset = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, 1), // starts from bottom
      end: Offset(0, 0), // moves to its position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleRectangle() {
    if (_currentOffset == 1.0) {
      _controller.forward();
      setState(() {
        _currentOffset = 0.0;
      });
    } else {
      _controller.reverse();
      setState(() {
        _currentOffset = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Map that takes up the whole screen
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(51.5, -0.09),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.urlTemplate,
                additionalOptions: const {
                  'id': AppConstants.mapBoxStyleNightId,
                },
                fallbackUrl: AppConstants.urlTemplate,
              ),
            ],
          ),
          // Overlay with rounded rectangle and avatar
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                _controller.forward(); // Trigger animation on tap
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circle with smaller avatar inside
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        // Smaller avatar inside the circle
                        CircleAvatar(
                          backgroundImage: NetworkImage(user?.photoURL ?? ''),
                          radius: 15, // Smaller avatar
                        ),
                      ],
                    ),
                    SizedBox(
                        width: 20), // Space between the circle and the text

                    // Rectangle with rounded corners (80% rounding)
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Container(
                          color:
                              Colors.black, // Background color of the rectangle
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Pick a group...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 20,
            top: 120,
            child: FloatingActionButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Log out the user
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LogoutScreen()), // Navigate to logout screen after logout
                );
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ),
          // Sliding square
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // Update the position based on drag
              setState(() {
                _currentOffset -=
                    details.primaryDelta! / 400; // Adjust sensitivity
                _currentOffset = _currentOffset.clamp(0.0, 1.0);
                _offsetAnimation = Tween<Offset>(
                  begin: Offset(0, _currentOffset),
                  end: Offset(0, 0),
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOut,
                ));
              });
            },
            onVerticalDragEnd: (details) {
              // Check if the drag distance is enough to close the rectangle
              if (_currentOffset > 0.5) {
                _toggleRectangle();
              } else {
                _controller.forward();
                setState(() {
                  _currentOffset = 0.0;
                });
              }
            },
            child: SlideTransition(
              position: _offsetAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'This is a sliding square!',
                      style: TextStyle(
                        color: Colors.white, // Set text color to white
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
