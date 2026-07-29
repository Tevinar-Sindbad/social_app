import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

/// Shows a snackbar with the given content.
void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          content,
          style: const TextStyle(color: AppPallete.textPrimary),
        ),
        backgroundColor: AppPallete.secondaryBackgroundColor,
      ),
    );
}
