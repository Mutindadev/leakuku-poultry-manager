import 'package:flutter/foundation.dart';

typedef CrashReporter = void Function(Object error, StackTrace? stackTrace);

class ErrorHandler {
  static CrashReporter? _crashReporter;

  static void setCrashReporter(CrashReporter reporter) {
    _crashReporter = reporter;
  }

  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logError(details.exception, details.stack);
    };
  }

  static void logError(Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    if (_crashReporter != null) {
      _crashReporter!(error, stackTrace);
      return;
    }

    if (kReleaseMode) {
      debugPrint('Release error: $error');
      if (stackTrace != null) {
        debugPrint('Release stack trace: $stackTrace');
      }
    }
  }
}
