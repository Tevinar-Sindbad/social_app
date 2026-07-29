/// Authentication-specific user-facing failure messages.
abstract final class AuthFailureMessages {
  /// Message used when an email address is invalid.
  static const invalidEmail = 'Please enter a valid email address.';

  /// Message used when the password does not satisfy client rules.
  static const invalidPassword = 'Password must be at least 6 characters long.';

  /// Message used when the submitted credentials are rejected.
  static const invalidCredentials = 'Invalid email or password.';

  /// Message used when the submitted email is already registered.
  static const emailAlreadyInUse = 'Email already in use.';

  /// Message used when the submitted display name is invalid.
  static const invalidName = 'Please enter a valid name.';

  /// Message used when the email must be confirmed before signing in.
  static const emailNotConfirmed =
      'Please confirm your email address before signing in.';

  /// Message used when the email confirmation link can no longer be used.
  static const emailConfirmationLinkExpired =
      'This confirmation link is invalid or has expired. '
      'Request a new one and try again.';

  /// Message used when confirmation succeeded but the app could not complete
  /// the callback-to-session exchange anymore.
  static const confirmationSessionExpired =
      'Your email was confirmed, but the app could not finish signing you in. '
      'Please sign in again.';

  /// Message used when the confirmation flow can no longer complete on the
  /// current device and the user must either sign in or request a new email.
  static const confirmationActionRequired =
      'This confirmation link can no longer complete on this device. '
      'If you already confirmed your email, sign in. '
      'Otherwise request a new confirmation email.';

  /// Message used when the local device identifier is invalid.
  static const invalidDeviceId =
      'Unable to validate this device. Please try again.';

  /// Message used when the account is already signed in on this device.
  static const alreadySignedInOnDevice =
      'This account is already signed in on this device.';
}
