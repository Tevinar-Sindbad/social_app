import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/errors/failures/failure_messages.dart';
import 'package:social_app/core/errors/failures/failures.dart';
import 'package:social_app/core/errors/failures/remote_data_source_exceptions_to_failures_mapper.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';

void main() {
  group('mapExceptionToFailure', () {
    test(
      'given a NetworkException when mapExceptionToFailure is called then '
      'returns NetworkFailure with the correct message',
      () {
        // Arrange
        const error = RemoteNetworkException(message: 'debug message');

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<NetworkFailure>());
        expect(
          failure.message,
          'Unable to reach the server. Check your connection and try again.',
        );
      },
    );

    test(
      'given a ServerException with unauthorized code when '
      'mapExceptionToFailure is called '
      'then returns UnauthorizedFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Token expired',
          code: 'unauthorized',
          statusCode: 401,
        );

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<UnauthorizedFailure>());
        expect(
          failure.message,
          'Your session has expired. Please sign in again.',
        );
      },
    );

    test(
      'given a ServerException with forbidden code when '
      'mapExceptionToFailure is called then returns ForbiddenFailure',
      () {
        final error = _serverException(
          message: 'Forbidden',
          code: 'forbidden',
          statusCode: 403,
        );

        final failure = mapRemoteDataSourceExceptionToFailure(error);

        expect(failure, isA<ForbiddenFailure>());
      },
    );

    test(
      'given a ServerException with not_found code when '
      'mapExceptionToFailure is called '
      'then returns NotFoundFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Resource not found',
          code: 'not_found',
          statusCode: 404,
        );

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<NotFoundFailure>());
        expect(failure.message, 'Requested resource not found.');
      },
    );

    test(
      'given a ServerException with conflict code when '
      'mapExceptionToFailure is called then returns ValidationFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Resource conflict',
          code: 'conflict',
          statusCode: 409,
        );

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, CommonFailureMessages.conflict);
      },
    );

    test(
      'given a ServerException with an unknown code and 400 status when '
      'mapExceptionToFailure is called then returns ValidationFailure from '
      'status fallback',
      () {
        // Arrange
        final error = _serverException(
          message: 'Unrecognized validation payload',
          code: 'unknown_validation_code',
          statusCode: 400,
        );

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, CommonFailureMessages.invalidRequest);
      },
    );

    test(
      'given a ServerException with an unknown code when '
      'mapExceptionToFailure is called then returns UnexpectedFailure',
      () {
        // Arrange
        final error = _serverException(
          message: 'Weird backend error',
          code: '99999',
          statusCode: 500,
        );

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<UnexpectedFailure>());
        expect(failure.message, 'Something went wrong. Please try again.');
      },
    );

    test(
      'given an InvalidResponseException when mapExceptionToFailure is called '
      'then returns UnexpectedFailure',
      () {
        const error = RemoteInvalidResponseException(
          message: 'Response body is missing',
        );

        final failure = mapRemoteDataSourceExceptionToFailure(error);

        expect(failure, isA<UnexpectedFailure>());
      },
    );

    test(
      'given an unknown exception when mapExceptionToFailure is called then '
      'returns UnexpectedFailure',
      () {
        // Arrange
        final error = Exception('Some random exception');

        // Act
        final failure = mapRemoteDataSourceExceptionToFailure(error);

        // Assert
        expect(failure, isA<UnexpectedFailure>());
        expect(failure.message, 'Something went wrong. Please try again.');
      },
    );
  });
}

RemoteServerException _serverException({
  required String message,
  required String code,
  required int statusCode,
}) {
  return RemoteServerException(
    message: message,
    code: code,
    statusCode: statusCode,
    path: '/test',
    timestamp: DateTime.parse('2026-05-12T10:00:00.000Z'),
  );
}
