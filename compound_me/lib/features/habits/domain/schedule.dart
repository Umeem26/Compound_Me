import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/domain/habit.dart';

/// Whether [habit] expects a check-in on [date] (05 §4.2). Days before the
/// habit existed are never scheduled. `timesPerWeek` habits may be done on
/// any day; their target is counted per Monday–Sunday week.
bool isScheduledOn(Habit habit, LocalDate date) {
  if (date.isBefore(habit.startDate)) return false;
  return switch (habit.scheduleType) {
    ScheduleType.daily || ScheduleType.timesPerWeek => true,
    ScheduleType.weekdays =>
      habit.scheduleDays & Weekdays.bitFor(date.weekday) != 0,
  };
}
