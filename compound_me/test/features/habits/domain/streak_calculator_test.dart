import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'habit_fixtures.dart';

// 2026-09-27 is a Sunday; 2026-09-21 and 2026-09-28 are Mondays.
final LocalDate _sunday = day('2026-09-27');

StreakResult _calc(Habit habit, List<HabitLog> logs, LocalDate today) =>
    StreakCalculator.calculate(habit: habit, logs: logs, today: today)!;

void main() {
  final daily = habitFixture(start: day('2026-09-20'));

  group('daily streak (05 §4.3 required cases)', () {
    test('no logs: no streak', () {
      final result = _calc(daily, const [], _sunday);

      expect(result.current, 0);
      expect(result.best, 0);
      expect(result.graceDates, isEmpty);
      expect(result.unit, StreakUnit.days);
    });

    test('running streak counts until yesterday while today is open', () {
      final logs = logsOn(daysBetween('2026-09-21', '2026-09-26'));

      expect(_calc(daily, logs, _sunday).current, 6);
      expect(
        _calc(daily, [
          ...logs,
          ...logsOn(['2026-09-27']),
        ], _sunday).current,
        7,
        reason: 'checking in today extends the streak',
      );
    });

    test('one missed day is a grace day, not a break', () {
      final logs = logsOn([
        ...daysBetween('2026-09-20', '2026-09-22'),
        ...daysBetween('2026-09-24', '2026-09-26'),
      ]);
      final result = _calc(daily, logs, _sunday);

      expect(result.current, 6);
      expect(result.graceDates, {day('2026-09-23')});
    });

    test('missing only yesterday keeps the streak alive', () {
      final logs = logsOn(daysBetween('2026-09-20', '2026-09-25'));
      final result = _calc(daily, logs, _sunday);

      expect(result.current, 6);
      expect(result.graceDates, {day('2026-09-26')});
    });

    test('two missed days in a row reset the streak', () {
      final logs = logsOn([
        ...daysBetween('2026-09-20', '2026-09-22'),
        ...daysBetween('2026-09-25', '2026-09-26'),
      ]);
      final result = _calc(daily, logs, _sunday);

      expect(result.current, 2);
      expect(result.best, 3);
      expect(result.graceDates, isEmpty);
    });

    test('missing yesterday and the day before ends the streak', () {
      final logs = logsOn(daysBetween('2026-09-20', '2026-09-24'));

      expect(_calc(daily, logs, _sunday).current, 0);
    });

    test('unscheduled days in between are skipped, not missed', () {
      final workdays = habitFixture(
        start: day('2026-09-14'),
        schedule: ScheduleType.weekdays,
        scheduleDays: Weekdays.workdays,
      );
      final logs = logsOn([
        ...daysBetween('2026-09-14', '2026-09-18'),
        ...daysBetween('2026-09-21', '2026-09-25'),
      ]);
      final result = _calc(workdays, logs, _sunday);

      expect(result.current, 10);
      expect(result.graceDates, isEmpty);
    });

    test('streaks cross month and year boundaries', () {
      final habit = habitFixture(start: day('2025-12-29'));
      final logs = logsOn([
        '2025-12-29',
        '2025-12-30',
        '2026-01-01',
        '2026-01-02',
      ]);
      final result = _calc(habit, logs, day('2026-01-02'));

      expect(result.current, 4);
      expect(result.graceDates, {day('2025-12-31')});
    });

    test('best streak remembers an earlier, longer run', () {
      final habit = habitFixture(start: day('2026-09-01'));
      final logs = logsOn([
        ...daysBetween('2026-09-01', '2026-09-10'),
        ...daysBetween('2026-09-24', '2026-09-26'),
      ]);
      final result = _calc(habit, logs, _sunday);

      expect(result.current, 3);
      expect(result.best, 10);
    });
  });

  group('weekly streak', () {
    final threeTimes = habitFixture(
      start: day('2026-08-31'),
      schedule: ScheduleType.timesPerWeek,
      timesPerWeek: 3,
    );
    final wednesday = day('2026-09-30');

    test('timesPerWeek counts successful weeks with one grace week', () {
      final logs = logsOn([
        ...daysBetween('2026-08-31', '2026-09-02'),
        ...daysBetween('2026-09-07', '2026-09-09'),
        '2026-09-14',
        ...daysBetween('2026-09-21', '2026-09-23'),
        '2026-09-28',
      ]);
      final result = _calc(threeTimes, logs, wednesday);

      expect(result.unit, StreakUnit.weeks);
      expect(result.current, 3, reason: 'running week is not a failure');
      expect(result.graceDates, {day('2026-09-14')});
    });

    test('the running week counts once its target is reached', () {
      final logs = logsOn([
        ...daysBetween('2026-09-21', '2026-09-23'),
        ...daysBetween('2026-09-28', '2026-09-30'),
      ]);

      expect(_calc(threeTimes, logs, wednesday).current, 2);
    });

    test('two failed weeks in a row reset the weekly streak', () {
      final logs = logsOn([
        ...daysBetween('2026-08-31', '2026-09-02'),
        '2026-09-07',
        '2026-09-14',
        ...daysBetween('2026-09-21', '2026-09-23'),
      ]);
      final result = _calc(threeTimes, logs, wednesday);

      expect(result.current, 1);
      expect(result.best, 1);
    });

    test('the partial creation week is never a failure', () {
      final habit = habitFixture(
        start: day('2026-09-10'),
        schedule: ScheduleType.timesPerWeek,
        timesPerWeek: 3,
      );
      final logs = logsOn([
        ...daysBetween('2026-09-14', '2026-09-16'),
        ...daysBetween('2026-09-21', '2026-09-23'),
      ]);

      expect(_calc(habit, logs, wednesday).current, 2);
    });

    test('reduce habits succeed when a finished week stays within the '
        'limit', () {
      final coffee = habitFixture(
        start: day('2026-08-31'),
        kind: HabitKind.reduce,
        weeklyLimit: 3,
      );
      final logs = [
        ...logsOn(['2026-08-31'], count: 2),
        ...logsOn(['2026-09-07'], count: 4),
        ...logsOn(['2026-09-14']),
        ...logsOn(['2026-09-21'], count: 3),
        ...logsOn(['2026-09-28'], count: 5),
      ];
      final result = _calc(coffee, logs, wednesday);

      expect(result.current, 3, reason: 'week of 09-07 is a grace week');
      expect(result.graceDates, {day('2026-09-07')});
      expect(result.consistency30, isNull);
    });

    test('reduce habits without a weekly limit have no streak', () {
      final coffee = habitFixture(
        start: day('2026-08-31'),
        kind: HabitKind.reduce,
      );

      expect(
        StreakCalculator.calculate(
          habit: coffee,
          logs: const [],
          today: wednesday,
        ),
        isNull,
      );
    });
  });

  group('consistency', () {
    test('30-day consistency ignores an unchecked today', () {
      final habit = habitFixture(start: day('2026-08-01'));
      // Every other day in the 29 closed days (08-29 .. 09-26): 15 of 29.
      final logs = logsOn([
        for (var d = day('2026-08-29'); d.isBefore(_sunday); d = d.addDays(2))
          d.toIso(),
      ]);

      expect(
        StreakCalculator.consistency30(
          habit: habit,
          logs: logs,
          today: _sunday,
        ),
        closeTo(15 / 29, 1e-9),
      );
    });

    test('is null before anything was scheduled', () {
      final habit = habitFixture(start: _sunday);

      expect(
        StreakCalculator.consistency30(
          habit: habit,
          logs: const [],
          today: _sunday,
        ),
        isNull,
      );
    });

    test('times-per-week consistency caps each week at its target', () {
      // Four full weeks before the running week of 2026-09-28 (Wed = 3/7).
      final logs = logsOn([
        ...daysBetween('2026-08-31', '2026-09-06'),
        ...daysBetween('2026-09-07', '2026-09-08'),
        ...daysBetween('2026-09-14', '2026-09-16'),
        '2026-09-28',
      ]);
      final habit = habitFixture(
        start: day('2026-08-01'),
        schedule: ScheduleType.timesPerWeek,
        timesPerWeek: 3,
      );
      final result = StreakCalculator.consistency30(
        habit: habit,
        logs: logs,
        today: day('2026-09-30'),
      );

      // Done: min(7,3) + 2 + 3 + 0 + min(1, 9/7) = 9; target: 4*3 + 9/7.
      expect(result, closeTo(9 / (12 + 9 / 7), 1e-9));
    });
  });
}
