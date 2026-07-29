import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

/// Centralizes the app's Material theme configuration.
class AppTheme {
  /// Builds the shared rounded border for text inputs.
  static OutlineInputBorder _border([
    Color color = AppPallete.secondaryBackgroundColor,
  ]) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 3),
    borderRadius: BorderRadius.circular(10),
  );

  /// The application's default dark theme.
  ///
  /// Starts from [ThemeData.dark] and applies the app palette to shared
  /// surfaces, inputs, and text overflow behavior.
  static final ThemeData darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.primaryBackgroundColor,

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(),

      border: _border(),
      focusedBorder: _border(AppPallete.primaryGreen),
      errorBorder: _border(AppPallete.errorColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.primaryBackgroundColor,
      surfaceTintColor: AppPallete.primaryBackgroundColor,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppPallete.primaryBackgroundColor,
    ),
    textTheme: const TextTheme().copyWith(
      headlineLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 40),
      titleLarge: const TextStyle(fontWeight: FontWeight.w800),
      titleSmall: const TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}
