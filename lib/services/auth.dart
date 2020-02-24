import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginReturnValue {
  var errors;
  var token;

  LoginReturnValue({this.errors, this.token});
}

class SendAuthTokenReturnValue {
  var errors;

  SendAuthTokenReturnValue({this.errors});
}

class ValidateAuthTokenReturnValue {
  var errors;
  var attempts;

  ValidateAuthTokenReturnValue({this.errors, this.attempts});
}

class ResetPasswordReturnValue {
  var errors;
  var attempts;
  var email;
  var token;

  ResetPasswordReturnValue({this.errors, this.attempts, this.email, this.token});
}

class AuthService {
  // Login
  Future<LoginReturnValue> login({String email = '', String password = ''}) async {
    // Check if already logged in
    // Create storage
    final storage = new FlutterSecureStorage();

    // Read value
    String token = await storage.read(key: 'auth_token');

    if(token != null) {
      return LoginReturnValue(token: token);
    }

    if(email == '' && password == '') {
      return LoginReturnValue(errors: ['User not currently logged in']);
    }

    // If not already logged in..
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['username'] = email;
    requestBody['password'] = password;

    final response = await http.post('https://claytoncornett.tk/api/login/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 200) {
      final token = responseBody['token'];
      storage.write(key: 'auth_token', value: token);

      return LoginReturnValue(token: token);
    } else {
      var errors = [];
      var errorKeys = ['email', 'password', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      return LoginReturnValue(errors: errors);
    }
  }

  Future<SendAuthTokenReturnValue> sendAuthToken({String email = ''}) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['email'] = email;

    final response = await http.post('https://claytoncornett.tk/api/user/password_reset/create/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 201) {
      return SendAuthTokenReturnValue();
    } else {
      var errors = [];
      var errorKeys = ['email', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      return SendAuthTokenReturnValue(errors: errors);
    }
  }

  Future<ValidateAuthTokenReturnValue> validateAuthToken({String email = '', String token = ''}) async {
    Map<String, String> requestBody = new Map<String, String>();
    requestBody['email'] = email;
    requestBody['token'] = token;

    final response = await http.post('https://claytoncornett.tk/api/user/password_reset/validate_token/', body: requestBody);
    final responseBody = jsonDecode(response.body);

    if(response.statusCode == 200) {
      return ValidateAuthTokenReturnValue();
    }else {
      var errors = [];
      var errorKeys = ['email', 'error', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      if(responseBody.containsKey('attempts')) {
        return ValidateAuthTokenReturnValue(errors: errors, attempts: responseBody['attempts'][0]);
      }else {
        return ValidateAuthTokenReturnValue(errors: errors);
      }
    }
  }

  Future<ResetPasswordReturnValue> resetPassword({String email = '', String token = '', String password = '', String password2 = ''}) async {
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

      return ResetPasswordReturnValue();
    }else {
      var errors = [];
      var errorKeys = ['email', 'password', 'password2', 'token', 'non_field_errors'];

      responseBody.forEach((key, value) {
        if(errorKeys.contains(key)) {
          errors += responseBody[key];
        }
      });

      if (responseBody.containsKey('attempts')) {
        return ResetPasswordReturnValue(errors: errors, attempts: responseBody['attempts']);
      } else {
        return ResetPasswordReturnValue(errors: errors);
      }
    }
  }

  // Logout
  Future<void> logout() async {
    final storage = FlutterSecureStorage();

    storage.delete(key: 'auth_token');
    // Simulate a future for response after 1 second.
    return await new Future<void>.delayed(
        new Duration(
            seconds: 1
        )
    );
  }
}