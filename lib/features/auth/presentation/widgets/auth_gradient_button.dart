import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';

/// A button widget used in the sign in and sign up pages.
class AuthButton extends StatelessWidget {
  /// Creates a [AuthButton].
  const AuthButton({
    required this.buttonText,
    required this.onPressed,
    super.key,
  });

  /// The button text.
  final String buttonText;

  /// The on pressed.
  final VoidCallback onPressed;

  @override
  /// The build.
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is AuthLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
              backgroundColor: AppPallete.primaryGreen,
              foregroundColor: AppPallete.primaryBackgroundColor,
            ),
            child: state is AuthLoading
                ? const Loader(
                    size: 20,
                    color: AppPallete.primaryBackgroundColor,
                  )
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.primaryBackgroundColor,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
