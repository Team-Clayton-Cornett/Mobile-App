import 'package:capstone_app/main.dart';
import 'package:capstone_app/pages/forgot_password_reset.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';

class ForgotPasswordValidateArguments {
  String email;

  ForgotPasswordValidateArguments(this.email);
}

class ForgotPasswordValidatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordValidatePageState();
}

class _ForgotPasswordValidatePageState extends State<ForgotPasswordValidatePage> {
  String _status = 'Submit';
  int _attempts = 3;
  bool _showError = false;
  String _error = '';
  TextStyle style = getAppTheme().primaryTextTheme.body1;
  TextEditingController _tokenController = new TextEditingController();
  // TODO: create additional fields for further steps in forgot password steps
  final _formKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordValidateArguments args = ModalRoute.of(context).settings.arguments;
    // TODO: create back button

    final tokenField = TextFormField(
      controller: _tokenController,
      obscureText: false,
      style: style,
      validator: (token) {
        RegExp tokenRegex = RegExp(r'^(?![O])[A-Z0-9]{6}$');

        if (token.isEmpty || !tokenRegex.hasMatch(token)) {
          setState(() => this._status = 'Submit');

          return 'Invalid reset code format';
        }

        return null;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Reset Code",
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
            String token = _tokenController.text;

            appAuth.validateAuthToken(email: args.email, token: token).then((result) {
              if (result.errors != null) {
                String errors = result.errors.join(' ');
                if(result.attempts != null) {
                  errors += ' You have ${result.attempts} attempts remaining.';
                }

                setState(() => this._status = 'Submit');
                setState(() => this._showError = true);
                setState(() => this._error = errors);
              } else {
                setState(() => this._status = 'Submit');
                setState(() => this._showError = false);
                setState(() => this._error = '');
                Navigator.pushNamed(context, '/forgot_password/reset', arguments: ForgotPasswordResetArguments(args.email, token));
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
                      tokenField,
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