import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/features/auth/domain/failures/auth_failure_messages.dart';

/// Minimum allowed password length for email/password authentication.
const int _minimumPasswordLength = 6;
const int _maximumEmailLength = 254;

/// Validates email/password credentials before calling auth repositories.
///
/// Returns a [ValidationFailure] when the email format is invalid or the
/// password is shorter than the minimum accepted length. Returns `null` when
/// both values pass local validation.
ValidationFailure? validateAuthEmailAndPassword({
  required String email,
  required String password,
}) {
  if (!_isValidEmail(email)) {
    return const ValidationFailure(AuthFailureMessages.invalidEmail);
  }

  if (password.length < _minimumPasswordLength) {
    return const ValidationFailure(AuthFailureMessages.invalidPassword);
  }

  return null;
}

/// Validates one auth email address before calling auth repositories.
///
/// Returns a [ValidationFailure] when the email format is invalid. Returns
/// `null` when the email passes local validation.
ValidationFailure? validateAuthEmail(String email) {
  if (!_isValidEmail(email)) {
    return const ValidationFailure(AuthFailureMessages.invalidEmail);
  }

  return null;
}

bool _isValidEmail(String email) {
  if (email.isEmpty || email.length > _maximumEmailLength) {
    return false;
  }

  if (email.contains(' ')) {
    return false;
  }

  final atIndex = email.indexOf('@');
  if (atIndex <= 0 || atIndex != email.lastIndexOf('@')) {
    return false;
  }

  final localPart = email.substring(0, atIndex);
  final domainPart = email.substring(atIndex + 1);

  if (localPart.isEmpty || domainPart.isEmpty) {
    return false;
  }

  if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
    return false;
  }

  final domainLabels = domainPart.split('.');
  if (domainLabels.length < 2) {
    return false;
  }

  return domainLabels.every((label) => label.isNotEmpty);
}
