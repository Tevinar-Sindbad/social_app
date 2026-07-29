import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/auth_input_validation.dart';

/// Creates a new auth account from an email and password pair.
///
/// This use case trims the submitted email, validates both credentials with
/// the shared auth input rules, and only then delegates the sign-up request to
/// the auth repository.
class UserSignUpUseCase implements UseCase<void, UserSignUpParams> {
  /// Creates a [UserSignUpUseCase].
  UserSignUpUseCase({required this.authRepository});

  /// Repository responsible for creating the auth account.
  final AuthRepository authRepository;

  @override
  Future<Either<Failure, void>> call(UserSignUpParams params) {
    final email = params.email.trim();
    final validationFailure = validateAuthEmailAndPassword(
      email: email,
      password: params.password,
    );
    if (validationFailure != null) {
      return Future.value(left(validationFailure));
    }

    return authRepository.signUpWithEmailPassword(
      email: email,
      password: params.password,
    );
  }
}

/// Input required to sign up a new auth account.
class UserSignUpParams {
  /// Creates a [UserSignUpParams].
  UserSignUpParams({
    required this.email,
    required this.password,
  });

  /// Email address used as the account identifier.
  final String email;

  /// Raw password chosen by the user for this account.
  final String password;
}
