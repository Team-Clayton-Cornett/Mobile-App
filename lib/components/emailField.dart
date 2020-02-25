import 'package:flutter/material.dart';
import 'package:capstone_app/components/inputTextField.dart';

class EmailField extends InputTextField {
  EmailField({
    TextEditingController controller,
    FocusNode focusNode,
    TextInputAction textInputAction,
    TextStyle style,
    FormFieldValidator<String> validator,
    ValueChanged<String> onFieldSubmitted
  }) : super(
    controller: controller,
    focusNode: focusNode,
    textInputAction: textInputAction,
    onFieldSubmitted: onFieldSubmitted,
    style: style,
    validator: validator,
    hintText: 'Email',
    keyboardType: TextInputType.emailAddress,
    textCapitalization: TextCapitalization.none
  );
}