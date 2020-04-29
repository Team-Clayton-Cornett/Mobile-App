import 'package:capstone_app/pages/about.dart';
import 'package:capstone_app/pages/account.dart';
import 'package:capstone_app/pages/history.dart';
import 'package:capstone_app/pages/report.dart';
import 'package:capstone_app/services/auth.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/pages/home.dart';
import 'package:flutter/material.dart';

class NavigationDrawer extends StatefulWidget {
  final Widget currentPage;

  NavigationDrawer({this.currentPage});

  @override
  State<StatefulWidget> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            selected: widget.currentPage is HomePage,
            onTap: () {
              widget.currentPage is HomePage ? Navigator.pop(context) : Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Report'),
            selected: widget.currentPage is ReportPage,
            onTap: () {
              widget.currentPage is ReportPage ? Navigator.pop(context) : Navigator.of(context).pushReplacementNamed('/report');
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            selected: widget.currentPage is HistoryPage,
            onTap: () {
              widget.currentPage is HistoryPage ? Navigator.pop(context) : Navigator.of(context).pushReplacementNamed('/history');
            },
          ),
          ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              selected: widget.currentPage is AccountPage,
              onTap: () {
                widget.currentPage is AccountPage ? Navigator.pop(context) : Navigator.pushNamed(context, "/account");
              }
          ),
          ListTile(
              leading: Icon(Icons.help),
              title: Text('About'),
              selected: widget.currentPage is AboutPage,
              onTap: () {
                widget.currentPage is AboutPage ? Navigator.pop(context) : Navigator.pushNamed(context, "/about");
              }
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
    );
  }
}