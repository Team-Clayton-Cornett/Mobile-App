import 'package:flutter/material.dart';

import 'style/appTheme.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/forgot_password.dart';
import 'pages/forgot_password_validate.dart';
import 'pages/forgot_password_reset.dart';
import 'pages/create_account.dart';
import 'services/auth.dart';

AuthService appAuth = new AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set default home.
  Widget _defaultHome = new LoginPage();

  // Get result of the login function.
  LoginReturnValue _result = await appAuth.login();
  if (_result.errors == null) {
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
        '/home': (BuildContext context) => new HomePage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/forgot_password': (context) => new ForgotPasswordPage(),
        '/forgot_password/validate': (context) => new ForgotPasswordValidatePage(),
        '/forgot_password/reset': (context) => new ForgotPasswordResetPage(),
        '/create_account': (BuildContext context) => new CreateAccountPage()
      },
    );
  }
}
