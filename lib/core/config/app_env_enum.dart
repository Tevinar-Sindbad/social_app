/// Application environments supported by the app.
enum AppEnv {
  /// Local development environment.
  local('local'),

  /// Shared development environment.
  development('development'),

  /// Pre-production staging environment.
  staging('staging'),

  /// Production environment.
  production('production')
  ;

  const AppEnv(this.value);

  /// Serialized environment value used by compile-time config and Sentry.
  final String value;
}
