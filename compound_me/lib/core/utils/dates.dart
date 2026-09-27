import 'package:meta/meta.dart';

/// A calendar day in the user's local time zone, without a time of day.
/// Habit logs are keyed by this (05 §3) so check-ins never drift across
/// days when the device time zone or DST changes.
@immutable
class LocalDate implements Comparable<LocalDate> {
  /// Out-of-range parts roll over like [DateTime] (e.g. day 0 = last day of
  /// the previous month).
  factory LocalDate(int year, int month, int day) {
    final normalized = DateTime.utc(year, month, day);
    return LocalDate._(normalized.year, normalized.month, normalized.day);
  }

  const LocalDate._(this.year, this.month, this.day);

  /// The local calendar day of [value]; UTC values are converted first.
  factory LocalDate.fromDateTime(DateTime value) {
    final local = value.isUtc ? value.toLocal() : value;
    return LocalDate._(local.year, local.month, local.day);
  }

  /// Parses the `YYYY-MM-DD` storage format.
  factory LocalDate.parse(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) throw FormatException('Not a YYYY-MM-DD date', iso);
    return LocalDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  final int year;
  final int month;
  final int day;

  DateTime get _utcMidnight => DateTime.utc(year, month, day);

  /// 1 = Monday ... 7 = Sunday, like [DateTime.weekday].
  int get weekday => _utcMidnight.weekday;

  /// Weeks run Monday to Sunday (05 §4.2).
  LocalDate get startOfWeek => addDays(1 - weekday);

  LocalDate addDays(int days) => LocalDate(year, month, day + days);

  /// Whole days from this date to [other]; negative when [other] is earlier.
  int daysUntil(LocalDate other) =>
      other._utcMidnight.difference(_utcMidnight).inDays;

  /// Local midnight at the start of this day.
  DateTime get startLocal => DateTime(year, month, day);

  /// This day at [hour]:00 local time.
  DateTime atLocalHour(int hour) => DateTime(year, month, day, hour);

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => _utcMidnight.compareTo(other._utcMidnight);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}

/// Normalizes an instant for storage: UTC with millisecond precision.
/// Drift stores date times as ISO text and compares them as text, so every
/// stored value must have the same shape (no microseconds, trailing `Z`).
DateTime toStoredUtc(DateTime value) => DateTime.fromMillisecondsSinceEpoch(
  value.millisecondsSinceEpoch,
  isUtc: true,
);

/// A local calendar month as a half-open UTC range `[start, end)`.
({DateTime start, DateTime end}) localMonthRangeUtc(int year, int month) => (
  start: toStoredUtc(DateTime(year, month)),
  end: toStoredUtc(DateTime(year, month + 1)),
);
