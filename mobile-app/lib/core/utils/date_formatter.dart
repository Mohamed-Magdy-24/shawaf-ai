import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static final DateFormat _telemetryFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm:ss');

  static String toTelemetryString(DateTime dateTimeUtc) {
    return '${_telemetryFormat.format(dateTimeUtc.toUtc())} UTC';
  }

  static String toTimeOnly(DateTime dateTime) {
    return _timeOnlyFormat.format(dateTime.toLocal());
  }

  static String toRelativeTime(DateTime dateTimeUtc) {
    final difference = DateTime.now().toUtc().difference(dateTimeUtc.toUtc());
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
