import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/auth_input_validation.dart';

/// Resends the email confirmation message for a pending sign-up account.
///
/// This use case trims the submitted email, validates its format locally, and
/// only then delegates the resend request to the auth repository.
class ResendSignUpConfirmationEmailUseCase implements UseCase<void, String> {
  /// Creates a [ResendSignUpConfirmationEmailUseCase].
  ResendSignUpConfirmationEmailUseCase({required this.authRepository});

  /// Repository responsible for interacting with the auth provider.
  final AuthRepository authRepository;

  @override
  Future<Either<Failure, void>> call(String email) {
    final trimedEmail = email.trim();
    final validationFailure = validateAuthEmail(trimedEmail);
    if (validationFailure != null) {
      return Future.value(left(validationFailure));
    }

    return authRepository.resendSignUpConfirmationEmail(email: trimedEmail);
  }
}
