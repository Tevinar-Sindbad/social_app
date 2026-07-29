import 'dart:io';

import 'package:dio/dio.dart';
import 'package:social_app/features/auth/data/network/auth_access_token_provider.dart';

/// Dio interceptor that attaches the current bearer token and retries once
/// after
/// an auth refresh when the backend responds with `401` or `403`.
class AuthDioInterceptor extends QueuedInterceptor {
  /// Creates an [AuthDioInterceptor].
  AuthDioInterceptor({
    required Dio dio,
    required AuthAccessTokenProvider authAccessTokenProvider,
  }) : _dio = dio,
       _authAccessTokenProvider = authAccessTokenProvider;

  final Dio _dio;
  final AuthAccessTokenProvider _authAccessTokenProvider;

  static const _retriedKey = 'auth_retry_done';

  @override
  /// Attaches the current Supabase access token before Dio sends the request.
  /// If no authenticated session is available, the request is rejected as a
  /// Dio error instead of being sent without credentials.
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _authAccessTokenProvider.getAccessToken();

      if (accessToken == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const HttpException('Missing auth session'),
          ),
        );
      }

      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';

      handler.next(options);
    } on Object catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
        ),
      );
    }
  }

  @override
  /// Handles backend auth failures after a request was sent.
  /// When the backend responds with `401` or `403`, retries the request once
  /// with a freshly refreshed Supabase access token before surfacing the
  /// original error.
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if ((statusCode != 401 && statusCode != 403) || alreadyRetried) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _authAccessTokenProvider
          .refreshAccessToken();

      final retriedOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          HttpHeaders.authorizationHeader: 'Bearer $newAccessToken',
        },
        extra: {
          ...err.requestOptions.extra,
          _retriedKey: true,
        },
      );

      // Replay the original backend request once with the refreshed token.
      final response = await _dio.fetch<dynamic>(retriedOptions);
      handler.resolve(response);
    } on Object catch (_) {
      handler.next(err);
    }
  }
}
