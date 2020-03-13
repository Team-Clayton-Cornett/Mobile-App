import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/garage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GarageRepository {
  static final GarageRepository _instance = GarageRepository._initialize();

  List<Garage> _garages;

  GarageRepository._initialize();

  static GarageRepository getInstance() {
    return _instance;
  }

  Future<List<Garage>> getGarages() {
    return Future(() async {
      if (_garages == null) {
        FlutterSecureStorage storage = FlutterSecureStorage();
        String userToken = await storage.read(key: 'auth_token');

        http.Response response = await http.get(
          'https://claytoncornett.tk/api/garages',
          headers: {HttpHeaders.authorizationHeader: 'Token $userToken'}
        );

        if (response.statusCode != 200) {
          return Future.error("Http Status Code: ${response.statusCode} Body: ${response.body}");
        }

        _garages = List();

        List<dynamic> jsonList = jsonDecode(response.body);

        for(Map<String, dynamic> garage in jsonList) {
          _garages.add(Garage.fromJson(garage));
        }
      }

      return _garages;
    });
  }
}