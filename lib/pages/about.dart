import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/models/authentication.dart';
import 'package:capstone_app/components/passwordFormField.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),
        title: Text('About'),
      ),
      // body is the majority of the screen.
      body: Center(
        child: Text('Hello, world!'),
      ),

    );
  }
}

