import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/park.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  group('Initialization', () {
    test('Construct', () {
      Park park = Park(
        id: 12,
        start: DateTime(2020, 1, 1, 7, 0),
        end: DateTime(2020, 1, 1, 7, 30),
        garageId: 12,
        garageName: 'Garage 12'
      );

      expect(park.id, 12);
      expect(park.start, DateTime(2020, 1, 1, 7, 0));
      expect(park.end, DateTime(2020, 1, 1, 7, 30));
      expect(park.garageId, 12);
      expect(park.garageName, 'Garage 12');
      expect(park.ticketDateTime, null);
    });

    test('Construct with end before start', () {
      expect(() => Park(
        id: 12,
        start: DateTime(2020, 1, 1, 7, 30),
        end: DateTime(2020, 1, 1, 7, 0),
        garageId: 12,
        garageName: 'Garage 12'
      ), throwsAssertionError);
    });

    test('Construct from valid JSON with ticket and no end', () {
      File validJSONFile = File('test_resources/valid_user_parks.json');

      List<dynamic> parkList = jsonDecode(validJSONFile.readAsStringSync());

      Park park = Park.fromJson(parkList[0]);
      
      expect(park.id, 772020);
      expect(park.start, DateTime.parse('2020-03-27T20:58:36'));
      expect(park.end, null);
      expect(park.garageId, 1);
      expect(park.garageName, '209 Hitt St');
      expect(park.ticketDateTime, DateTime.parse('2020-03-30T18:47:24.619000'));
    });

    test('Construct from valid JSON with end and no ticket', () {
      File validJSONFile = File('test_resources/valid_user_parks.json');

      List<dynamic> parkList = jsonDecode(validJSONFile.readAsStringSync());

      Park park = Park.fromJson(parkList[1]);

      expect(park.id, 772016);
      expect(park.start, DateTime.parse('2020-03-29T15:36:32.813000'));
      expect(park.end, DateTime.parse('2020-03-29T15:36:45.249000'));
      expect(park.garageId, 3);
      expect(park.garageName, 'AV11');
      expect(park.ticketDateTime, null);
    });

    test('Construct from invalid JSON', () {
      File invalidJSONFile = File('test_resources/no_token_response.json');

      Map<String, dynamic> json = jsonDecode(invalidJSONFile.readAsStringSync());

      expect(() => Park.fromJson(json), throwsAssertionError);
    });
  });
}