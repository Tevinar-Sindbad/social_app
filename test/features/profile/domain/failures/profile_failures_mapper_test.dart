import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/features/profile/domain/failures/profile_failure_messages.dart';
import 'package:social_app/features/profile/domain/failures/profile_failures_mapper.dart';

void main() {
  group('mapProfileExceptionToFailure', () {
    test(
      'given invalid_name server code then returns a profile-specific '
      'validation failure',
      () {
        final failure = mapProfileExceptionToFailure(
          _serverException(code: 'invalid_name'),
        );

        expect(failure, isA<ValidationFailure>());
        expect(failure.message, ProfileFailureMessages.invalidName);
      },
    );

    test(
      'given profile_already_exists server code then returns a profile-specific'
      ' validation failure',
      () {
        final failure = mapProfileExceptionToFailure(
          _serverException(code: 'profile_already_exists'),
        );

        expect(failure, isA<ValidationFailure>());
        expect(failure.message, ProfileFailureMessages.profileAlreadyExists);
      },
    );

    test(
      'given an unknown exception then falls back to the shared mapper',
      () {
        final failure = mapProfileExceptionToFailure(
          const RemoteNetworkException(message: 'offline'),
        );

        expect(failure, isA<NetworkFailure>());
      },
    );
  });
}

RemoteServerException _serverException({required String code}) {
  return RemoteServerException(
    message: 'profile error',
    code: code,
    statusCode: 400,
    path: '/profile',
    timestamp: DateTime.parse('2026-06-29T12:00:00.000Z'),
  );
}
