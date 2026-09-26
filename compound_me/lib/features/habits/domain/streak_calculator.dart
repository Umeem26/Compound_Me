import 'dart:math' as math;

import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/schedule.dart';
import 'package:meta/meta.dart';

enum StreakUnit { days, weeks }

@immutable
class StreakResult {
  const StreakResult({
    required this.current,
    required this.best,
    required this.unit,
    required this.graceDates,
    required this.consistency30,
  });

  final int current;
  final int best;
  final StreakUnit unit;

  /// "Hari longgar": single misses that did not break the streak. For weekly
  /// streaks these are the Mondays of the forgiven weeks.
  final Set<LocalDate> graceDates;

  /// Share of the scheduled target done in the last 30 days (0–1). Only for
  /// build habits; null when nothing was scheduled yet.
  final double? consistency30;
}

/// Streaks with the "never miss twice" rule (05 §4.3). Pure functions over
/// the habit's logs so they can be tested without a database.
abstract final class StreakCalculator {
  /// Null for reduce habits without a weekly limit: they have no streak.
  static StreakResult? calculate({
    required Habit habit,
    required Iterable<HabitLog> logs,
    required LocalDate today,
  }) {
    final counts = _countsByDate(logs);
    final weekly =
        habit.kind == HabitKind.reduce ||
        habit.scheduleType == ScheduleType.timesPerWeek;
    if (habit.kind == HabitKind.reduce && habit.weeklyLimit == null) {
      return null;
    }

    final run = weekly
        ? _weeklyRun(habit, counts, today)
        : _dailyRun(habit, counts, today);
    return StreakResult(
      current: run.current,
      best: run.best,
      unit: weekly ? StreakUnit.weeks : StreakUnit.days,
      graceDates: run.graces,
      consistency30: habit.kind == HabitKind.build
          ? consistency30(habit: habit, logs: logs, today: today)
          : null,
    );
  }

  /// Consistency over the last 30 days (daily/weekdays) or the last four
  /// complete weeks plus the current week pro rata (timesPerWeek).
  static double? consistency30({
    required Habit habit,
    required Iterable<HabitLog> logs,
    required LocalDate today,
  }) {
    final from = habit.scheduleType == ScheduleType.timesPerWeek
        ? today.startOfWeek.addDays(-28)
        : today.addDays(-29);
    return consistencyBetween(
      habit: habit,
      logs: logs,
      from: from,
      to: today,
      today: today,
    );
  }

  /// Share of the scheduled target done between [from] and [to] inclusive.
  /// Today only counts once it is checked in, so an open day never lowers
  /// the score. Null when nothing was scheduled in the range.
  static double? consistencyBetween({
    required Habit habit,
    required Iterable<HabitLog> logs,
    required LocalDate from,
    required LocalDate to,
    required LocalDate today,
  }) {
    final counts = _countsByDate(logs);
    final start = _latest(from, habit.startDate);
    final end = to.isAfter(today) ? today : to;
    if (end.isBefore(start)) return null;

    if (habit.scheduleType == ScheduleType.timesPerWeek) {
      return _weeklyConsistency(habit, counts, start, end, today);
    }
    var scheduled = 0;
    var done = 0;
    for (var d = start; !d.isAfter(end); d = d.addDays(1)) {
      if (!isScheduledOn(habit, d)) continue;
      final checked = (counts[d] ?? 0) > 0;
      if (d == today && !checked) continue;
      scheduled++;
      if (checked) done++;
    }
    return scheduled == 0 ? null : done / scheduled;
  }

  static double? _weeklyConsistency(
    Habit habit,
    Map<LocalDate, int> counts,
    LocalDate start,
    LocalDate end,
    LocalDate today,
  ) {
    final target = habit.timesPerWeek ?? 1;
    var targetSum = 0.0;
    var doneSum = 0.0;
    for (
      var week = start.startOfWeek;
      !week.isAfter(end);
      week = week.addDays(7)
    ) {
      var activeDays = 0;
      var weekCount = 0;
      for (var i = 0; i < 7; i++) {
        final d = week.addDays(i);
        if (d.isBefore(start) || d.isAfter(end)) continue;
        activeDays++;
        weekCount += counts[d] ?? 0;
      }
      // Partial weeks (creation week, running week) get a pro-rata target.
      final weekTarget = target * activeDays / 7;
      targetSum += weekTarget;
      doneSum += math.min(weekCount.toDouble(), weekTarget);
    }
    return targetSum == 0 ? null : doneSum / targetSum;
  }

  static _Run _dailyRun(
    Habit habit,
    Map<LocalDate, int> counts,
    LocalDate today,
  ) {
    final tracker = _RunTracker();
    for (var d = habit.startDate; !d.isAfter(today); d = d.addDays(1)) {
      if (!isScheduledOn(habit, d)) continue;
      final checked = (counts[d] ?? 0) > 0;
      if (checked) {
        tracker.success();
      } else if (d != today) {
        // Today is still open, so an unchecked today is not a miss yet.
        tracker.miss(d);
      }
    }
    return tracker.finish();
  }

  static _Run _weeklyRun(
    Habit habit,
    Map<LocalDate, int> counts,
    LocalDate today,
  ) {
    final tracker = _RunTracker();
    final firstWeek = habit.startDate.startOfWeek;
    final currentWeek = today.startOfWeek;
    for (
      var week = firstWeek;
      !week.isAfter(currentWeek);
      week = week.addDays(7)
    ) {
      var count = 0;
      for (var i = 0; i < 7; i++) {
        final d = week.addDays(i);
        if (d.isBefore(habit.startDate) || d.isAfter(today)) continue;
        count += counts[d] ?? 0;
      }
      final complete = week != currentWeek;
      final bool succeeded;
      if (habit.kind == HabitKind.reduce) {
        // Staying under the limit is only known once the week is over.
        succeeded = complete && count <= habit.weeklyLimit!;
      } else {
        succeeded = count >= (habit.timesPerWeek ?? 1);
      }
      if (succeeded) {
        tracker.success();
      } else if (complete && week != firstWeek) {
        // The running week and the partial creation week never count as a
        // failure.
        tracker.miss(week);
      }
    }
    return tracker.finish();
  }

  static Map<LocalDate, int> _countsByDate(Iterable<HabitLog> logs) => {
    for (final log in logs) log.date: log.count,
  };

  static LocalDate _latest(LocalDate a, LocalDate b) => a.isAfter(b) ? a : b;
}

class _Run {
  const _Run(this.current, this.best, this.graces);

  final int current;
  final int best;
  final Set<LocalDate> graces;
}

/// Walks periods oldest to newest. One miss after a success is forgiven
/// (a grace period); a second miss in a row ends the run.
class _RunTracker {
  int _run = 0;
  int _best = 0;
  int _misses = 0;
  LocalDate? _pendingGrace;
  final Set<LocalDate> _graces = {};

  void success() {
    _run++;
    _best = math.max(_best, _run);
    _misses = 0;
    if (_pendingGrace != null) {
      _graces.add(_pendingGrace!);
      _pendingGrace = null;
    }
  }

  void miss(LocalDate period) {
    _misses++;
    if (_misses == 1 && _run > 0) {
      _pendingGrace = period;
    } else {
      _run = 0;
      _pendingGrace = null;
    }
  }

  _Run finish() {
    // A single miss at the end (e.g. yesterday) keeps the streak alive.
    if (_pendingGrace != null) _graces.add(_pendingGrace!);
    return _Run(_run, _best, _graces);
  }
}
