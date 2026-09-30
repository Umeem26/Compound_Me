import 'package:compound_me/core/utils/dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDate', () {
    test('parses and prints the YYYY-MM-DD storage format', () {
      final date = LocalDate.parse('2026-09-07');

      expect(date.year, 2026);
      expect(date.month, 9);
      expect(date.day, 7);
      expect(date.toIso(), '2026-09-07');
      expect(date.toString(), '2026-09-07');
      expect(() => LocalDate.parse('2026/09/07'), throwsFormatException);
    });

    test('rolls over months and years when adding days', () {
      expect(LocalDate(2025, 12, 31).addDays(1), LocalDate(2026, 1, 1));
      expect(LocalDate(2026, 3, 1).addDays(-1), LocalDate(2026, 2, 28));
      expect(LocalDate(2026, 1, 0), LocalDate(2025, 12, 31));
    });

    test('weeks start on Monday', () {
      final sunday = LocalDate(2026, 9, 27);

      expect(sunday.weekday, DateTime.sunday);
      expect(sunday.startOfWeek, LocalDate(2026, 9, 21));
      expect(LocalDate(2026, 9, 21).startOfWeek, LocalDate(2026, 9, 21));
    });

    test('compares and measures distance in days', () {
      final a = LocalDate(2026, 9, 1);
      final b = LocalDate(2026, 10, 1);

      expect(a.daysUntil(b), 30);
      expect(b.daysUntil(a), -30);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.compareTo(a), 0);
      expect({a, LocalDate(2026, 9, 1)}, hasLength(1));
    });

    test('takes the local calendar day of a DateTime', () {
      final local = DateTime(2026, 9, 27, 23, 30);

      expect(LocalDate.fromDateTime(local), LocalDate(2026, 9, 27));
      expect(LocalDate.fromDateTime(local.toUtc()), LocalDate(2026, 9, 27));
      expect(LocalDate(2026, 9, 27).startLocal, DateTime(2026, 9, 27));
      expect(LocalDate(2026, 9, 27).atLocalHour(12), DateTime(2026, 9, 27, 12));
    });
  });

  test('toStoredUtc drops microseconds and converts to UTC', () {
    final stored = toStoredUtc(DateTime(2026, 9, 27, 10, 0, 0, 123, 456));

    expect(stored.isUtc, isTrue);
    expect(stored.microsecond, 0);
    expect(stored.millisecond, 123);
    expect(stored.toIso8601String(), endsWith('.123Z'));
  });

  test('localMonthRangeUtc spans the local month as UTC instants', () {
    final range = localMonthRangeUtc(2026, 12);

    expect(range.start, DateTime(2026, 12).toUtc());
    expect(range.end, DateTime(2027).toUtc());
    expect(range.start.isUtc, isTrue);
  });

  group('YearMonth', () {
    test('rolls over years and counts months between', () {
      expect(YearMonth(2026, 13), YearMonth(2027, 1));
      expect(YearMonth(2026, 1).addMonths(-1), YearMonth(2025, 12));
      expect(YearMonth(2025, 11).monthsUntil(YearMonth(2026, 2)), 3);
      expect(YearMonth(2026, 2).monthsUntil(YearMonth(2025, 11)), -3);
    });

    test('orders months and reads local time', () {
      expect(YearMonth(2026, 8).compareTo(YearMonth(2026, 9)), lessThan(0));
      expect(YearMonth(2026, 9).compareTo(YearMonth(2026, 9)), 0);
      expect(YearMonth(2027, 1).compareTo(YearMonth(2026, 12)), greaterThan(0));
      expect(YearMonth.of(DateTime(2026, 9, 30, 23)), YearMonth(2026, 9));
    });

    test('parses the ?month= link form only', () {
      expect(YearMonth.tryParse('2026-09'), YearMonth(2026, 9));
      expect(YearMonth(2026, 9).toIso(), '2026-09');
      expect(YearMonth.tryParse('2026-13'), isNull);
      expect(YearMonth.tryParse('2026-9'), isNull);
      expect(YearMonth.tryParse(null), isNull);
    });
  });
}
