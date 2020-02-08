import 'dart:async';

import 'package:capstone_app/components/handle.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set the initial camera position to focus on Columbia
  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(38.939654, -92.327518),
      zoom: 13.0
  );

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = Set<Marker>();

  bool _bottomSheetExpanded = false;

  // TODO: Populate markers with LatLng coordinates of garages
  _HomePageState();

  // Called when the Google Map has been successfully created
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  /// Called when the sliding bottom panel moves
  ///
  /// [position] is a double referring to the position of the panel
  /// where 0.0 is fully closed and 1.0 is fully open
  void _onPanelSlide(double position) {
    if (!_bottomSheetExpanded && position == 1.0) {
      setState(() {
        _bottomSheetExpanded = true;
      });
    } else if (_bottomSheetExpanded && position < 1.0) {
      setState(() {
        _bottomSheetExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry sheetRadius = BorderRadius.only(
      topRight: Radius.circular(_bottomSheetExpanded ? 0.0 : 15.0),
      topLeft: Radius.circular(_bottomSheetExpanded ? 0.0 : 15.0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height,
        borderRadius: sheetRadius,
        onPanelSlide: _onPanelSlide,
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _cameraPosition,
          markers: _markers,
        ),
        panelBuilder: (ScrollController scrollController) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Handle(
                  height: 6.0,
                  width: 45.0,
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 25,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text("Garage #$index"),
                      );
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
