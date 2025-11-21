import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kReleaseMode) {
        // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
        debugPrint('Error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      }
    };
  }

  static void logError(Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    // TODO: Send to analytics/crash reporting
  }
}
