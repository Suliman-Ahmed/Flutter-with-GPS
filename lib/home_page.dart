import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initial Variables
  Position _currentPosition = Position();
  late GoogleMapController _controller;
  String _currentAddress = "";
  Set<Marker> _marker = HashSet<Marker>();
  static const LatLng _center = const LatLng(33.347054, 44.340221);
  late CameraPosition _cameraPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _cameraPosition = CameraPosition(
      target: _center,
      zoom: 18.7,
    );
    setState(() {});
  }

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold();
  }

  Scaffold buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps Sample App'),
        backgroundColor: Colors.amber[700],
        centerTitle: true,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _marker,
        initialCameraPosition: _cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location_outlined),
        onPressed: () {
          showLocation();
        },
      ),
    );
  }

  void showLocation() {
    setState(() {
      _getCurrentLocation();
      // Add Marker to show exactly where you are
      _marker.add(
        Marker(
          markerId: MarkerId('location'),
          position:
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
        ),
      );
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          new CameraPosition(
              bearing: 192.8334901395799,
              target:
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
              tilt: 0,
              zoom: 18.00),
        ),
      );
    });
    Fluttertoast.showToast(
        msg: "Your Position is $_currentAddress",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(.5),
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
