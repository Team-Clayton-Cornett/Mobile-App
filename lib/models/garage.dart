import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Garage {
  String name;
  TimeOfDay enforcementStartTime;
  TimeOfDay enforcementEndTime;
  bool enforcedOnWeekends;
  LatLng location;
  List<List<double>> _ticketProbabilities;

  Garage({
    @required this.name,
    @required this.location,
    this.enforcementStartTime = const TimeOfDay(hour: 8, minute: 0),
    this.enforcementEndTime = const TimeOfDay(hour: 18, minute: 0),
    this.enforcedOnWeekends = false,
  }) {
    _initRandomProbabilities();
  }

  // TODO: Get enforcement start times and end times from JSON once it is made available
  // TODO: Get ticket probabilities from JSON once they are made available
  Garage.fromJson(Map<String, dynamic> json) :
        name = json['name'],
        location = LatLng(json['latitude'], json['longitude']),
        enforcementStartTime = TimeOfDay(hour: 8, minute: 0),
        enforcementEndTime = TimeOfDay(hour: 18, minute: 0),
        enforcedOnWeekends = false {
    _initRandomProbabilities();
  }

  // TODO: Remove once real probabilities are available
  _initRandomProbabilities() {
    Random random = Random();

    _ticketProbabilities = List.generate(7, (_) => List.generate(24 * 4, (_) => random.nextDouble()));
  }

  double getProbabilityForTimeInterval(DateTime intervalStart, DateTime intervalEnd) {
    assert(intervalEnd.isAfter(intervalStart));

    int startDayOfWeekIndex = intervalStart.weekday - 1;
    int endDayOfWeekIndex = intervalEnd.weekday - 1;

    if (intervalEnd.difference(intervalStart).inDays > 6) {
      startDayOfWeekIndex = 0;
      endDayOfWeekIndex = 0;
    }

    int startIndexInFirstDay = (((intervalStart.hour * 60) + intervalStart.minute) / 15).truncate();
    int endIndexInLastDay = (((intervalEnd.hour * 60) + intervalEnd.minute) / 15).truncate();

    double maxProb = 0.0;

    for(int i = startDayOfWeekIndex; i <= endDayOfWeekIndex; i++) {
      int startIndexInCurrentDay = 0;
      if (i == startDayOfWeekIndex) {
        startIndexInCurrentDay = startIndexInFirstDay;
      }

      int endIndexInCurrentDay = (24 * 4) - 1;
      if (i == endDayOfWeekIndex) {
        endIndexInCurrentDay = endIndexInLastDay;
      }

      for(int j = startIndexInCurrentDay; j <= endIndexInCurrentDay; j++) {
        if (_ticketProbabilities[i][j] > maxProb) {
          maxProb = _ticketProbabilities[i][j];
        }
      }
    }

    return maxProb;
  }
}