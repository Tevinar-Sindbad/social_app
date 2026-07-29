import 'package:flutter/material.dart';

/// A post editor widget that allows the user to edit the content of a post.
class PostEditor extends StatelessWidget {
  /// Creates a [PostEditor].
  const PostEditor({
    required this.controller,
    required this.hintText,
    super.key,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.minLines = 1,
    this.maxLines,
    this.textCapitalization = TextCapitalization.sentences,
  });

  /// The controller.
  final TextEditingController controller;

  /// The hint text.
  final String hintText;

  /// Keyboard layout used for the field.
  final TextInputType? keyboardType;

  /// Preferred action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Autofill metadata exposed to the platform.
  final Iterable<String>? autofillHints;

  /// Minimum number of visible lines.
  final int? minLines;

  /// Maximum number of visible lines.
  final int? maxLines;

  /// Automatic capitalization behavior.
  final TextCapitalization textCapitalization;

  @override
  /// The build.
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: hintText,
        hintText: hintText,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing';
        }
        return null;
      },
    );
  }
}
