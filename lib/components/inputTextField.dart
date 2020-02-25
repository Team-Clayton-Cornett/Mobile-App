import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle style;
  final String hintText;
  final InputDecoration decoration;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;


  InputTextField({
    this.controller,
    this.focusNode,
    this.obscureText,
    this.keyboardType,
    this.style,
    this.textInputAction,
    this.textCapitalization,
    this.hintText,
    this.decoration,
    this.validator,
    this.onFieldSubmitted
  });

  @override
  Widget build(BuildContext context) {
    final _style = this.style ?? getAppTheme().primaryTextTheme.body1;
    final _obscureText = this.obscureText ?? false;
    final _keyboardType = this.keyboardType ?? TextInputType.text;
    final _textInputAction = this.textInputAction ?? TextInputAction.next;
    final _textCapitalization = this.textCapitalization ?? TextCapitalization.sentences;

    final _decoration = this.decoration ?? InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: this.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
    );

    return TextFormField(
      controller: this.controller,
      focusNode: this.focusNode,
      obscureText: _obscureText,
      keyboardType: _keyboardType,
      style: _style,
      textInputAction: _textInputAction,
      textCapitalization: _textCapitalization,
      validator: this.validator,
      decoration: _decoration,
      onFieldSubmitted: this.onFieldSubmitted
    );
  }
}