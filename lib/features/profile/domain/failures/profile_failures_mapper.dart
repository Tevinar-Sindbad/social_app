import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/failures/remote_data_source_exceptions_to_failures_mapper.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/features/profile/domain/failures/profile_failure_messages.dart';

/// Maps profile-owned exceptions and backend error codes into [Failure]s.
Failure mapProfileExceptionToFailure(Object error) {
  if (error is RemoteServerException) {
    switch (error.code) {
      case 'invalid_name':
        return const ValidationFailure(ProfileFailureMessages.invalidName);

      case 'profile_already_exists':
        return const ValidationFailure(
          ProfileFailureMessages.profileAlreadyExists,
        );
    }
  }

  return mapRemoteDataSourceExceptionToFailure(error);
}
