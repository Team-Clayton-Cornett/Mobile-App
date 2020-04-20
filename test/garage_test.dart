import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/garage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('Initialization', () {
    test('Construct with defaults', () {
      Garage garage = Garage(
        id: 12,
        name: "Garage 12",
        location: LatLng(100.0, 100.0)
      );

      expect(garage.id, 12);
      expect(garage.name, "Garage 12");
      expect(garage.location, LatLng(100.0, 100.0));
      expect(garage.enforcementStartTime, TimeOfDay(hour: 8, minute: 0));
      expect(garage.enforcementEndTime, TimeOfDay(hour: 18, minute: 0));
      expect(garage.enforcedOnWeekends, false);

      // Range should cover all days to ensure all probabilities are 0
      DateTime start = DateTime(2020, 1, 1);
      DateTime end = DateTime(2020, 1, 8);

      expect(garage.getProbabilityForTimeInterval(start, end), 0.0);
    });

    test('Construct from valid JSON', () {
      File validJSONFile = File('test_resources/valid_garages.json');
      
      List<dynamic> garageList = jsonDecode(validJSONFile.readAsStringSync());

      Garage garage = Garage.fromJson(garageList[0]);
      
      expect(garage.id, 1);
      expect(garage.name, '209 Hitt St');
      expect(garage.enforcedOnWeekends, true);
      expect(garage.enforcementStartTime, TimeOfDay(hour: 7, minute: 0));
      expect(garage.enforcementEndTime, TimeOfDay(hour: 17, minute: 0));

      DateTime start = DateTime(2020, 1, 1, 0, 0);
      DateTime end = DateTime(2020, 1, 1, 1, 0);

      expect(garage.getProbabilityForTimeInterval(start, end), 0.01);
    });

    test('Construct from invalid JSON', () {
      File invalidJSONFile = File('test_resources/no_token_response.json');

      Map<String, dynamic> json = jsonDecode(invalidJSONFile.readAsStringSync());

      expect(() => Garage.fromJson(json), throwsAssertionError);
    });
  });

  group('Probabilities by time interval', () {
    Garage garage;
    Map<String, dynamic> garageJSON;

    setUp(() {
      File garageJSONFile = File('test_resources/valid_garages.json');
      List<dynamic> garageList = jsonDecode(garageJSONFile.readAsStringSync());

      garageJSON = garageList[0];
      garage = Garage.fromJson(garageJSON);
    });

    test('Interval end before interval start', () {
      DateTime start = DateTime.parse('2020-01-01T08:00:00');
      DateTime end = DateTime.parse('2020-01-01T07:59:59');

      expect(() => garage.getProbabilityForTimeInterval(start, end), throwsAssertionError);
    });

    test('Interval along 15 minute boundary', () {
      // Monday
      DateTime start = DateTime.parse('2020-01-06T07:15:00');
      DateTime end = DateTime.parse('2020-01-06T07:30:00');

      expect(garage.getProbabilityForTimeInterval(start, end), garageJSON['probability'][1]['probability'][29]['probability']);
    });

    test('Interval within single 15 minute boundary', () {
      // Monday
      DateTime start = DateTime.parse('2020-01-06T07:16:00');
      DateTime end = DateTime.parse('2020-01-06T07:29:00');

      expect(garage.getProbabilityForTimeInterval(start, end), garageJSON['probability'][1]['probability'][29]['probability']);
    });

    test('Interval not along 15 minute boundary', () {
      // Monday
      DateTime start = DateTime.parse('2020-01-06T07:10:00');
      DateTime end = DateTime.parse('2020-01-06T07:40:00');

      expect(garage.getProbabilityForTimeInterval(start, end), garageJSON['probability'][1]['probability'][28]['probability']);
    });

    test('Interval longer than 1 week', () {
      double maxProb = 0.0;

      for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 4 * 24; j++) {
          double prob = garageJSON['probability'][i]['probability'][j]['probability'];

          if (prob > maxProb) {
            maxProb = prob;
          }
        }
      }

      // Monday
      DateTime start = DateTime.parse('2020-01-06T00:00:00');

      // 1 week and 1 day after
      DateTime end = DateTime.parse('2020-01-14T00:00:00');

      expect(garage.getProbabilityForTimeInterval(start, end), maxProb);
    });
  });
}