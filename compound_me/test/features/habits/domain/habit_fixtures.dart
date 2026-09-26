import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';

LocalDate day(String iso) => LocalDate.parse(iso);

Habit habitFixture({
  required LocalDate start,
  HabitKind kind = HabitKind.build,
  ScheduleType schedule = ScheduleType.daily,
  int scheduleDays = 0,
  int? timesPerWeek,
  int? weeklyLimit,
}) => Habit(
  id: 'h',
  name: kind == HabitKind.build ? 'Baca' : 'Kopi',
  kind: kind,
  iconKey: 'gift',
  colorKey: 'teal',
  scheduleType: schedule,
  scheduleDays: scheduleDays,
  timesPerWeek: timesPerWeek,
  costPerOccurrence: kind == HabitKind.reduce ? 25000 : null,
  walletId: kind == HabitKind.reduce ? 'w' : null,
  categoryId: kind == HabitKind.reduce ? 'c' : null,
  weeklyLimit: weeklyLimit,
  // Noon local time keeps startDate stable in any time zone.
  createdAt: start.atLocalHour(12),
);

List<HabitLog> logsOn(Iterable<String> isoDates, {int count = 1}) => [
  for (final iso in isoDates)
    HabitLog(habitId: 'h', date: LocalDate.parse(iso), count: count),
];

/// Consecutive ISO dates from [from] to [to] inclusive.
List<String> daysBetween(String from, String to) {
  final end = LocalDate.parse(to);
  return [
    for (var d = LocalDate.parse(from); !d.isAfter(end); d = d.addDays(1))
      d.toIso(),
  ];
}
