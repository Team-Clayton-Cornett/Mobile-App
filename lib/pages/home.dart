import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:capstone_app/components/clusterableMapMarker.dart';
import 'package:capstone_app/components/garageCard.dart';
import 'package:capstone_app/components/garageListSearchDelegate.dart';
import 'package:capstone_app/components/handle.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/services/auth.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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

  Future<LocationData> locationFuture;

  // Record the user's location if it is available
  LatLng userLocation;

  // List of markers for every garage on the map
  final List<ClusterableMapMarker> _markers = List<ClusterableMapMarker>();

  // List of map markers that will actually be displayed, whether they are clusters or actual garage markers
  Set<Marker> _displayedMarkers = Set<Marker>();

  final List<Garage> _garages = List();

  // Handles clustering map markers when too many are too close together
  Fluster<ClusterableMapMarker> fluster;

  _HomePageState();

  @override
  initState() {
    super.initState();

    // Save the location Future so its progress can be checked later
    locationFuture = Location().getLocation();

    locationFuture.then((LocationData location) {
      setState(() {
        userLocation = LatLng(location.latitude, location.longitude);

        _sortGaragesByProximity();
      });
    });

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

        _sortGaragesByProximity();

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

  // Sorts the garage list by proximity to the user if both the garage list and the user location are available
  // Has no effect otherwise.
  void _sortGaragesByProximity() {
    if (_garages.isNotEmpty && userLocation != null) {
      _garages.sort((garage1, garage2) {
        double latDist = garage1.location.latitude - userLocation.latitude;
        double lngDist = garage1.location.longitude - userLocation.longitude;

        double garage1Dist = sqrt(pow(latDist, 2) + pow(lngDist, 2));

        latDist = garage2.location.latitude - userLocation.latitude;
        lngDist = garage2.location.longitude - userLocation.longitude;

        double garage2Dist = sqrt(pow(latDist, 2) + pow(lngDist, 2));

        if (garage1Dist < garage2Dist){
          return -1;
        } else if (garage1Dist == garage2Dist) {
          return 0;
        }
        else {
          return 1;
        }
      });
    }
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
                ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.filter_list
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/home/filter');
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
        // Make sure that the user location request has been completed before creating the GoogleMap widget
        // Otherwise, the map widget will not be created properly on iOS
        body: FutureBuilder(
          future: locationFuture,
          builder: (BuildContext context, AsyncSnapshot<LocationData> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting){
              return Container();
            } else {
              return GoogleMap(
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
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
              );
            }
          },
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
                  garage: _garages[index - 1],
                );
              },
            ),
          );
        },
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
              onTap: () {
                Navigator.pushNamed(context, "/about");
                 }
               ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text('Sign Out'),
              onTap: () {
                AuthService appAuth = new AuthService();
                appAuth.logout();

                Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
              },
            ),
          ],
        ),
      ),

    );
  }
}
