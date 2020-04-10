import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';


class AboutPage extends StatelessWidget {
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
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
//              color: Colors.blue,
              child: Text('\nMission Statement\n\n\n\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Container (
              width: MediaQuery.of(context).size.width,
//              color: Colors.blue,
              child: Text('Team Clayton Cornett believes that students should not be subject to fines for parking at school, considering the substantial financial burden that students already face',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
        ],
    ),
      ),
    );
  }
}

