import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatDayAndMonth(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  static int daysSince(DateTime startDate) {
    final now = DateTime.now();
    return now.difference(startDate).inDays;
  }
}
