import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Garage {
  int id;
  String name;
  TimeOfDay enforcementStartTime;
  TimeOfDay enforcementEndTime;
  bool enforcedOnWeekends;
  LatLng location;
  List<List<double>> _ticketProbabilities;

  Garage({
    @required this.id,
    @required this.name,
    this.location,
    this.enforcementStartTime = const TimeOfDay(hour: 8, minute: 0),
    this.enforcementEndTime = const TimeOfDay(hour: 18, minute: 0),
    this.enforcedOnWeekends = false,
  }) {
    _ticketProbabilities = List.generate(7, (_) => List.generate(24 * 4, (_) => 0.0));
  }

  Garage.fromJson(Map<String, dynamic> json) :
    id = json['pk'],
    name = json['name'],
    location = LatLng(json['latitude'], json['longitude']),
    enforcementStartTime = TimeOfDay(
      hour: int.parse(json['start_enforce_time'].split(':')[0]),
      minute: int.parse(json['start_enforce_time'].split(':')[1])
    ),
    enforcementEndTime = TimeOfDay(
      hour: int.parse(json['end_enforce_time'].split(':')[0]),
      minute: int.parse(json['end_enforce_time'].split(':')[1])
    ),
    enforcedOnWeekends = json['enforced_on_weekends'],
    _ticketProbabilities = List.generate(
      json['probability'].length,
      (int dayIndex) => List.generate(
        // Use (dayIndex + 1) % 7 as the day index because in Sunday is the first day in the JSON,
        // but Flutter considers Monday the first day of the week
        json['probability'][(dayIndex + 1) % 7]['probability'].length,
        (int indexInDay) => json['probability'][(dayIndex + 1) % 7]['probability'][indexInDay]['probability']
      )
    );

  double getProbabilityForTimeInterval(DateTime intervalStart, DateTime intervalEnd) {
    assert(intervalEnd.isAfter(intervalStart));

    int startDayOfWeekIndex = intervalStart.weekday - 1;
    int endDayOfWeekIndex = intervalEnd.weekday - 1;

    if (intervalEnd.difference(intervalStart).inDays > 6) {
      startDayOfWeekIndex = 0;
      endDayOfWeekIndex = 6;
    }

    int startIndexInFirstDay = (((intervalStart.hour * 60) + intervalStart.minute) / 15).truncate();
    int endIndexInLastDay = ((((intervalEnd.hour * 60) + intervalEnd.minute) - 1) / 15).truncate();

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