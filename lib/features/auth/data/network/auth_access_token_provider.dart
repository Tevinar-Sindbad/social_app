import 'dart:async';

import 'package:social_app/core/errors/remote_data_source_exceptions/remote_data_source_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bridges the current Supabase access token into backend HTTP and SSE
/// clients.
class AuthAccessTokenProvider {
  /// Creates an [AuthAccessTokenProvider].
  AuthAccessTokenProvider({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  Future<AuthResponse>? _refreshInFlight;

  /// Returns the current access token exposed by Supabase, if any.
  Future<String?> getAccessToken() async {
    return _supabaseClient.auth.currentSession?.accessToken;
  }

  /// Forces one refresh and returns the new access token.
  /// Useful when the backend rejects the current token and the client wants
  /// one recovery attempt before surfacing the auth failure.
  /// This can happen when:
  /// - the access token expired just before the request reached the backend
  /// - the client sent an older token while Supabase had already rotated the
  ///   session in the background
  Future<String> refreshAccessToken() async {
    final response = await _refreshSession();
    final session = response.session;
    if (session == null) {
      throw const RemoteUnauthorizedException(
        message: 'Missing auth session',
      );
    }

    return session.accessToken;
  }

  Future<AuthResponse> _refreshSession() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _runRefresh();
    _refreshInFlight = future;
    return future.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<AuthResponse> _runRefresh() async {
    try {
      return await _supabaseClient.auth.refreshSession();
    } on AuthException {
      await _supabaseClient.auth.signOut();
      rethrow;
    }
  }
}
