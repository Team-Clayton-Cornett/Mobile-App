import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/account.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountRepository {
  static final AccountRepository _instance = AccountRepository._initialize();

  Account _account;
  String _token;

  int _currentParkId;
  int _currentGarageId;

  AccountRepository._initialize();

  static AccountRepository getInstance() {
    return _instance;
  }

  Future<Account> getAccount() {
    return Future(
      () async {
        if (_account == null) {
          if (_token == null) {
            FlutterSecureStorage storage = FlutterSecureStorage();
            _token = await storage.read(key: 'auth_token');
          }

          http.Response response = await http.get(
              'https://claytoncornett.tk/api/user',
              headers: {HttpHeaders.authorizationHeader: 'Token $_token'}
          );

          if (response.statusCode != 200) {
            return Future.error("Http Status Code: ${response.statusCode} Body: ${response.body}");
          }

          Map<String, dynamic> json = jsonDecode(response.body);

          _account = Account.fromJson(json);
        }

        return _account;
      }
    );
  }

  Future<void> checkInToGarage(Garage garage) {
    return Future(
      () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        if (_currentParkId == null) {
          _currentParkId = preferences.getInt('currentParkId') ?? -1;
        }

        if (_currentGarageId == null) {
          _currentGarageId = preferences.getInt('currentGarageId') ?? -1;
        }

        if (_currentParkId != -1) {
          return Future.error("User is already checked in to a garage");
        }

        if (_token == null) {
          FlutterSecureStorage storage = FlutterSecureStorage();
          _token = await storage.read(key: 'auth_token');
        }

        Map<String, String> params = {
          'start': DateTime.now().toIso8601String(),
          'garage_id': garage.id.toString(),
        };

        http.Response response = await http.post(
          'https://claytoncornett.tk/api/user/park/',
          headers: {HttpHeaders.authorizationHeader: 'Token $_token'},
          body: params,
        );

        if (response.statusCode != 201) {
          return Future.error("Http Status Code: ${response.statusCode} Body: ${response.body}");
        }

        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        preferences.setInt('currentParkId', jsonResponse['pk']);
        _currentParkId = jsonResponse['pk'];

        preferences.setInt('currentGarageId', garage.id);
        _currentGarageId = garage.id;

        // TODO: subscribe to notifications for garage
      }
    );
  }

  Future<void> checkOutOfGarage() {
    return Future(
      () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        if (_currentParkId == null) {
          _currentParkId = preferences.getInt('currentParkId') ?? -1;
        }

        if (_currentGarageId == null) {
          _currentGarageId = preferences.getInt('currentGarageId') ?? -1;
        }
        
        if (_currentParkId == -1) {
          return Future.error("User is not checked in to a garage");
        }

        if (_token == null) {
          FlutterSecureStorage storage = FlutterSecureStorage();
          _token = await storage.read(key: 'auth_token');
        }

        Map<String, dynamic> params = {
          'pk': _currentParkId.toString(),
          'end': DateTime.now().toIso8601String(),
        };

        http.Response response = await http.patch(
            'https://claytoncornett.tk/api/user/park/',
            headers: {HttpHeaders.authorizationHeader: 'Token $_token'},
            body: params
        );

        if (response.statusCode != 200) {
          return Future.error("Http Status Code: ${response.statusCode} Body: ${response.body}");
        }

        // TODO: unsubscribe from garage notifications

        preferences.remove('currentParkId');
        _currentParkId = -1;

        preferences.remove('currentGarageId');
        _currentGarageId = -1;
      }
    );
  }

  Future<bool> isCheckedInTo(Garage garage) {
    return Future(
      () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();

        if (_currentGarageId == null) {
          _currentGarageId = preferences.getInt('currentGarageId') ?? -1;
        }

        return garage.id == _currentGarageId;
      }
    );
  }

  /// Should be called by the Auth service when a user is logged out or their token is invalid
  Future<void> invalidateCurrentAccount() {
    return Future(
      () async {
        _account = null;
        _token = null;
        _currentParkId = null;
        _currentGarageId = null;

        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('currentParkId');
        preferences.remove('currentGarageId');
      }
    );
  }
}