import 'package:capstone_app/components/navigationDrawer.dart';
import 'package:flutter/material.dart';


class AboutPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('About'),
        centerTitle: false,
        iconTheme: IconThemeData(
        color: Colors.white

        ),
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

      drawer: NavigationDrawer(
        currentPage: this,
      ),

    );
  }
}

