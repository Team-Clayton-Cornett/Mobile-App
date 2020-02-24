import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String _status = 'Login';
  bool _showError = false;
  String _error = '';
  TextStyle style = getAppTheme().primaryTextTheme.body1;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  // TODO: create addtional fields for create account form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: create back button

    final emailField = TextFormField(
      controller: _emailController,
      obscureText: false,
      style: style,
      validator: (email) {
        RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

        if (email.isEmpty || !emailRegex.hasMatch(email)) {
          setState(() => this._status = 'Login');

          return 'Invalid email format';
        }

        return null;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextFormField(
      controller: _passwordController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          setState(() => this._status = 'Loading...');

          if (_formKey.currentState.validate()) {
            String email = _emailController.text;
            String password = _passwordController.text;

            appAuth.login(email: email, password: password).then((result) {
              if (result.errors) {
                setState(() => this._status = 'Login');
                setState(() => this._showError = true);
                setState(() => this._error = 'Failed to login');
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            });
          }
        },
        child: Text(
            '${this._status}',
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    final errorField = Visibility(
      child: Container(
          height: 36,
          child: Text(
              '${this._error}',
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.redAccent, fontWeight: FontWeight.bold
              )
          )
      ),
      visible: this._showError,
    );

    final otherOperations = Container(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                  child: Text(
                    'Forgot Password?',
                    style: style,
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/forgot_password');
                  }
              ),
              FlatButton(
                  child: Text(
                    'Create Account',
                    style: style,
                    textAlign: TextAlign.right,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/create_account');
                  }
              ),
            ]
        )
    );

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: Center(
          child: Container(
            child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      errorField,
                      emailField,
                      SizedBox(height: 25.0),
                      passwordField,
                      SizedBox(height: 35.0),
                      loginButton,
                      otherOperations,
                      SizedBox(height: 15.0),
                    ],
                  ),
                )
            ),
          )
      ),
    );
  }
}