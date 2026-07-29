import 'package:dio/dio.dart';
import 'package:social_app/core/config/env_variables.dart';
import 'package:social_app/features/auth/data/network/auth_access_token_provider.dart';
import 'package:social_app/features/auth/data/network/auth_dio_interceptor.dart';

/// Creates the unauthenticated Dio client used for public backend endpoints.
Dio createPublicDio() {
  return Dio(_createBackendBaseOptions());
}

/// Creates the authenticated Dio client used for protected backend endpoints.
Dio createAuthedDio({
  required AuthAccessTokenProvider authAccessTokenProvider,
}) {
  final dio = Dio(_createBackendBaseOptions());

  // Turn this client into the authenticated backend client by attaching the
  // interceptor that injects bearer tokens and retries once after refresh.
  dio.interceptors.add(
    AuthDioInterceptor(
      dio: dio,
      authAccessTokenProvider: authAccessTokenProvider,
    ),
  );

  return dio;
}

/// Creates the shared base options used by all backend HTTP clients.
BaseOptions _createBackendBaseOptions() {
  return BaseOptions(
    baseUrl: EnvVariables.backendBaseUrl,
    headers: {'content-type': 'application/json'},
  );
}
