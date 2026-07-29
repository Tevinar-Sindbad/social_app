import 'package:flutter/material.dart';

/// A text form field with built-in required-field validation.
class RequiredTextFormField extends StatelessWidget {
  /// Creates a [RequiredTextFormField].
  const RequiredTextFormField({
    required this.labelText,
    required this.controller,
    super.key,
    this.hintText,
    this.isObscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  /// The field label and the basis for the default validation message.
  final String labelText;

  /// Optional placeholder shown inside the input.
  final String? hintText;

  /// The controller.
  final TextEditingController controller;

  /// Whether the value bool.
  final bool isObscureText;

  /// Keyboard layout used for the field.
  final TextInputType? keyboardType;

  /// Preferred action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Autofill metadata exposed to the platform.
  final Iterable<String>? autofillHints;

  /// Automatic capitalization behavior.
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscureText,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      autocorrect: !isObscureText,
      enableSuggestions: !isObscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return '$labelText is missing!';
        }
        return null;
      },
    );
  }
}
