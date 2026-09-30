import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  final today = LocalDate(2026, 9, 25);

  setUpAll(initializeDateFormatting);

  test('day parts follow 03 S-10', () {
    DayPart at(int hour, [int minute = 0]) =>
        dayPartOf(DateTime(2026, 9, 25, hour, minute));

    expect(at(4), DayPart.morning);
    expect(at(9, 59), DayPart.morning);
    expect(at(10), DayPart.midday);
    expect(at(15), DayPart.afternoon);
    expect(at(17, 59), DayPart.afternoon);
    expect(at(18), DayPart.night);
    expect(at(3, 59), DayPart.night);
    expect(at(0), DayPart.night);
  });

  test('greeting uses the name, and reads naturally without one', () {
    final morning = DateTime(2026, 9, 25, 8);

    expect(id.greeting(morning, 'Raka'), 'Selamat pagi, Raka');
    expect(id.greeting(morning, ''), 'Selamat pagi');
    expect(id.greeting(morning, '   '), 'Selamat pagi');
    expect(
      id.greeting(DateTime(2026, 9, 25, 12), 'Raka'),
      'Selamat siang, Raka',
    );
    expect(
      id.greeting(DateTime(2026, 9, 25, 16), 'Raka'),
      'Selamat sore, Raka',
    );
    expect(
      id.greeting(DateTime(2026, 9, 25, 21), 'Raka'),
      'Selamat malam, Raka',
    );
    expect(en.greeting(DateTime(2026, 9, 25, 21), ''), 'Good evening');
  });

  test('day headers: today, yesterday, then weekday and date', () {
    expect(id.dayLabel(today, today), 'Hari ini');
    expect(id.dayLabel(today.addDays(-1), today), 'Kemarin');
    expect(id.dayLabel(LocalDate(2026, 9, 21), today), 'Senin, 21 Sep');
    expect(en.dayLabel(LocalDate(2026, 9, 21), today), 'Monday, 21 Sep');
    expect(id.dayLabel(LocalDate(2025, 12, 31), today), 'Rabu, 31 Des 2025');
  });

  test('times and full dates follow the language', () {
    final at = DateTime(2026, 9, 25, 8, 12);

    expect(id.timeOfDay(at), '08.12');
    expect(en.timeOfDay(at), '08:12');
    expect(id.dayAndTime(at, today), 'Hari ini, 08.12');
    expect(id.fullDateTime(at), 'Jumat, 25 September 2026, 08.12');
    expect(en.fullDateTime(at), 'Friday, 25 September 2026, 08:12');
    expect(id.longDate(at), 'Jumat, 25 September');
    expect(id.monthLabel(2026, 9), 'September 2026');
    expect(en.monthLabel(2026, 8, withYear: false), 'August');
  });
}
