import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:capstone_app/components/garageCard.dart';
import 'package:capstone_app/components/handle.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _bottomSheetExpanded = false;

  // Set the initial camera position to focus on Columbia
  CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(38.939654, -92.327518),
      zoom: 14.0
  );

  Set<Marker> _markers = Set<Marker>();

  // TODO: Remove when actual probabilities are available
  Random random = Random();
  List<double> probabilities;

  List<Garage> _garages = List();

  Completer<GoogleMapController> _controller = Completer();

  _HomePageState() {
    // Load garage list from JSON file and deserialize
    rootBundle.loadString('assets/GarageCoordinates.json').then((json) {
      List<dynamic> garageArray = jsonDecode(json);

      for(Map<String, dynamic> garage in garageArray) {
        Garage newGarage = Garage.fromJson(garage);

        _garages.add(newGarage);

        _markers.add(Marker(
          markerId: MarkerId(newGarage.name),
          position: newGarage.location,
          infoWindow: InfoWindow(
            title: newGarage.name,
          ),
        ));
      }

      probabilities = List.generate(_garages.length, (index) {return random.nextDouble();});
    });
  }

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
        // Max height needs to be set to the total height of the page - the height of the toolbar - a bit of padding
        // If this is not set correctly the garage list will not be able to scroll to the bottom
        maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - 20,
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
                    itemCount: _garages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GarageCard(
                        name: _garages[index].name,
                        ticketProbability: probabilities[index],
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
