import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/models/authentication.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String _status;
  bool _showError;
  bool _hidePassword;
  bool _hidePassword2;
  String _error;
  TextStyle _style;
  FocusNode _emailFocus;
  FocusNode _firstNameFocus;
  FocusNode _lastNameFocus;
  FocusNode _phoneFocus;
  FocusNode _passwordFocus;
  FocusNode _password2Focus;
  TextEditingController _emailController;
  TextEditingController _firstNameController;
  TextEditingController _lastNameController;
  TextEditingController _phoneController;
  TextEditingController _passwordController;
  TextEditingController _password2Controller;
  GlobalKey<FormState> _formKey;
  AuthArguments _args;

  @override
  void initState() {
    super.initState();

    _status = 'Create Account';
    _showError = false;
    _hidePassword = true;
    _hidePassword2 = true;
    _error = '';
    _style = getAppTheme().primaryTextTheme.body1;
    _emailFocus = FocusNode();
    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _passwordFocus = FocusNode();
    _password2Focus = FocusNode();
    _emailController = new TextEditingController();
    _firstNameController = new TextEditingController();
    _lastNameController = new TextEditingController();
    _phoneController = new TextEditingController();
    _passwordController = new TextEditingController();
    _password2Controller = new TextEditingController();
    _formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_emailFocus);
    });

    // wait for app to be initialized,
    // then retrieve context args and initialize emailController with email arg
    Future.delayed(Duration.zero,() {
      _args = ModalRoute.of(context).settings.arguments;
      _emailController = new TextEditingController(text: _args.email);
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _password2Focus.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();

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
          setState(() => this._status = 'Create Account');

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
        FocusScope.of(context).requestFocus(_firstNameFocus);
      },
    );

    final firstNameField = TextFormField(
      controller: _firstNameController,
      obscureText: false,
      focusNode: _firstNameFocus,
      style: _style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      validator: (firstName) {
        if(firstName.isEmpty) {
          return 'This field is required.';
        }

        if(firstName.length > 30) {
          setState(() => this._status = 'Create Account');

          return 'First name cannot exceed 30 characters.';
        }

        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "First Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      onFieldSubmitted: (v){
        FocusScope.of(context).requestFocus(_lastNameFocus);
      },
    );

    final lastNameField = TextFormField(
      controller: _lastNameController,
      obscureText: false,
      focusNode: _lastNameFocus,
      style: _style,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      validator: (lastName) {
        if(lastName.isEmpty) {
          return 'This field is required.';
        }

        if(lastName.length > 150) {
          setState(() => this._status = 'Create Account');

          return 'Last name cannot exceed 150 characters.';
        }

        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Last Name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      onFieldSubmitted: (v){
        FocusScope.of(context).requestFocus(_phoneFocus);
      },
    );

    final phoneField = TextFormField(
      controller: _phoneController,
      obscureText: false,
      focusNode: _phoneFocus,
      style: _style,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: (phone) {
        RegExp phoneRegExp = RegExp(r'^\+?1?\d{9,15}$');

        if(phone.isNotEmpty && !phoneRegExp.hasMatch(phone)) {
          setState(() => this._status = 'Create Account');

          return 'Phone number must be entered in the format: \'+999999999\'.';
        }

        return null;
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Phone Number",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
      onFieldSubmitted: (v){
        FocusScope.of(context).requestFocus(_passwordFocus);
      },
    );

    final passwordField = TextFormField(
      controller: _passwordController,
      obscureText: _hidePassword,
      focusNode: _passwordFocus,
      style: _style,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
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
          setState(() => this._status = 'Create Account');

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

          return 'Does not match first password.';
        }

        return null;
      },
      onFieldSubmitted: (v) {
        setState(() => this._status = 'Loading...');

        if (_formKey.currentState.validate()) {
          String email = _emailController.text;
          String firstName = _firstNameController.text;
          String lastName = _lastNameController.text;
          String phone = _phoneController.text == '' ? null : _phoneController.text;
          String password = _passwordController.text;
          String password2 = _password2Controller.text;

          appAuth.createAccount(email, firstName, lastName, phone, password, password2)
          .then((result) {
            if (result.errors != null) {
              String errors = result.errors.join('\n');

              setState(() => this._status = 'Create Account');
              setState(() => this._showError = true);
              setState(() => this._error = errors);
            } else {
              setState(() => this._status = 'Create Account');
              setState(() => this._showError = false);
              setState(() => this._error = '');
              Navigator.of(context).pushReplacementNamed('/home');
            }
          });
        }
      },
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

          if (_formKey.currentState.validate()) {
            String email = _emailController.text;
            String firstName = _firstNameController.text;
            String lastName = _lastNameController.text;
            String phone = _phoneController.text == '' ? null : _phoneController.text;
            String password = _passwordController.text;
            String password2 = _password2Controller.text;

            appAuth.createAccount(email, firstName, lastName, phone, password, password2)
            .then((result) {
              if (result.errors != null) {
                String errors = result.errors.join('\n');

                setState(() => this._status = 'Create Account');
                setState(() => this._showError = true);
                setState(() => this._error = errors);
              } else {
                setState(() => this._status = 'Create Account');
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
        ),
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

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Create Account'),
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
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: _style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0
                      )
                    ),
                    SizedBox(height: 28.0),
                    errorField,
                    emailField,
                    SizedBox(height: 24.0),
                    firstNameField,
                    SizedBox(height: 24.0),
                    lastNameField,
                    SizedBox(height: 24.0),
                    phoneField,
                    SizedBox(height: 24.0),
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