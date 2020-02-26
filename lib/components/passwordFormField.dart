import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final bool confirm;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  PasswordFormField({
    @required this.controller,
    @required this.focusNode,
    this.textInputAction: TextInputAction.next,
    this.confirm: false,
    @required this.validator,
    @required this.onFieldSubmitted
  });

  @override
  _PasswordFormFieldState createState() => new _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _hidePassword;

  @override
  void initState() {
    super.initState();

    _hidePassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _hidePassword,
        style: getAppTheme().primaryTextTheme.body1,
        textInputAction: widget.textInputAction,
        textCapitalization: TextCapitalization.none,
        validator: widget.validator,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: widget.confirm ? 'Confirm Password' : 'Password',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          suffixIcon: IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () {
              setState(() => this._hidePassword = !this._hidePassword);
            }
          )
        ),
        onFieldSubmitted: widget.onFieldSubmitted
    );
  }
}