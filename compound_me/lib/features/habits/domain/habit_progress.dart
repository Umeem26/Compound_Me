import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/schedule.dart';
import 'package:compound_me/features/habits/domain/streak_calculator.dart';
import 'package:meta/meta.dart';

/// How one calendar day of a habit looks (§7.4 HabitCalendar).
enum DayMark {
  /// Checked in (build) or occurred (reduce).
  done,

  /// A single missed scheduled day that kept the streak ("hari longgar").
  grace,

  /// A scheduled day that passed without a check-in.
  missed,

  /// Today, scheduled and still open.
  open,

  /// Not scheduled, before the habit existed, or no per-day target
  /// (weekly and reduce habits).
  unscheduled,

  /// After today.
  future,
}

/// Where a habit stands today: counts, the week so far and its streak.
@immutable
class HabitProgress {
  const HabitProgress({
    required this.habit,
    required this.todayCount,
    required this.weekCount,
    required this.scheduledToday,
    required this.streak,
  });

  final Habit habit;
  final int todayCount;

  /// Occurrences since Monday, today included (05 §4.2: weeks start on
  /// Monday everywhere).
  final int weekCount;
  final bool scheduledToday;

  /// Null for reduce habits without a weekly limit (no streak).
  final StreakResult? streak;

  bool get doneToday => todayCount > 0;

  /// Share of the week's target done, for the HabitChip ring (build
  /// habits with N times per week); 1 or 0 for the rest.
  double get ringProgress {
    final target = habit.timesPerWeek;
    if (habit.kind == HabitKind.build &&
        habit.scheduleType == ScheduleType.timesPerWeek &&
        target != null &&
        target > 0) {
      return (weekCount / target).clamp(0, 1).toDouble();
    }
    return doneToday ? 1 : 0;
  }

  /// Reduce with a weekly limit: at the limit (warning) or past it (danger).
  bool get atWeeklyLimit {
    final limit = habit.weeklyLimit;
    return limit != null && weekCount == limit;
  }

  bool get overWeeklyLimit {
    final limit = habit.weeklyLimit;
    return limit != null && weekCount > limit;
  }
}

/// Counts per day from [logs], which may cover several habits.
Map<LocalDate, int> countsByDate(Iterable<HabitLog> logs) => {
  for (final log in logs) log.date: log.count,
};

HabitProgress progressOf(
  Habit habit,
  Iterable<HabitLog> logs,
  LocalDate today,
) {
  final own = [
    for (final l in logs)
      if (l.habitId == habit.id) l,
  ];
  final counts = countsByDate(own);
  final monday = today.startOfWeek;
  var week = 0;
  for (var day = monday; !day.isAfter(today); day = day.addDays(1)) {
    week += counts[day] ?? 0;
  }
  return HabitProgress(
    habit: habit,
    todayCount: counts[today] ?? 0,
    weekCount: week,
    scheduledToday: isScheduledOn(habit, today),
    streak: StreakCalculator.calculate(habit: habit, logs: own, today: today),
  );
}

/// The home strip (S-10): habits scheduled today, the ones still open
/// first, otherwise in their own order.
List<HabitProgress> todayStrip(List<HabitProgress> all) {
  final scheduled = [
    for (final p in all)
      if (p.scheduledToday && !p.habit.isArchived) p,
  ];
  return [
    for (final p in scheduled)
      if (!p.doneToday) p,
    for (final p in scheduled)
      if (p.doneToday) p,
  ];
}

/// Marks for every day of [month] (§7.4). Only daily and weekday build
/// habits have per-day misses and grace days; weekly and reduce habits show
/// the days they were done.
Map<LocalDate, DayMark> markMonth({
  required Habit habit,
  required Map<LocalDate, int> counts,
  required Set<LocalDate> graceDates,
  required YearMonth month,
  required LocalDate today,
}) {
  final perDay =
      habit.kind == HabitKind.build &&
      habit.scheduleType != ScheduleType.timesPerWeek;
  final marks = <LocalDate, DayMark>{};
  for (
    var day = LocalDate(month.year, month.month, 1);
    day.month == month.month;
    day = day.addDays(1)
  ) {
    final DayMark mark;
    if (day.isAfter(today)) {
      mark = DayMark.future;
    } else if ((counts[day] ?? 0) > 0) {
      mark = DayMark.done;
    } else if (!perDay || !isScheduledOn(habit, day)) {
      mark = DayMark.unscheduled;
    } else if (graceDates.contains(day)) {
      mark = DayMark.grace;
    } else if (day == today) {
      mark = DayMark.open;
    } else {
      mark = DayMark.missed;
    }
    marks[day] = mark;
  }
  return marks;
}
