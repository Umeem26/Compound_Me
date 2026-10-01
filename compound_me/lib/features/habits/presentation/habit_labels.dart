import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/habits/domain/streak_calculator.dart';

String habitKindLabel(AppLocalizations l10n, HabitKind kind) => switch (kind) {
  HabitKind.build => l10n.habitKindBuild,
  HabitKind.reduce => l10n.habitKindReduce,
};

/// "Setiap hari", "Hari kerja", "Sen, Rab, Jum" or "3x/minggu".
String scheduleLabel(AppLocalizations l10n, Habit habit) {
  switch (habit.scheduleType) {
    case ScheduleType.daily:
      return l10n.scheduleDaily;
    case ScheduleType.timesPerWeek:
      return l10n.scheduleTimesPerWeek(habit.timesPerWeek ?? 1);
    case ScheduleType.weekdays:
      if (habit.scheduleDays == Weekdays.workdays) return l10n.scheduleWorkdays;
      final names = l10n.weekdayNames(short: false);
      return [
        for (var day = 1; day <= 7; day++)
          if (habit.scheduleDays & Weekdays.bitFor(day) != 0)
            names[day - 1].substring(0, 3),
      ].join(', ');
  }
}

/// "12 hari" or "3 minggu".
String streakLabel(AppLocalizations l10n, int count, StreakUnit unit) =>
    switch (unit) {
      StreakUnit.days => l10n.streakDays(count),
      StreakUnit.weeks => l10n.streakWeeks(count),
    };

/// "Rp 25.000 per kali" for a reduce habit.
String costLabel(AppLocalizations l10n, Habit habit) =>
    l10n.habitCostPer(formatRupiah(habit.costPerOccurrence ?? 0));

/// "minggu ini 3/4", or "minggu ini 3" without a limit.
String weekCountLabel(AppLocalizations l10n, HabitProgress progress) {
  final limit = progress.habit.weeklyLimit;
  return limit == null
      ? l10n.habitThisWeek(progress.weekCount)
      : l10n.habitThisWeekOf(progress.weekCount, limit);
}

/// What screen readers hear for a check-in control: "Kopi, sudah check-in
/// 2 kali hari ini" (03 §5).
String checkInSemantics(AppLocalizations l10n, HabitProgress progress) {
  final name = progress.habit.name;
  if (!progress.doneToday) return l10n.habitCheckInOpen(name);
  return progress.habit.kind == HabitKind.reduce
      ? l10n.habitCheckInCount(name, progress.todayCount)
      : l10n.habitCheckInDone(name);
}
