import 'package:flutter/material.dart';

class Account {
  String email;
  String firstName;
  String lastName;
  String phoneNumber;

  Account({
    @required this.email,
    @required this.firstName,
    @required this.lastName,
    @required this.phoneNumber
  });

  Account.fromJson(Map<String, dynamic> json) :
    email = json['email'],
    firstName = json['first_name'],
    lastName = json['last_name'],
    phoneNumber = json['phone'];
}