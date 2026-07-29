import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:social_app/core/serialization/json_reader.dart';

/// Runs one remote data source operation behind a consistent exception
/// boundary.
///
/// The wrapped [call] is expected to perform transport or parsing work against
/// the backend. This helper translates low-level library exceptions into the
/// app's internal exception model so higher layers do not need to understand
/// Dio-specific failure details.
///
/// Mapping rules:
/// - network-level Dio failures become [RemoteNetworkException]
/// - normalized backend error payloads become [RemoteServerException]
/// - malformed backend payloads become [RemoteInvalidResponseException]
/// - local parsing [FormatException]s become [RemoteInvalidResponseException]
/// - all other unclassified local failures become [RemoteUnexpectedException]
Future<T> guardRemoteDataSourceCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    if (_isNetworkDioException(e)) {
      throw RemoteNetworkException(
        message: e.message ?? 'Network request failed',
      );
    }

    final responseData = e.response?.data;
    if (responseData == null) {
      throw const RemoteInvalidResponseException(
        message: 'Backend error response body is empty',
      );
    }

    throw parseRemoteServerExceptionResponseData(responseData);
  } on RemoteInvalidResponseException {
    rethrow;
  } on RemoteNetworkException {
    rethrow;
  } on RemoteServerException {
    rethrow;
  } on RemoteUnauthorizedException {
    rethrow;
  } on FormatException catch (e) {
    throw RemoteInvalidResponseException(message: e.message);
  } catch (e) {
    throw RemoteUnexpectedException(message: e.toString());
  }
}

/// Returns whether [e] represents a transport failure before any valid backend
/// response could be consumed.
///
/// These failures are mapped separately because there is no backend error
/// contract to parse when the connection itself fails.
bool _isNetworkDioException(DioException e) {
  return e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;
}

/// Parses a backend error payload into a fully populated
/// [RemoteServerException].
/// Throws an [RemoteInvalidResponseException] when the payload does not match
/// the normalized backend error contract.
RemoteServerException parseRemoteServerExceptionResponseData(Object? data) {
  final json = _asJsonMap(data);
  if (json == null) {
    throw const RemoteInvalidResponseException(
      message: 'Backend error response is not a valid JSON object',
    );
  }

  const source = 'Backend error response';

  final message = JsonReader.readNonEmptyString(
    json,
    'message',
    source: source,
  );
  final code = JsonReader.readNonEmptyString(
    json,
    'code',
    source: source,
  );
  final statusCode = JsonReader.readInt(
    json,
    'statusCode',
    source: source,
  );
  final path = JsonReader.readNonEmptyString(
    json,
    'path',
    source: source,
  );
  final timestamp = JsonReader.readDateTime(
    json,
    'timestamp',
    source: source,
  );

  return RemoteServerException(
    message: message,
    code: code,
    statusCode: statusCode,
    path: path,
    timestamp: timestamp,
  );
}

/// Attempts to normalize [data] into a JSON object map.
///
/// This helper accepts already-decoded object maps and JSON strings. It
/// returns `null` when [data] is empty, not an object, or cannot be safely
/// represented as `Map<String, dynamic>`.
Map<String, dynamic>? _asJsonMap(Object? data) {
  if (data is String) {
    if (data.isEmpty) {
      return null;
    }

    try {
      return _asJsonMap(jsonDecode(data));
    } on FormatException {
      return null;
    }
  }

  if (data is Map<String, dynamic>) {
    return data;
  }

  if (data is Map) {
    final normalized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      if (key is! String) {
        return null;
      }

      normalized[key] = entry.value;
    }

    return normalized;
  }

  return null;
}
