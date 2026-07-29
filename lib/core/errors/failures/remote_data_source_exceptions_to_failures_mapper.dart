import 'package:social_app/core/errors/failures/failure_messages.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';

/// Maps one non-feature-specific exception into the app-facing [Failure]
/// hierarchy.
///
/// This is the boundary where infrastructure and parsing exceptions are turned
/// into user-safe failures that presentation and domain layers can consume.
/// Messages produced here are intentionally broader and safer than the raw
/// exception details.
Failure mapRemoteDataSourceExceptionToFailure(Object error) {
  if (error is RemoteNetworkException) {
    return const NetworkFailure();
  }

  if (error is RemoteUnauthorizedException) {
    return const UnauthorizedFailure();
  }

  if (error is RemoteInvalidResponseException) {
    return const UnexpectedFailure();
  }

  if (error is RemoteServerException) {
    return _mapServerExceptionToFailure(error);
  }

  if (error is RemoteUnexpectedException) {
    return const UnexpectedFailure();
  }

  return const UnexpectedFailure();
}

/// Maps one validated backend [RemoteServerException] into a generic [Failure].
///
/// Feature-owned backend codes are handled in feature-specific mappers before
/// delegating back to this generic fallback mapper.
Failure _mapServerExceptionToFailure(RemoteServerException error) {
  switch (error.code) {
    case 'bad_request':
    case 'validation_error':
      return const ValidationFailure(CommonFailureMessages.invalidRequest);

    case 'invalid_refresh_token':
    case 'invalid_access_token':
    case 'unauthorized':
      return const UnauthorizedFailure();

    case 'forbidden':
      return const ForbiddenFailure();

    case 'not_found':
      return const NotFoundFailure();

    case 'conflict':
      return const ValidationFailure(CommonFailureMessages.conflict);

    default:
      return _mapServerExceptionStatusToFailure(error);
  }
}

/// Provides a coarse fallback mapping when the backend code is unknown.
///
/// This keeps the client behavior reasonable for new or unhandled backend
/// error codes by falling back to the HTTP status code instead of always
/// collapsing immediately to [UnexpectedFailure].
Failure _mapServerExceptionStatusToFailure(RemoteServerException error) {
  switch (error.statusCode) {
    case 400:
      return const ValidationFailure(CommonFailureMessages.invalidRequest);

    case 401:
      return const UnauthorizedFailure();

    case 403:
      return const ForbiddenFailure();

    case 404:
      return const NotFoundFailure();

    case 409:
      return const ValidationFailure(CommonFailureMessages.conflict);

    default:
      return const UnexpectedFailure();
  }
}
