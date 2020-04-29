import 'package:capstone_app/pages/about.dart';
import 'package:capstone_app/pages/filter.dart';
import 'package:capstone_app/pages/garageDetail.dart';
import 'package:flutter/material.dart';

import 'style/appTheme.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/forgot_password.dart';
import 'pages/forgot_password_validate.dart';
import 'pages/forgot_password_reset.dart';
import 'pages/create_account.dart';
import 'services/auth.dart';
import 'pages/history.dart';

AuthService appAuth = new AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set default home.
  Widget _defaultHome = new LoginPage();

  // Get result of the login function.
  bool _result = await appAuth.verifyAuthToken();
  if (_result == true) {
    _defaultHome = new HomePage();
  }

  runApp(MyApp(home: _defaultHome));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final Widget home;
  MyApp({this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: getAppTheme(),
      home: home,
      routes: <String, WidgetBuilder>{
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/history': (context) => HistoryPage(),
        '/forgot_password': (context) => ForgotPasswordPage(),
        '/forgot_password/validate': (context) => ForgotPasswordValidatePage(),
        '/forgot_password/reset': (context) => ForgotPasswordResetPage(),
        '/create_account': (context) => CreateAccountPage(),
        '/home/garage_details': (context) => GarageDetailPage(),
        '/home/filter': (context) => FilterPage(),
        '/about': (context) => AboutPage(),
      },
    );
  }
}
