import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import 'habit_fixtures.dart';

void main() {
  // Sunday 27 September 2026; the week began on Monday the 21st.
  final today = day('2026-09-27');

  group('progressOf', () {
    test('counts today and the week from Monday', () {
      final habit = habitFixture(
        start: day('2026-09-01'),
        kind: HabitKind.reduce,
        weeklyLimit: 3,
      );
      final progress = progressOf(habit, [
        ...logsOn(['2026-09-20']), // Sunday before: another week
        ...logsOn(['2026-09-21', '2026-09-24']),
        ...logsOn(['2026-09-27'], count: 2),
        HabitLog(habitId: 'other', date: today, count: 5),
      ], today);

      expect(progress.todayCount, 2);
      expect(progress.weekCount, 4);
      expect(progress.doneToday, isTrue);
      expect(progress.overWeeklyLimit, isTrue);
      expect(progress.atWeeklyLimit, isFalse);
      expect(progress.streak, isNotNull, reason: 'has a weekly limit');
    });

    test('a reduce habit without a limit has no streak', () {
      final habit = habitFixture(
        start: day('2026-09-01'),
        kind: HabitKind.reduce,
      );
      expect(progressOf(habit, const [], today).streak, isNull);
    });

    test('the ring shows the week for N times a week, else today', () {
      final weekly = habitFixture(
        start: day('2026-09-01'),
        schedule: ScheduleType.timesPerWeek,
        timesPerWeek: 4,
      );
      final daily = habitFixture(start: day('2026-09-01'));
      final logs = logsOn(['2026-09-22', '2026-09-23']);

      expect(progressOf(weekly, logs, today).ringProgress, 0.5);
      expect(progressOf(daily, logs, today).ringProgress, 0);
      expect(progressOf(daily, logsOn(['2026-09-27']), today).ringProgress, 1);
    });
  });

  test("the home strip keeps today's habits, open ones first", () {
    Habit habit(String id, {int days = Weekdays.all}) => Habit(
      id: id,
      name: id,
      kind: HabitKind.build,
      iconKey: 'gift',
      colorKey: 'teal',
      scheduleType: ScheduleType.weekdays,
      scheduleDays: days,
      createdAt: DateTime(2026, 9),
    );
    final done = habit('done');
    final open = habit('open');
    final notToday = habit('weekdays', days: Weekdays.workdays);
    final logs = [HabitLog(habitId: 'done', date: today, count: 1)];

    final strip = todayStrip([
      for (final h in [done, notToday, open]) progressOf(h, logs, today),
    ]);
    expect([for (final p in strip) p.habit.id], ['open', 'done']);
  });

  group('markMonth', () {
    Map<LocalDate, DayMark> marks(
      Habit habit,
      List<HabitLog> logs, {
      Set<LocalDate> grace = const {},
    }) => markMonth(
      habit: habit,
      counts: countsByDate(logs),
      graceDates: grace,
      month: YearMonth(2026, 9),
      today: today,
    );

    test('daily build: done, grace, missed, open today, future', () {
      final habit = habitFixture(start: day('2026-09-20'));
      final result = marks(
        habit,
        logsOn(['2026-09-20', '2026-09-21', '2026-09-23']),
        grace: {day('2026-09-22')},
      );

      expect(result[day('2026-09-19')], DayMark.unscheduled, reason: 'before');
      expect(result[day('2026-09-21')], DayMark.done);
      expect(result[day('2026-09-22')], DayMark.grace);
      expect(result[day('2026-09-24')], DayMark.missed);
      expect(result[day('2026-09-27')], DayMark.open);
      expect(result[day('2026-09-28')], DayMark.future);
      expect(result, hasLength(30));
    });

    test('days off a weekday schedule stay plain', () {
      final habit = habitFixture(
        start: day('2026-09-01'),
        schedule: ScheduleType.weekdays,
        scheduleDays: Weekdays.monday,
      );
      final result = marks(habit, const []);

      expect(result[day('2026-09-21')], DayMark.missed, reason: 'a Monday');
      expect(result[day('2026-09-22')], DayMark.unscheduled);
    });

    test('weekly and reduce habits have no per-day misses', () {
      final weekly = habitFixture(
        start: day('2026-09-01'),
        schedule: ScheduleType.timesPerWeek,
        timesPerWeek: 3,
      );
      final reduce = habitFixture(
        start: day('2026-09-01'),
        kind: HabitKind.reduce,
      );
      final logs = logsOn(['2026-09-10']);

      for (final habit in [weekly, reduce]) {
        final result = marks(habit, logs);
        expect(result[day('2026-09-10')], DayMark.done);
        expect(result[day('2026-09-11')], DayMark.unscheduled);
        expect(result.values, isNot(contains(DayMark.missed)));
      }
    });
  });
}
