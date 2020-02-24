import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';

class ForgotPasswordResetArguments {
  String email;
  String token;

  ForgotPasswordResetArguments(this.email, this.token);
}

class ForgotPasswordResetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  String _status = 'Change Password';
  int _attempts = 3;
  bool _showError = false;
  String _error = '';
  TextStyle style = getAppTheme().primaryTextTheme.body1;
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _password2Controller = new TextEditingController();
  final _formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordResetArguments args = ModalRoute.of(context).settings.arguments;
    // TODO: update fields so they autofocus

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

    final passwordField2 = TextFormField(
      controller: _password2Controller,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Confirm Password",
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final submitButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          setState(() => this._status = 'Loading...');

          if (_formKey1.currentState.validate()) {
            String password = _passwordController.text;
            String password2 = _password2Controller.text;

            if(password != password2) {
              setState(() => this._status = 'Change Password');
              setState(() => this._showError = true);
              setState(() => this._error = 'Passwords must match.');

              return;
            }

            appAuth.resetPassword(email: args.email, token: args.token, password: password, password2: password2).then((result) {
              if (result.errors != null) {
                String errors = result.errors.join(' ');
                if(result.attempts != null) {
                  errors += ' You have ${result.attempts} remaining.';
                }

                setState(() => this._status = 'Change Password');
                setState(() => this._showError = true);
                setState(() => this._error = errors);
              } else {
                setState(() => this._status = 'Change Password');
                setState(() => this._showError = false);
                setState(() => this._error = '');
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
      child: Column(
        children: [
          Text(
            '${this._error}',
            textAlign: TextAlign.center,
            style: style.copyWith(
              color: Colors.redAccent, fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: 12.0)
        ]
      ),
      visible: this._showError,
    );

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Forgot Password'),
      ),
      body: Center(
          child: Container(
            child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      errorField,
                      passwordField,
                      SizedBox(height: 24.0),
                      passwordField2,
                      SizedBox(height: 35.0),
                      submitButton,
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