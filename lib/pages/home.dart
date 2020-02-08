import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:capstone_app/components/scrollableBottomListSheet.dart';

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  CameraPosition cameraPosition = CameraPosition(
      target: LatLng(38.939654, -92.327518),
      zoom: 13.0
  );

  Completer<GoogleMapController> _controller = Completer();

  // TODO: Populate markers with LatLng coordinates of garages
  Set<Marker> _markers = Set<Marker>();

  _HomePageState();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: cameraPosition,
              markers: _markers,
            ),
            ScrollableBottomListSheet(
              itemCount: 50,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text("Garage #$index"),
                );
              },
            )
          ],
        )
    );
  }
}