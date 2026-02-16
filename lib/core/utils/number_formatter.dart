import 'package:intl/intl.dart';

/// Compact number formatting utility.
///
/// Uses ICU compact notation for human-readable numbers:
///   1930 → "1.9K"
///   257551 → "258K"
///   1234567 → "1.2M"
///
/// For exact values (e.g. in data exports), use [formatExact].
class NumberFormatter {
  NumberFormatter._();

  static final _compact = NumberFormat.compact();
  static final _exact = NumberFormat('#,###');

  /// Format a number in compact notation (e.g. 1.9K, 258K, 1.2M).
  static String compact(num value) {
    return _compact.format(value);
  }

  /// Format a number with comma separators (e.g. 1,930 / 257,551).
  static String exact(num value) {
    return _exact.format(value);
  }
}
