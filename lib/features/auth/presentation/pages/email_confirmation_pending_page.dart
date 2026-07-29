import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/ui/feedback/show_snackbar.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_app/features/auth/presentation/widgets/auth_gradient_button.dart';

/// Page shown after sign-up when email confirmation is required.
class EmailConfirmationPendingPage extends StatelessWidget {
  /// Creates a [EmailConfirmationPendingPage].
  const EmailConfirmationPendingPage({
    required this.email,
    super.key,
  });

  /// Email address waiting for confirmation.
  final String email;

  Future<void> _goToSignIn(BuildContext context) async {
    await context.read<AppUserCubit>().cancelAwaitingEmailConfirmation();
    if (!context.mounted) {
      return;
    }

    const SignInPageRoute().go(context);
  }

  Future<void> _handleBack(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    await _goToSignIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () async {
            await _handleBack(context);
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showSnackBar(context, state.message);
            }

            if (state is AuthConfirmationEmailResent) {
              showSnackBar(
                context,
                'Confirmation email sent again.',
              );
            }
          },
          builder: (context, state) {
            final actionRequiredState = state is AuthConfirmationActionRequired
                ? state
                : null;
            final actionRequired = actionRequiredState != null;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 72,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      actionRequired
                          ? 'Choose how to continue.'
                          : 'Confirm your email.',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      actionRequired
                          ? actionRequiredState.message
                          : 'We sent you a confirmation link. '
                                'Open it from your email to continue in the '
                                'app.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (actionRequired) ...[
                      AuthButton(
                        buttonText: 'Go to Sign In',
                        onPressed: () async {
                          await _goToSignIn(context);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    AuthButton(
                      buttonText: 'Resend Email',
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          AuthResendSignUpConfirmationEmail(email: email),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
