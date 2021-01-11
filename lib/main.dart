import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position _currentPosition;
  GoogleMapController _controller;
  String _currentAddress;
  static const LatLng _center = const LatLng(33.347054, 44.340221);
  CameraPosition _cameraPosition;

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
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  // void _onMapCreated(GoogleMapController controller) {
  //   _controller.complete(controller);
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        // body: Container(),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _cameraPosition,
          onMapCreated: (GoogleMapController controller){
            _controller = controller;
          },
        ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching_outlined),
          onPressed: () {
            setState(() {
              _getCurrentLocation();
              // LatLng _latlng =
              //     LatLng(_currentPosition.latitude, _currentPosition.longitude);
              _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
                  tilt: 0,
                  zoom: 18.00)));
              // _cameraPosition = CameraPosition(target: _latlng, zoom: 15);
            });
            Fluttertoast.showToast(
                msg: "Your Position is $_currentAddress",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black.withOpacity(.5),
                textColor: Colors.white,
                fontSize: 16.0
            );
            // print(
            //     '\nLat: ${_currentPosition.latitude}, Lon: ${_currentPosition.longitude}');
          },
        ),
      ),
    );
  }
}
