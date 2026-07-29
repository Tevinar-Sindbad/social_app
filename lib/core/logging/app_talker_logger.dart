import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:social_app/core/config/app_env_enum.dart';
import 'package:talker/talker.dart';

/// A app talker logger.
class AppTalkerLogger {
  /// Creates a [AppTalkerLogger].
  AppTalkerLogger({
    required Talker talker,
    required AppEnv appEnv,
  }) : _talker = talker,
       _appEnv = appEnv;
  final Talker _talker;
  final AppEnv _appEnv;

  /// Logs a debug message.
  void debug(String message, [Object? data]) {
    if (_appEnv != AppEnv.local) {
      return;
    }

    _talker.debug(message, data);
  }

  /// Logs an informational message.
  void info(String message, [Object? data]) {
    if (_appEnv != AppEnv.local) {
      return;
    }

    _talker.info(message, data);
  }

  /// Logs a warning message.
  void warning(String message, [Object? data]) {
    if (_appEnv != AppEnv.local) {
      return;
    }

    _talker.warning(message, data);
  }

  /// Logs an error and forwards it to Sentry.
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_appEnv == AppEnv.local) {
      _talker.error(message, error, stackTrace);
    }

    if (error != null) {
      unawaited(
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) async {
            await scope.setContexts('log', {
              'message': message,
            });
          },
        ),
      );
      return;
    }

    unawaited(
      Sentry.captureMessage(
        message,
        withScope: (scope) {
          scope.level = SentryLevel.error;
        },
      ),
    );
  }
}
