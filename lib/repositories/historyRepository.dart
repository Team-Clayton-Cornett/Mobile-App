import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/park.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HistoryRepository {
  static HistoryRepository _instance;

  List<Park> _parks;

  HistoryRepository._initialize();

  static HistoryRepository getInstance() {
    if (_instance == null) {
      _instance = HistoryRepository._initialize();

    }
    return _instance;
  }

  Future<List<Park>> getPreviousParks() {
    return Future(
      () async {
        if (_parks == null) {
          FlutterSecureStorage storage = FlutterSecureStorage();
          String userToken = await storage.read(key: 'auth_token');

          http.Response response = await http.get(
            'https://claytoncornett.tk/api/user/park/',
            headers: {HttpHeaders.authorizationHeader: 'Token $userToken'}
          );

          if (response.statusCode != 200) {
            return Future.error("Http Status Code: ${response.statusCode} Body: ${response.body}");
          }

          String parkListJson = response.body;

          _parks = List();

          List<dynamic> jsonList = jsonDecode(parkListJson);

          for(Map<String, dynamic> park in jsonList) {
            Park newPark = Park.fromJson(park);

            // Make sure the park's start and end are at least 5 seconds apart to filter out the
            // park events generated by ticket reporting
            if (newPark.end != null && newPark.end.difference(newPark.start).inSeconds > 3) {
              _parks.add(newPark);
            }
          }
        }

        return _parks;
      }
    );
  }

  void invalidateCachedHistory() {
    _parks = null;
  }
}