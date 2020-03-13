import 'dart:convert';

import 'package:capstone_app/models/garage.dart';
import 'package:flutter/services.dart' show rootBundle;

class GarageRepository {
  static final GarageRepository _instance = GarageRepository._initialize();

  List<Garage> _garages;

  GarageRepository._initialize();

  static GarageRepository getInstance() {
    return _instance;
  }

  Future<List<Garage>> getGarages() {
    return Future.delayed(Duration(seconds: 10) ,() async {
      if (_garages == null) {
        _garages = List();

        String json = await rootBundle.loadString('assets/garages.json');

        List<dynamic> jsonList = jsonDecode(json);

        for(Map<String, dynamic> garage in jsonList) {
          _garages.add(Garage.fromJson(garage));
        }
      }

      return _garages;
    });
  }
}