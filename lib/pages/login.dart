import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/models/authentication.dart';
import 'package:capstone_app/components/passwordFormField.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _status;
  bool _showError;
  String _error;
  FocusNode _emailFocus;
  FocusNode _passwordFocus;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  GlobalKey<FormState> _formKey;
  TextStyle _style;
  
  @override
  void initState() {
    super.initState();

    _status = 'Login';
    _showError = false;
    _error = '';
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _style = getAppTheme().primaryTextTheme.body1;

    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_emailFocus);
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: _emailController,
      obscureText: false,
      focusNode: _emailFocus,
      style: _style,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: (email) {
        RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

        if(email.isEmpty) {
          return 'This field is required.';
        }

        if (!emailRegex.hasMatch(email)) {
          setState(() => this._status = 'Login');

          return 'Invalid email.';
        }

        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      onFieldSubmitted: (v){
        FocusScope.of(context).requestFocus(_passwordFocus);
      },
    );

    final passwordField = PasswordFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      textInputAction: TextInputAction.done,
      validator: (password) {
        if(password.isEmpty) {
          return 'This field is required.';
        }

        return null;
      },
      onFieldSubmitted: (v) {
        setState(() => this._status = 'Loading...');

        if (_formKey.currentState.validate()) {
          String email = _emailController.text;
          String password = _passwordController.text;

          appAuth.login(email, password).then((result) {
            if (result.errors != null) {
              setState(() => this._status = 'Login');
              setState(() => this._showError = true);
              setState(() => this._error = result.errors.join('\n'));
            } else {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          });
        }
      }
    );

    final loginButton =  MaterialButton(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: getAppTheme().primaryColor,
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      onPressed: () {
        setState(() => this._status = 'Loading...');

        if (_formKey.currentState.validate()) {
          String email = _emailController.text;
          String password = _passwordController.text;

          appAuth.login(email, password).then((result) {
            if (result.errors != null) {
              setState(() => this._status = 'Login');
              setState(() => this._showError = true);
              setState(() => this._error = result.errors.join('\n'));
            } else {
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
      ),
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

    final otherOperations = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlatButton(
            child: Text(
              'Forgot Password?',
              style: _style,
              textAlign: TextAlign.left,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/forgot_password', arguments: AuthArguments(email: _emailController.text));
            }
          ),
          FlatButton(
            child: Text(
              'Create Account',
              style: _style,
              textAlign: TextAlign.right,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/create_account', arguments: AuthArguments(email: _emailController.text));
            }
          ),
        ]
      )
    );

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
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
                      'Login',
                      style: _style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0
                      )
                    ),
                    SizedBox(height: 24.0),
                    errorField,
                    emailField,
                    SizedBox(height: 25.0),
                    passwordField,
                    SizedBox(height: 35.0),
                    loginButton,
                    SizedBox(height: 8.0),
                    otherOperations,
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