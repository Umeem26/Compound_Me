import 'package:compound_me/core/l10n/app_localizations.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:intl/intl.dart';

/// Part of the day for the Home greeting (S-10): morning 04–10, midday
/// 10–15, afternoon 15–18 and night 18–04.
enum DayPart { morning, midday, afternoon, night }

DayPart dayPartOf(DateTime local) => switch (local.hour) {
  >= 4 && < 10 => DayPart.morning,
  >= 10 && < 15 => DayPart.midday,
  >= 15 && < 18 => DayPart.afternoon,
  _ => DayPart.night,
};

/// Dates and times as the screens show them (03 §4 "Waktu"). Formats
/// follow [AppLocalizations.localeName], so Indonesian gets "08.12" and
/// "Senin", English "08:12" and "Monday".
extension DateLabels on AppLocalizations {
  /// "Selamat pagi, Raka", or just "Selamat pagi" without a name.
  String greeting(DateTime now, String name) {
    final hello = switch (dayPartOf(now)) {
      DayPart.morning => greetingMorning,
      DayPart.midday => greetingMidday,
      DayPart.afternoon => greetingAfternoon,
      DayPart.night => greetingNight,
    };
    final trimmed = name.trim();
    return trimmed.isEmpty ? hello : greetingWithName(hello, trimmed);
  }

  /// "Hari ini", "Kemarin", otherwise "Senin, 21 Sep"; the year is added
  /// for days outside [today]'s year.
  String dayLabel(LocalDate day, LocalDate today) {
    if (day == today) return dayToday;
    if (day == today.addDays(-1)) return dayYesterday;
    final pattern = day.year == today.year ? 'EEEE, d MMM' : 'EEEE, d MMM y';
    return DateFormat(pattern, localeName).format(day.startLocal);
  }

  /// "08.12" (id) or "08:12" (en).
  String timeOfDay(DateTime value) =>
      DateFormat.Hm(localeName).format(value.toLocal());

  /// "Hari ini, 08.12" for the date row of the transaction form (S-11).
  String dayAndTime(DateTime value, LocalDate today) => dateTimeJoin(
    dayLabel(LocalDate.fromDateTime(value), today),
    timeOfDay(value),
  );

  /// "Jumat, 25 September 2026, 08.12" for the transaction detail (S-12).
  String fullDateTime(DateTime value) => dateTimeJoin(
    DateFormat('EEEE, d MMMM y', localeName).format(value.toLocal()),
    timeOfDay(value),
  );

  /// "Jumat, 25 September" above the Home greeting.
  String longDate(DateTime value) =>
      DateFormat('EEEE, d MMMM', localeName).format(value.toLocal());

  /// "September 2026"; without the year when [withYear] is false.
  String monthLabel(int year, int month, {bool withYear = true}) => DateFormat(
    withYear ? 'MMMM y' : 'MMMM',
    localeName,
  ).format(DateTime(year, month));
}
