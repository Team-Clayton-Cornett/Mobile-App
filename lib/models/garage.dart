import 'package:google_maps_flutter/google_maps_flutter.dart';

class Garage {
  String name;
  DateTime enforcementStartTime;
  DateTime enforcementEndTime;
  bool enforcedOnWeekends;
  LatLng location;
  List<List<double>> _ticketProbabilities;

  Garage(
      this.name,
      this.enforcementStartTime,
      this.enforcementEndTime,
      this.location,
      {this.enforcedOnWeekends = false,
      }) {
    // Initialise _ticketProbabilities as a list of 7 lists, each with 4 probability values for each hour in the day
    // [[0.0, 0.0, ...], [0.0, 0.0, ...], ...]
    _ticketProbabilities = List.generate(7, (_) => List.generate(24 * 4, (_) => 0.0));
  }

  // TODO: Get enforcement start times and end times from JSON once it is made available
  Garage.fromJson(Map<String, dynamic> json) :
      name = json['name'],
      location = LatLng(json['latitude'], json['longitude']),
      enforcementStartTime = DateTime.now(),
      enforcementEndTime = DateTime.now(),
      enforcedOnWeekends = false {
    // Initialise _ticketProbabilities as a list of 7 lists, each with 4 probability values for each hour in the day
    // [[0.0, 0.0, ...], [0.0, 0.0, ...], ...]
    _ticketProbabilities = List.generate(7, (_) => List.generate(24 * 4, (_) => 0.0));
  }

  // TODO: Add ability to update/set probabilities from JSON
  // TODO: Add methods for updating/reading probabilities based on time
}