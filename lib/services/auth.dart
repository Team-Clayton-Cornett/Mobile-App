import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:io';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/repositories/historyRepository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_app/models/authentication.dart';

class AuthService {
  // Verify auth_token
  Future<bool> verifyAuthToken() async {
    final storage = new FlutterSecureStorage();

    String token = await storage.read(key: 'auth_token');

    if(token != null) {
      final response = await http.post(
        'https://claytoncornett.tk/api/user/verify/',
        headers: {HttpHeaders.authorizationHeader: "Token $token"}
      );

      if(response.statusCode == 200) {
        return true;
      }else {
        storage.delete(key: 'auth_token');

        return false;
      }
    }else {
      return false;
    }
  }

  Future<bool> updateAccount(String email, String firstName, String lastName, String phone) async {
    Map<String, String> requestBody = new Map<String, String>();

    final storage = new FlutterSecureStorage();
    String token = await storage.read(key: 'auth_token');

    requestBody['email'] = email;
    requestBody['first_name'] = firstName;
    requestBody['last_name'] = lastName;
    requestBody['phone'] = phone;

    if (token != null) {
      final response = await http.patch(
          'https://claytoncornett.tk/api/user/',
          headers: {HttpHeaders.authorizationHeader: "Token $token"}
      );
      print(response.statusCode);
      final responseBody = jsonDecode(response.body);
      print(requestBody);
      if (response.statusCode == 200) {
        //await AccountRepository.getInstance().getAccount();
//        await AccountRepository.getInstance().invalidateCurrentAccount();
        storage.write(key: 'auth_token', value: token);
        return true;
      } else {
        var errors = [];
        var errorKeys = [
          'email',
          'first_name',
          'last_name',
          'phone',
          'non_field_errors'
        ];

        responseBody.forEach((key, value) {
          if (errorKeys.contains(key)) {
            errors += responseBody[key];
          }
        });

        return false;
      }
    }
    return false;
  }

  // Login
  Future<AuthArguments> login(String email, String password) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['username'] = email;
    requestBody['password'] = password;

    final response = await http.post('https://claytoncornett.tk/api/login/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 200) {
      final token = responseBody['token'];
      final storage = FlutterSecureStorage();
      storage.write(key: 'auth_token', value: token);

      return AuthArguments(token: token);
    } else {
      var errors = [];
      var errorKeys = ['email', 'password', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      return AuthArguments(errors: errors);
    }
  }


  Future<AuthArguments> createAccount(String email, String firstName, String lastName, String phone, String password, String password2) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['email'] = email;
    requestBody['first_name'] = firstName;
    requestBody['last_name'] = lastName;
    requestBody['phone'] = phone;
    requestBody['password'] = password;
    requestBody['password2'] = password2;

    final response = await http.post('https://claytoncornett.tk/api/user/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 201) {
      final token = responseBody['token'];
      final storage = FlutterSecureStorage();
      storage.write(key: 'auth_token', value: token);

      return AuthArguments(token: token);
    } else {
      var errors = [];
      var errorKeys = ['email', 'first_name', 'last_name', 'phone', 'password', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      return AuthArguments(errors: errors);
    }
  }

  // send password reset code to email
  Future<AuthArguments> sendResetToken(String email) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['email'] = email;

    final response = await http.post('https://claytoncornett.tk/api/user/password_reset/create/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 201) {
      return AuthArguments();
    } else {
      var errors = [];
      var errorKeys = ['email', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      return AuthArguments(errors: errors);
    }
  }

  // validate password reset code
  Future<AuthArguments> validateResetToken(String email, String token) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['email'] = email;
    requestBody['token'] = token;

    final response = await http.post('https://claytoncornett.tk/api/user/password_reset/validate_token/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 200) {
      return AuthArguments();
    }else {
      var errors = [];
      var errorKeys = ['email', 'error', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      if(responseBody.containsKey('attempts')) {
        return AuthArguments(errors: errors, attempts: responseBody['attempts'][0]);
      }else {
        return AuthArguments(errors: errors);
      }
    }
  }

  // reset password using reset code
  Future<AuthArguments> resetPassword(String email, String token, String password, String password2) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['email'] = email;
    requestBody['token'] = token;
    requestBody['password'] = password;
    requestBody['password2'] = password2;

    final response = await http.post('https://claytoncornett.tk/api/user/password_reset/reset/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 200) {
      final storage = FlutterSecureStorage();
      storage.write(key: 'auth_token', value: responseBody['token']);

      return AuthArguments();
    }else {
      var errors = [];
      var errorKeys = ['email', 'password', 'password2', 'token', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      if (responseBody.containsKey('attempts')) {
        return AuthArguments(errors: errors, attempts: responseBody['attempts']);
      } else {
        return AuthArguments(errors: errors);
      }
    }
  }

  // Logout
  Future<void> logout() async {
    final storage = FlutterSecureStorage();

    String token = await storage.read(key: 'auth_token');

    http.post(
      'https://claytoncornett.tk/api/logout/',
      headers: {HttpHeaders.authorizationHeader: "Token $token"}
    );

    storage.delete(key: 'auth_token');

    // Make sure no user account info remains cached after the user logs out
    await AccountRepository.getInstance().invalidateCurrentAccount();
    HistoryRepository.getInstance().invalidateCachedHistory();
  }
}