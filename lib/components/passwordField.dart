import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:capstone_app/components/inputTextField.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final TextStyle style;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final bool confirm;

  PasswordField({
    this.controller,
    this.focusNode,
    this.style,
    this.textInputAction,
    this.confirm,
    this.validator,
    this.onFieldSubmitted
  });

  @override
  _PasswordFieldState createState() => new _PasswordFieldState(
    controller: this.controller,
    focusNode: this.focusNode,
    style: this.style,
    textInputAction: this.textInputAction,
    confirm: this.confirm,
    validator: this.validator,
    onFieldSubmitted: this.onFieldSubmitted
  );
}

class _PasswordFieldState extends State<PasswordField> {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final TextStyle style;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final bool confirm;

  _PasswordFieldState({
    Key key,
    this.controller,
    this.focusNode,
    this.style,
    this.textInputAction,
    this.confirm,
    this.validator,
    this.onFieldSubmitted
  });

  bool _hidePassword;

  @override
  void initState() {
    super.initState();

    _hidePassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return InputTextField(
        controller: this.controller,
        focusNode: this.focusNode,
        obscureText: _hidePassword,
        textInputAction: this.textInputAction,
        textCapitalization: TextCapitalization.none,
        validator: this.validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: this.confirm == null ? 'Confirm Password' : 'Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          suffixIcon: IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () {
              setState(() => this._hidePassword = !this._hidePassword);
            }
          )
        ),
        onFieldSubmitted: this.onFieldSubmitted
    );
  }
}