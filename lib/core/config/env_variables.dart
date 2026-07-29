import 'package:social_app/core/config/app_env_enum.dart';

/// Compile-time application environment declarations.
///
/// These values are baked into the app at build time and are intended for
/// public environment-specific configuration, not secrets.
class EnvVariables {
  /// Base URL for the Supabase project used by the app.
  static String get supabaseUrl => _readRequiredString(
    value: const String.fromEnvironment('SUPABASE_URL'),
    key: 'SUPABASE_URL',
  );

  /// Public publishable key used by the client to talk to Supabase.
  static String get supabasePublishableKey => _readRequiredString(
    value: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    key: 'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Deep-link URL used by Supabase email confirmation redirects.
  static String get supabaseEmailRedirectUrl => _readRequiredString(
    value: const String.fromEnvironment('SUPABASE_EMAIL_REDIRECT_URL'),
    key: 'SUPABASE_EMAIL_REDIRECT_URL',
  );

  /// Base URL for the backend API.
  static String get backendBaseUrl => _readRequiredString(
    value: const String.fromEnvironment('BACKEND_BASE_URL'),
    key: 'BACKEND_BASE_URL',
  );

  /// Application environment for this build.
  ///
  /// Missing values throw, while invalid values raise a [StateError].
  static AppEnv get appEnv {
    switch (_readRequiredString(
      value: const String.fromEnvironment('APP_ENV'),
      key: 'APP_ENV',
    )) {
      case 'development':
        return AppEnv.development;
      case 'staging':
        return AppEnv.staging;
      case 'production':
        return AppEnv.production;
      case 'local':
        return AppEnv.local;
      default:
        throw StateError(
          'APP_ENV must be one of: local, development, staging, production.',
        );
    }
  }

  /// Optional DSN used to enable Sentry event delivery for this build.
  ///
  /// When omitted, Sentry stays disabled.
  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  /// Release identifier attached to Sentry events for this build.
  static String get sentryRelease => _readRequiredString(
    value: const String.fromEnvironment('SENTRY_RELEASE'),
    key: 'SENTRY_RELEASE',
  );

  /// Fraction of Sentry performance traces to keep for this build.
  ///
  /// The value is provided through
  /// `--dart-define=SENTRY_TRACES_SAMPLE_RATE=...`
  /// and parsed as a `double`.
  static double get sentryTracesSampleRate {
    final raw = _readRequiredString(
      value: const String.fromEnvironment('SENTRY_TRACES_SAMPLE_RATE'),
      key: 'SENTRY_TRACES_SAMPLE_RATE',
    );
    final parsed = double.tryParse(raw);

    if (parsed == null) {
      throw StateError(
        'SENTRY_TRACES_SAMPLE_RATE must be a valid double, got "$raw".',
      );
    }

    return parsed;
  }

  static String _readRequiredString({
    required String value,
    required String key,
  }) {
    if (value.isEmpty) {
      throw StateError('Missing required --dart-define=$key');
    }

    return value;
  }
}
