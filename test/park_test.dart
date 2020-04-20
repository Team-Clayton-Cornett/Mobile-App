import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/park.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  // Makes test running work from both Android Studio and command line
  if (Directory.current.path.endsWith('/test')) {
    Directory.current = Directory.current.parent;
  }

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

      Map<String, dynamic> parkJson = jsonDecode(validJSONFile.readAsStringSync())[0];

      Park park = Park.fromJson(parkJson);
      
      expect(park.id, parkJson['pk']);
      expect(park.start, DateTime.parse(parkJson['start']));
      expect(park.end, null);
      expect(park.garageId, parkJson['garage']['pk']);
      expect(park.garageName, parkJson['garage']['name']);
      expect(park.ticketDateTime, DateTime.parse(parkJson['ticket']['date']));
    });

    test('Construct from valid JSON with end and no ticket', () {
      File validJSONFile = File('test_resources/valid_user_parks.json');

      Map<String, dynamic> parkJson = jsonDecode(validJSONFile.readAsStringSync())[1];

      Park park = Park.fromJson(parkJson);

      expect(park.id, parkJson['pk']);
      expect(park.start, DateTime.parse(parkJson['start']));
      expect(park.end, DateTime.parse(parkJson['end']));
      expect(park.garageId, parkJson['garage']['pk']);
      expect(park.garageName, parkJson['garage']['name']);
      expect(park.ticketDateTime, null);
    });

    test('Construct from invalid JSON', () {
      File invalidJSONFile = File('test_resources/no_token_response.json');

      Map<String, dynamic> json = jsonDecode(invalidJSONFile.readAsStringSync());

      expect(() => Park.fromJson(json), throwsAssertionError);
    });
  });
}