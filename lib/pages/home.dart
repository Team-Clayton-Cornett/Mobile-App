import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:capstone_app/components/clusterableMapMarker.dart';
import 'package:capstone_app/components/garageCard.dart';
import 'package:capstone_app/components/garageListSearchDelegate.dart';
import 'package:capstone_app/components/handle.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:fluster/fluster.dart';
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

  final List<ClusterableMapMarker> _markers = List<ClusterableMapMarker>();

  Set<Marker> _displayedMarkers = Set<Marker>();

  // TODO: Remove when actual probabilities are available
  Random random = Random();
  List<double> probabilities;

  final List<Garage> _garages = List();

  final Completer<GoogleMapController> _controller = Completer();

  // Handles clustering map markers when too many are too close together
  Fluster<ClusterableMapMarker> fluster;

  _HomePageState();

  @override
  initState() {
    super.initState();

    // TODO: Move garage list loading into repository when it becomes available
    // Load garage list from JSON file and deserialize
    rootBundle.loadString('assets/GarageCoordinates.json').then((json) {
      setState(() {
        List<dynamic> garageArray = jsonDecode(json);

        for(Map<String, dynamic> garage in garageArray) {
          Garage newGarage = Garage.fromJson(garage);

          _garages.add(newGarage);

          _markers.add(ClusterableMapMarker(
            name: newGarage.name,
            position: newGarage.location
          ));
        }

        probabilities = List.generate(_garages.length, (index) {return random.nextDouble();});

        // Initialize fluster
        fluster = Fluster<ClusterableMapMarker>(
            minZoom: 0,
            maxZoom: 21,
            radius: 150,
            extent: 2048,
            nodeSize: 64,
            points: _markers,
            createCluster: (BaseCluster cluster, double lng, double lat) {
              return ClusterableMapMarker(
                  name: cluster.id.toString(),
                  position: LatLng(lat, lng),
                  isCluster: cluster.isCluster,
                  clusterId: cluster.id,
                  pointsSize: cluster.pointsSize,
                  childMarkerId: cluster.childMarkerId
              );
            }
        );

        _displayedMarkers = fluster
            .clusters([-180, -85, 180, 85], _cameraPosition.zoom.floor())
            .map((ClusterableMapMarker cluster) => cluster.toMarker())
            .toSet();
      });
    });
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

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Home"),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search
          ),
          onPressed: () {
            showSearch(
                context: context,
                delegate: GarageListSearchDelegate(
                  garages: _garages,
                  probabilities: probabilities
                ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list
          ),
          onPressed: () {
            // TODO: Navigate to filter page
          },
        )
      ],
      iconTheme: IconThemeData(
        color: Colors.white
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry sheetRadius = BorderRadius.only(
      topRight: Radius.circular(_bottomSheetExpanded ? 0.0 : 15.0),
      topLeft: Radius.circular(_bottomSheetExpanded ? 0.0 : 15.0),
    );

    return Scaffold(
      appBar: _buildAppBar(),
      body: SlidingUpPanel(
        // Max height needs to be set to the total height of the page - the height of the toolbar - a bit of padding
        // If this is not set correctly the garage list will not be able to scroll to the bottom
        maxHeight: MediaQuery.of(context).size.height - kToolbarHeight - 20,
        borderRadius: sheetRadius,
        onPanelSlide: _onPanelSlide,
        body: GoogleMap(
          onMapCreated: (controller) {
            _controller.complete(controller);
          },
          onCameraMove: (position) {
            if (_cameraPosition.zoom != position.zoom) {
              setState(() {
                _displayedMarkers = fluster
                    .clusters([-180, -85, 180, 85], _cameraPosition.zoom.floor())
                    .map((ClusterableMapMarker cluster) => cluster.toMarker())
                    .toSet();
              });
            }

            _cameraPosition = position;
          },
          initialCameraPosition: _cameraPosition,
          markers: _displayedMarkers,
        ),
        panelBuilder: (ScrollController scrollController) {
          return Container(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _garages.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return UnconstrainedBox(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Handle(
                        height: 6.0,
                        width: 45.0,
                      ),
                    ),
                  );
                }
                return GarageCard(
                  name: _garages[index - 1].name,
                  ticketProbability: probabilities[index - 1],
                );
              },
            ),
          );
        },
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'App Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report'),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('About'),
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text('Sign Out'),
            ),
          ],
        ),
      ),

    );
  }
}
