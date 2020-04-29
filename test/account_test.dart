import 'dart:convert';
import 'dart:io';

import 'package:capstone_app/models/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Makes test running work from both Android Studio and command line
  if (Directory.current.path.endsWith('/test')) {
    Directory.current = Directory.current.parent;
  }

  group('Initialization', () {
    test('Construct', () {
      Account account = Account(
        email: "test@test.com",
        firstName: "Test",
        lastName: "Account",
        phoneNumber: "1234567890"
      );

      expect(account.email, "test@test.com");
      expect(account.firstName, "Test");
      expect(account.lastName, "Account");
      expect(account.phoneNumber, "1234567890");
    });

    test('Construct from valid JSON', () {
      File validJSONFile = File('test_resources/valid_user.json');

      Map<String, dynamic> accountJSON = jsonDecode(validJSONFile.readAsStringSync());

      Account account = Account.fromJson(accountJSON);

      expect(account.email, accountJSON['email']);
      expect(account.firstName, accountJSON['first_name']);
      expect(account.lastName, accountJSON['last_name']);
      expect(account.phoneNumber, accountJSON['phone']);
    });

    test('Construct from invalid JSON', () {
      File invalidJSONFile = File('test_resources/no_token_response.json');

      Map<String, dynamic> json = jsonDecode(invalidJSONFile.readAsStringSync());

      expect(() => Account.fromJson(json), throwsAssertionError);
    });
  });
}