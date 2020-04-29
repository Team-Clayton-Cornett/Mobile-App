import 'dart:async';
import 'dart:math';

import 'package:capstone_app/components/clusterableMapMarker.dart';
import 'package:capstone_app/components/garageCard.dart';
import 'package:capstone_app/components/garageListSearchDelegate.dart';
import 'package:capstone_app/components/handle.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/repositories/garageRepository.dart';
import 'package:capstone_app/services/auth.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
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

  Future<LocationData> _location;

  // List of markers for every garage on the map
  final List<ClusterableMapMarker> _markers = List<ClusterableMapMarker>();

  // List of map markers that will actually be displayed, whether they are clusters or actual garage markers
  Set<Marker> _displayedMarkers = Set<Marker>();

  List<Garage> _garages = List();

  Future<List<Garage>> _garageFuture;

  GarageRepository _garageRepo = GarageRepository.getInstance();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Handles clustering map markers when too many are too close together
  Fluster<ClusterableMapMarker> fluster;

  _HomePageState();

  @override
  initState() {
    super.initState();

    // Save the location Future so its progress can be checked later
    _location = Location().getLocation();

    _garageFuture = _garageRepo.getGarages().timeout(Duration(seconds: 30));

    _garageFuture.then((List<Garage> garages) async {
      LocationData location = await _location;

      _sortGaragesByProximity(LatLng(location.latitude, location.longitude));

      for(Garage garage in garages) {
        _markers.add(ClusterableMapMarker(
          name: garage.name,
          position: garage.location
        ));
      }

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

      setState(() {
        _garages = garages;

        _displayedMarkers = fluster.clusters([-180, -85, 180, 85], _cameraPosition.zoom.floor())
                                   .map((ClusterableMapMarker cluster) => cluster.toMarker())
                                   .toSet();
      });
    }).catchError((error) {
      // If there is an error getting the garages, it is likely because of a bad token,
      // so send the user back to the login screen to get a new one
      debugPrint('Error getting garages');

      SnackBar snackBar = SnackBar(
        content: Text('Could not connect to server'),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    });
  }

  /// Sorts the garage list by proximity to the user
  void _sortGaragesByProximity(LatLng location) {
    _garages.sort((garage1, garage2) {
      double latDist = garage1.location.latitude - location.latitude;
      double lngDist = garage1.location.longitude - location.longitude;

      double garage1Dist = sqrt(pow(latDist, 2) + pow(lngDist, 2));

      latDist = garage2.location.latitude - location.latitude;
      lngDist = garage2.location.longitude - location.longitude;

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
      key: _scaffoldKey,
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
          future: _garageFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Garage>> snapshot) {
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
          },
        ),
        panelBuilder: (ScrollController scrollController) {
          return Container(
            child: FutureBuilder(
              future: _garageFuture,
              builder: (BuildContext context, AsyncSnapshot<List<Garage>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Handle(
                            height: 6.0,
                            width: 45.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(getAppTheme().accentColor),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
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
                  );
                }
              },
            )
          );
        },
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 150.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: getAppTheme().primaryColor,
                ),
                child: Text(
                  'PARKR',
                  style: TextStyle(
                    color: getAppTheme().accentColor,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/report');
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/history');
              },
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
