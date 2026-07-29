import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:social_app/core/config/env_variables.dart';

/// Initializes Sentry when a DSN is provided and then runs the app bootstrap.
Future<void> initSentry(FutureOr<void> Function() appRunner) async {
  final sentryDsn = EnvVariables.sentryDsn;

  if (sentryDsn.isEmpty) {
    await appRunner();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = sentryDsn
        ..environment = EnvVariables.appEnv.value
        ..release = EnvVariables.sentryRelease
        ..tracesSampleRate = EnvVariables.sentryTracesSampleRate;
    },
    appRunner: appRunner,
  );
}
