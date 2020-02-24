import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/pages/forgot_password_validate.dart';

class ForgotPasswordArguments {
  String email;

  ForgotPasswordArguments(this.email);
}

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String _status = 'Send Reset Code';
  bool _showError = false;
  String _error = '';
  TextStyle style = getAppTheme().primaryTextTheme.body1;
  TextEditingController _emailController = new TextEditingController();
  final _formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordArguments args = ModalRoute.of(context).settings.arguments;

    // TODO: update fields so they autofocus
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
            String email = _emailController.text;

            appAuth.sendAuthToken(email: email).then((result) {
              if (result.errors != null) {
                setState(() => this._status = 'Send Reset Code');
                setState(() => this._showError = true);
                setState(() => this._error = result.errors.join(' '));
              } else {
                setState(() => this._status = 'Send Reset Code');
                setState(() => this._showError = false);
                setState(() => this._error = '');
                Navigator.pushNamed(context, '/forgot_password/validate', arguments: ForgotPasswordValidateArguments(email));
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
                      emailField,
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