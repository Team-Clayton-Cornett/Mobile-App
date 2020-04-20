import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/garage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GarageRepository {
  static GarageRepository _instance;

  List<Garage> _garages;

  GarageRepository._initialize();

  static GarageRepository getInstance() {
    if (_instance == null) {
      _instance = GarageRepository._initialize();
    }

    return _instance;
  }

  Future<List<Garage>> getGarages() {
    return Future(
      () async {
        if (_garages == null) {
          SharedPreferences preferences = await SharedPreferences.getInstance();

          DateTime lastCachedDateTime = DateTime.parse(preferences.getString('lastCachedDateTime') ?? '2000-01-01 12:00:00');
          DateTime now = DateTime.now();

          String garageListJson;

          String garageCacheFilePath = (await getApplicationDocumentsDirectory()).path + '/garageCache.json';
          File cacheFile = File(garageCacheFilePath);

          // If the garage list was last loaded from the network today, load the list from the cache file since
          // data from the API is only refreshed as part of the nightly job
          // Otherwise, load it from the network
          if (lastCachedDateTime.day == now.day && lastCachedDateTime.month == now.month && lastCachedDateTime.day == now.day) {
            garageListJson = await cacheFile.readAsString();
          } else {
            FlutterSecureStorage storage = FlutterSecureStorage();
            String userToken = await storage.read(key: 'auth_token');

            http.Response response = await http.get(
              'https://claytoncornett.tk/api/garages/',
              headers: {HttpHeaders.authorizationHeader: 'Token $userToken'}
            );

            if (response.statusCode != 200) {
              return Future.error("Http Status Code: ${response.statusCode} Body: ${response.body}");
            }

            garageListJson = response.body;

            // Cache the result of the network request and record the time at which it was cached
            await cacheFile.writeAsString(garageListJson);
            await preferences.setString('lastCachedDateTime', DateTime.now().toString());
          }

          _garages = List();

          List<dynamic> jsonList = jsonDecode(garageListJson);

          for(Map<String, dynamic> garage in jsonList) {
            _garages.add(Garage.fromJson(garage));
          }
        }

        return _garages;
      }
    );
  }
}