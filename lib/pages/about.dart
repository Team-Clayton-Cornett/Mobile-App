import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/services/auth.dart';


class AboutPage extends StatelessWidget {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


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

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'App Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: (){
                Navigator.of(context).pushReplacementNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report'),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, "/history", (r) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('About'),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, "/about", (r) => false);
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text('Sign Out'),
              onTap: () {
                AuthService appAuth = new AuthService();
                appAuth.logout();

                Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
              },
            ),
          ],
        ),
      ),

    );
  }
}

