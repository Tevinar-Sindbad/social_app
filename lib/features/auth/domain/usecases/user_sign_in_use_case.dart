import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/auth_input_validation.dart';

/// Signs an existing user into the app with email and password credentials.
///
/// This use case trims the submitted email, validates the credentials locally,
/// and then delegates the actual sign-in request to the auth repository.
class UserSignInUseCase implements UseCase<void, UserSignInParams> {
  /// Creates a [UserSignInUseCase].
  UserSignInUseCase({required this.authRepositoy});

  /// Repository responsible for authenticating the user.
  final AuthRepository authRepositoy;

  @override
  Future<Either<Failure, void>> call(UserSignInParams params) {
    final email = params.email.trim();
    final validationFailure = validateAuthEmailAndPassword(
      email: email,
      password: params.password,
    );
    if (validationFailure != null) {
      return Future.value(left(validationFailure));
    }

    return authRepositoy.signInWithEmailPassword(
      email: email,
      password: params.password,
    );
  }
}

/// Input required to sign in with email and password.
class UserSignInParams {
  /// Creates a [UserSignInParams].
  UserSignInParams({required this.email, required this.password});

  /// Email address used to authenticate the user.
  final String email;

  /// Raw password submitted for authentication.
  final String password;
}
