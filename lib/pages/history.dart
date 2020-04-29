import 'dart:async';

import 'package:capstone_app/components/historyCard.dart';
import 'package:capstone_app/models/park.dart';
import 'package:capstone_app/repositories/historyRepository.dart';
import 'package:capstone_app/services/auth.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  List<Park> _histories = List();

  Future<List<Park>> _historyFuture;

  HistoryRepository _historyRepo = HistoryRepository.getInstance();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _HistoryPageState();

  @override
  initState() {
    super.initState();

    _historyFuture = _historyRepo.getPreviousParks().timeout(Duration(seconds: 30));

    _historyFuture.then((List<Park> histories) async {

      setState(() {
        _histories = histories;
      });

    }).catchError((error) {
      // If there is an error getting the garages, it is likely because of a bad token,
      // so send the user back to the login screen to get a new one
      debugPrint('Error getting user history');

      SnackBar snackBar = SnackBar(
        content: Text('Could not connect to server'),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("History"),
        centerTitle: false,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: Container(
          child: FutureBuilder(
            future: _historyFuture,
            builder: (BuildContext context, AsyncSnapshot<List<Park>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(getAppTheme().accentColor),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: _histories.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return UnconstrainedBox(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                        ),
                      );
                    }

                    return HistoryCard(
                      historyPark: _histories[index - 1],
                    );
                  },
                );
              }
            },
          )

      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 150.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: getAppTheme().primaryColor,
                ),
                child: Text(
                  'PARKR',
                  style: TextStyle(
                    color: getAppTheme().accentColor,
                    fontSize: 24,
                  ),
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
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/report');
              },
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