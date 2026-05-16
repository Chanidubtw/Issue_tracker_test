import 'package:intl/intl.dart';

class DateFormatter {
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final _csvFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ssZ");

  static String toDate(DateTime dt) => _dateFormat.format(dt);
  static String toDateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String toCsvDate(DateTime dt) => _csvFormat.format(dt);

  static String toRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) return toDate(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
