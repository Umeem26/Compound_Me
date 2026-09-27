import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/schedule.dart';
import 'package:flutter_test/flutter_test.dart';

import 'habit_fixtures.dart';

void main() {
  group('isScheduledOn', () {
    test('daily habits are scheduled every day from their start', () {
      final habit = habitFixture(start: day('2026-09-21'));

      expect(isScheduledOn(habit, day('2026-09-21')), isTrue);
      expect(isScheduledOn(habit, day('2026-09-27')), isTrue);
      expect(isScheduledOn(habit, day('2026-09-20')), isFalse);
    });

    test('weekday habits follow the Monday = 1 ... Sunday = 64 bitmask', () {
      final habit = habitFixture(
        start: day('2026-09-01'),
        schedule: ScheduleType.weekdays,
        scheduleDays: Weekdays.monday | Weekdays.sunday,
      );

      expect(isScheduledOn(habit, day('2026-09-21')), isTrue, reason: 'Mon');
      expect(isScheduledOn(habit, day('2026-09-22')), isFalse, reason: 'Tue');
      expect(isScheduledOn(habit, day('2026-09-27')), isTrue, reason: 'Sun');
    });

    test('work-day habits skip the weekend', () {
      final habit = habitFixture(
        start: day('2026-09-01'),
        schedule: ScheduleType.weekdays,
        scheduleDays: Weekdays.workdays,
      );

      expect(isScheduledOn(habit, day('2026-09-25')), isTrue, reason: 'Fri');
      expect(isScheduledOn(habit, day('2026-09-26')), isFalse, reason: 'Sat');
    });

    test('times-per-week habits may be done on any day', () {
      final habit = habitFixture(
        start: day('2026-09-01'),
        schedule: ScheduleType.timesPerWeek,
        timesPerWeek: 3,
      );

      expect(isScheduledOn(habit, day('2026-09-26')), isTrue);
    });

    test('bitFor maps DateTime weekdays to bits', () {
      expect(Weekdays.bitFor(DateTime.monday), Weekdays.monday);
      expect(Weekdays.bitFor(DateTime.sunday), Weekdays.sunday);
    });
  });
}
