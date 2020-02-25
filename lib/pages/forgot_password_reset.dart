import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/models/authentication.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  String _status;
  bool _showError;
  bool _hidePassword;
  bool _hidePassword2;
  String _error;
  TextStyle _style;
  FocusNode _passwordFocus;
  FocusNode _password2Focus;
  TextEditingController _passwordController;
  TextEditingController _password2Controller;
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();

    _status = 'Change Password';
    _showError = false;
    _hidePassword = true;
    _hidePassword2 = true;
    _error = '';
    _style = getAppTheme().primaryTextTheme.body1;
    _passwordFocus = FocusNode();
    _password2Focus = FocusNode();
    _passwordController = new TextEditingController();
    _password2Controller = new TextEditingController();
    _formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_passwordFocus);
    });
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    _password2Focus.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthArguments args = ModalRoute.of(context).settings.arguments;

    final passwordField = TextFormField(
      controller: _passwordController,
      obscureText: _hidePassword,
      focusNode: _passwordFocus,
      style: _style,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        suffixIcon: IconButton(
          icon: Icon(Icons.remove_red_eye),
          onPressed: () {
            setState(() => this._hidePassword = !this._hidePassword);
          }
        )
      ),
      validator: (password) {
        if(password.isEmpty) {
          return 'This field is required.';
        }

        if(password.length < 8) {
          setState(() => this._status = 'Change Password');

          return 'Password must be at least 8 characters.';
        }

        return null;
      },
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(_password2Focus);
      },
    );

    final passwordField2 = TextFormField(
      controller: _password2Controller,
      obscureText: _hidePassword2,
      focusNode: _password2Focus,
      style: _style,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Confirm Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        suffixIcon: IconButton(
          icon: Icon(Icons.remove_red_eye),
          onPressed: () {
            setState(() => this._hidePassword2 = !this._hidePassword2);
          }
        )
      ),
      validator: (password2) {
        if(password2.isEmpty) {
          return 'This field is required.';
        }

        if(password2 != _passwordController.text) {
          setState(() => this._status = 'Change Password');

          return 'Must match first password.';
        }

        return null;
      },
      onFieldSubmitted: (v) {
        setState(() => this._status = 'Loading...');

        if (_formKey.currentState.validate()) {
          String password = _passwordController.text;
          String password2 = _password2Controller.text;

          appAuth.resetPassword(args.email, args.token, password, password2)
          .then((result) {
            if (result.errors != null) {
              String errors = result.errors.join('\n');
              if (result.attempts != null) {
                errors += '\nYou have ${result.attempts} remaining.';
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
    );

    final submitButton = MaterialButton(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: getAppTheme().primaryColor,
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      onPressed: () {
        setState(() => this._status = 'Loading...');

        if (_formKey.currentState.validate()) {
          String password = _passwordController.text;
          String password2 = _password2Controller.text;

          if (password != password2) {
            setState(() => this._status = 'Change Password');
            setState(() => this._showError = true);
            setState(() => this._error = 'Passwords must match.');

            return;
          }

          appAuth.resetPassword(args.email, args.token, password, password2)
          .then((result) {
            if (result.errors != null) {
              String errors = result.errors.join('\n');
              if (result.attempts != null) {
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
        style: _style.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold
        )
      )
    );

    final errorField = Visibility(
      child: Column(
        children: [
          Text(
            '${this._error}',
            textAlign: TextAlign.center,
            style: _style.copyWith(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold
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
        iconTheme: IconThemeData(
          color: Colors.white
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Set New Password',
                      textAlign: TextAlign.center,
                      style: _style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0
                      )
                    ),
                    SizedBox(height: 28.0),
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
        )
      ),
    );
  }
}