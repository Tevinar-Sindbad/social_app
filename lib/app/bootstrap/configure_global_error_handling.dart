import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Installs app-wide error handlers for Flutter, platform, and BLoC errors.
///
/// This is intended to run early during startup, before dependency injection is
/// fully initialized, so unexpected bootstrap errors can still be logged.
void configureGlobalErrorHandling() {
  // Catches errors reported by the Flutter framework itself,
  // such as build, layout, and paint failures.
  FlutterError.onError = (details) {
    unawaited(
      Sentry.captureException(details.exception, stackTrace: details.stack),
    );
    FlutterError.presentError(details);
  };

  // Catches uncaught top-level async/runtime errors
  // that happen outside Flutter framework callbacks.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(Sentry.captureException(error, stackTrace: stackTrace));
    return true;
  };
}
