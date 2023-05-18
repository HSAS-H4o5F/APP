/*
 * This file is part of hsas_h4o5f_app.
 * Copyright (c) 2023 HSAS H4o5F Team. All Rights Reserved.
 *
 * hsas_h4o5f_app is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * hsas_h4o5f_app is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:hsas_h4o5f_app/ext.dart';

/// This is a text form field.
///
/// The user can enter text into this field. The text that the user
/// enters is stored in the [controller]. The [controller] is a
/// [TextEditingController].
///
/// The [labelText] is the text that is displayed in the field
/// when the field is empty.
///
/// The [onFieldSubmitted] callback is called when the user
/// submits the form. The [controller] contains the text that
/// the user entered into the field.
///
/// The [suffixIcon] is the widget displayed at the end of the field.
///
/// The [validator] callback is called when the user attempts
/// to submit the form. The [validator] callback returns a
/// string describing the error that occurred, or `null` if
/// the validation was successful.
///
/// The [keyboardType] is the type of keyboard that is used
/// to enter text into the field.
///
/// The [autofillHints] are the autofill hints that are provided
/// to the platform's autofill service.
///
/// If [obscureText] is true, the text that the user enters is
/// obscured, for example by hiding it with an asterisk.
///
/// If [enabled] is false, the field is greyed out and the user
/// cannot interact with it.
class MyTextFormField extends StatelessWidget {
  const MyTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.onFieldSubmitted,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
    this.obscureText = false,
    this.enabled = true,
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;
  final void Function() onFieldSubmitted;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofillHints: autofillHints,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        suffixIcon: suffixIcon,
      ),
      validator: validator ??
          (value) {
            if (value!.isEmpty) {
              return AppLocalizations.of(context)!.requiredField;
            }
            return null;
          },
      onFieldSubmitted: (_) => onFieldSubmitted(),
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
    );
  }
}
