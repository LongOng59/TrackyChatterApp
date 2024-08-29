import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackychatter/app_constants.dart';
import 'package:trackychatter/screen/logout_screen.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for sliding the square
  final User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _currentOffset = 1.0;
  LatLng? _currentLocation;
  MapController mapController = MapController();
  StreamSubscription<Position>? positionStreamSubscription;
  List<LatLng> _groupLocations = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
    _listenToGroupLocations();
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
    positionStreamSubscription?.cancel();
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnable;
    LocationPermission permission;

    //Check if location service are enable
    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      // Location services are not enabled, don't continue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Location service is disable')), // Show an error message
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('GPS permission is dinied')), // Show an error message
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'GPS permission is dinied forever')), // Show an error message
      );
      return;
    }

    // Get the current location of the device
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _updateUserLocation(LatLng location) async {
    String userId = user!.uid;
    await FirebaseFirestore.instance.collection('locations').doc(userId).set({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userId, // Optional if not using as document ID
      'heading': 90.0, // Optional
      'speed': 5.5, // Optional
    });
  }

  void _listenToGroupLocations() {
    FirebaseFirestore.instance
        .collection('locations')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        _groupLocations = snapshot.docs.map((doc) {
          return LatLng(
            doc['latitude'],
            doc['longitude'],
          );
        }).toList();
      });

      // Update the map markers for all group members
      _updateGroupMarkers();
    });
  }

  void _updateGroupMarkers() {
    setState(() {
      _markers.clear(); // Clear existing markers

      for (LatLng location in _groupLocations) {
        _markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: location,
            child: Icon(
              Icons.location_pin,
              color: Colors.blue,
              size: 40.0,
            ),
          ),
        );
      }
    });
  }

  void _startLocationUpdates() {
    // Request permission and start listening for location updates
    positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // Update location if moved more than 10 meters
      ),
    ).listen((Position position) {
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      _updateUserLocation(newLocation);
      // Calculate the distance between the old and new location
      double distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      // Only move the map if the user has moved more than 5 meters
      if (_currentLocation == null || distance > 1) {
        setState(() {
          _currentLocation = newLocation;
        });

        // Move the map to the new location smoothly
        mapController.move(_currentLocation!, 10.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation != null)
            // Map that takes up the whole screen
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
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
                //Display Current location
                MarkerLayer(markers: _markers),
              ],
            )
          else
            Center(
              child: CircularProgressIndicator(), // Show a loading indicator
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

          //Logout Button
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

          //Relocate Button
          Positioned(
            left: 20,
            top: 320,
            child: FloatingActionButton(
              onPressed: () async {
                await _getCurrentLocation();
                mapController.move(_currentLocation!, 13.0);
              },
              backgroundColor: Colors.blue,
              child: Icon(Icons.navigation),
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
