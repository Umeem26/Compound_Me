import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:meta/meta.dart';

/// Build = do more of it; reduce = do less of it, and it costs money (PRD §5).
enum HabitKind { build, reduce }

enum ScheduleType { daily, weekdays, timesPerWeek }

/// Bitmask for [ScheduleType.weekdays]: Monday = 1 ... Sunday = 64 (05 §3).
abstract final class Weekdays {
  static const monday = 1;
  static const tuesday = 2;
  static const wednesday = 4;
  static const thursday = 8;
  static const friday = 16;
  static const saturday = 32;
  static const sunday = 64;
  static const int workdays = monday | tuesday | wednesday | thursday | friday;
  static const all = 127;

  /// Bit for a [DateTime.weekday] value (1 = Monday ... 7 = Sunday).
  static int bitFor(int weekday) => 1 << (weekday - 1);
}

@immutable
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.colorKey,
    required this.scheduleType,
    required this.createdAt,
    this.scheduleDays = 0,
    this.timesPerWeek,
    this.costPerOccurrence,
    this.walletId,
    this.categoryId,
    this.weeklyLimit,
    this.sortOrder = 0,
    DateTime? updatedAt,
    this.archivedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  final String id;
  final String name;
  final HabitKind kind;
  final String iconKey;
  final String colorKey;
  final ScheduleType scheduleType;

  /// [Weekdays] bitmask, used when [scheduleType] is weekdays.
  final int scheduleDays;

  /// 1–7, used when [scheduleType] is timesPerWeek.
  final int? timesPerWeek;

  /// Reduce only: cost of one occurrence, the wallet it is paid from and the
  /// expense category it is logged under.
  final Money? costPerOccurrence;
  final String? walletId;
  final String? categoryId;

  /// Reduce only, optional: a week succeeds when occurrences stay at or
  /// under this limit.
  final int? weeklyLimit;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  /// The first day the habit can be scheduled.
  LocalDate get startDate => LocalDate.fromDateTime(createdAt);
}

/// Editable fields of a habit.
@immutable
class HabitDraft {
  const HabitDraft({
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.colorKey,
    required this.scheduleType,
    this.scheduleDays = 0,
    this.timesPerWeek,
    this.costPerOccurrence,
    this.walletId,
    this.categoryId,
    this.weeklyLimit,
  });

  final String name;
  final HabitKind kind;
  final String iconKey;
  final String colorKey;
  final ScheduleType scheduleType;
  final int scheduleDays;
  final int? timesPerWeek;
  final Money? costPerOccurrence;
  final String? walletId;
  final String? categoryId;
  final int? weeklyLimit;
}

/// Occurrences of a habit on one local day. Build habits always log 1.
@immutable
class HabitLog {
  const HabitLog({
    required this.habitId,
    required this.date,
    required this.count,
    this.id = '',
  });

  final String id;
  final String habitId;
  final LocalDate date;
  final int count;
}
