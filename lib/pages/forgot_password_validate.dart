import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/models/authentication.dart';

class ForgotPasswordValidatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordValidatePageState();
}

class _ForgotPasswordValidatePageState extends State<ForgotPasswordValidatePage> {
  String _status;
  bool _showError;
  String _error;
  TextStyle _style;
  FocusNode _tokenFocus;
  TextEditingController _tokenController;
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();

    _status = 'Submit';
    _showError = false;
    _error = '';
    _style = getAppTheme().primaryTextTheme.body1;
    _tokenFocus = FocusNode();
    _tokenController = new TextEditingController();
    _formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_tokenFocus);
    });
  }

  @override
  void dispose() {
    _tokenFocus.dispose();
    _tokenController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthArguments args = ModalRoute.of(context).settings.arguments;

    final tokenField = TextFormField(
      controller: _tokenController,
      obscureText: false,
      focusNode: _tokenFocus,
      style: _style,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      validator: (token) {
        RegExp tokenRegex = RegExp(r'^(?![O])[A-Z0-9]{6}$');
        RegExp noLowercase = RegExp(r'[a-z]{1,}');
        RegExp noLetterO = RegExp(r'[O]{1,}');

        if(token.isEmpty) {
          return 'This field is required.';
        }

        if(noLowercase.hasMatch(token)) {
          setState(() => this._status = 'Submit');

          return 'Reset code should be capital letters or numbers.';
        }

        if(noLetterO.hasMatch(token)) {
          setState(() => this._status = 'Submit');

          return 'Reset code should not contain the letter O.';
        }

        if(token.length != 6) {
          setState(() => this._status = 'Submit');

          return 'Reset code should be 6 characters.';
        }

        if (token.isEmpty || !tokenRegex.hasMatch(token)) {
          setState(() => this._status = 'Submit');

          return 'Invalid reset code format.';
        }

        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Reset Code",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      onFieldSubmitted: (v) {
        setState(() => this._status = 'Loading...');

        if (_formKey.currentState.validate()) {
          String token = _tokenController.text;

          appAuth.validateResetToken(args.email, token).then((result) {
            if (result.errors != null) {
              String errors = result.errors.join('\n');
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

              Navigator.pushNamed(context, '/forgot_password/reset', arguments: AuthArguments(email: args.email, token: token));
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
          String token = _tokenController.text;

          appAuth.validateResetToken(args.email, token).then((result) {
            if (result.errors != null) {
              String errors = result.errors.join('\n');
              if(result.attempts != null) {
                errors += '\nYou have ${result.attempts} attempts remaining.';
              }

              setState(() => this._status = 'Submit');
              setState(() => this._showError = true);
              setState(() => this._error = errors);
            } else {
              setState(() => this._status = 'Submit');
              setState(() => this._showError = false);
              setState(() => this._error = '');

              Navigator.pushNamed(context, '/forgot_password/reset', arguments: AuthArguments(email: args.email, token: token));
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
                      'You should have received a password reset code at the email you entered. Please enter the code below.',
                      textAlign: TextAlign.center,
                      style: _style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                      )
                    ),
                    SizedBox(height: 28.0),
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
        )
      ),
    );
  }
}