import 'package:flutter/material.dart';

ThemeData getAppTheme() {
  return ThemeData(
    primaryColor: Color.fromARGB(255, 79, 195, 247),
    accentColor: Color.fromARGB(255, 255, 152, 0),
    primaryTextTheme: TextTheme(
      title: TextStyle(
        color: Colors.white
      ),
      body1: TextStyle(
        color: Colors.black,
        fontSize: 16.0
      )
    ),
  );
}