import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClusterableMapMarker extends Clusterable {
  final String name;
  final LatLng position;

  ClusterableMapMarker({
    @required this.name,
    @required this.position,
    isCluster = false,
    clusterId,
    pointsSize,
    markerId,
    childMarkerId
  }) : super(
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    markerId: markerId,
    childMarkerId: childMarkerId
  );

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(name),
      position: position,
      infoWindow: InfoWindow(
        title: isCluster ? "$pointsSize garages nearby" : name
      ),
    );
  }
}