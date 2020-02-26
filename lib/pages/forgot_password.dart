import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:capstone_app/models/authentication.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String _status;
  bool _showError;
  String _error;
  TextStyle _style;
  FocusNode _emailFocus;
  TextEditingController _emailController;
  GlobalKey<FormState> _formKey;
  AuthArguments _args;

  @override
  void initState() {
    super.initState();

    _status = 'Send Reset Code';
    _showError = false;
    _error = '';
    _style = getAppTheme().primaryTextTheme.body1;
    _emailFocus = FocusNode();
    _formKey = GlobalKey<FormState>();

    // set the focus to the emailFocus once the app is initialized
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
    _emailController.dispose();

    super.dispose();
  }

  void _submitForm() {
    setState(() => this._status = 'Loading...');

    if (_formKey.currentState.validate()) {
      String email = _emailController.text;

      appAuth.sendResetToken(email).then((result) {
        if (result.errors != null) {
          setState(() => this._status = 'Send Reset Code');
          setState(() => this._showError = true);
          setState(() => this._error = result.errors.join('\n'));
        } else {
          setState(() => this._status = 'Send Reset Code');
          setState(() => this._showError = false);
          setState(() => this._error = '');

          Navigator.pushNamed(
            context,
            '/forgot_password/validate',
            arguments: AuthArguments(email: email)
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: _emailController,
      obscureText: false,
      focusNode: _emailFocus,
      style: _style,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
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
      onFieldSubmitted: (value) => _submitForm()
    );

    final submitButton = MaterialButton(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: getAppTheme().primaryColor,
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      onPressed: () => _submitForm(),
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
                      'Forgot Password',
                      style: _style.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0
                      )
                    ),
                    SizedBox(height: 28.0),
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
        )
      ),
    );
  }
}