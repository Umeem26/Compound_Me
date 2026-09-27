import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';

/// The eight starter habits offered at the end of onboarding (S-01,
/// PRD US-02.2). Names are translated at display time; the one chosen is
/// saved as the habit's name in the language used during onboarding.
enum HabitTemplate {
  exercise(
    kind: HabitKind.build,
    scheduleType: ScheduleType.timesPerWeek,
    timesPerWeek: 3,
    iconKey: 'barbell',
    colorKey: 'green',
  ),
  read(
    kind: HabitKind.build,
    scheduleType: ScheduleType.daily,
    iconKey: 'bookOpen',
    colorKey: 'blue',
  ),
  packLunch(
    kind: HabitKind.build,
    scheduleType: ScheduleType.weekdays,
    scheduleDays: Weekdays.workdays,
    iconKey: 'bowlFood',
    colorKey: 'gold',
  ),
  drinkWater(
    kind: HabitKind.build,
    scheduleType: ScheduleType.daily,
    iconKey: 'drop',
    colorKey: 'teal',
  ),
  cafeCoffee(
    kind: HabitKind.reduce,
    scheduleType: ScheduleType.daily,
    defaultCost: 25000,
    categoryNameKey: 'catFood',
    iconKey: 'coffee',
    colorKey: 'coral',
  ),
  lateSnacks(
    kind: HabitKind.reduce,
    scheduleType: ScheduleType.daily,
    defaultCost: 20000,
    categoryNameKey: 'catFood',
    iconKey: 'cookie',
    colorKey: 'violet',
  ),
  shortRides(
    kind: HabitKind.reduce,
    scheduleType: ScheduleType.daily,
    defaultCost: 15000,
    categoryNameKey: 'catTransport',
    iconKey: 'motorcycle',
    colorKey: 'slate',
  ),
  impulseBuys(
    kind: HabitKind.reduce,
    scheduleType: ScheduleType.daily,
    defaultCost: 50000,
    categoryNameKey: 'catShopping',
    iconKey: 'shoppingCart',
    colorKey: 'rose',
  );

  const HabitTemplate({
    required this.kind,
    required this.scheduleType,
    required this.iconKey,
    required this.colorKey,
    this.scheduleDays = 0,
    this.timesPerWeek,
    this.defaultCost,
    this.categoryNameKey,
  });

  final HabitKind kind;
  final ScheduleType scheduleType;
  final int scheduleDays;
  final int? timesPerWeek;
  final String iconKey;
  final String colorKey;

  /// Example cost of one occurrence; the user can edit it (reduce only).
  final Money? defaultCost;

  /// Default expense category the check-in expenses go to (reduce only).
  final String? categoryNameKey;

  /// Reduce habits have no weekly limit yet; it is set later in S-21.
  HabitDraft toDraft({
    required String name,
    Money? cost,
    String? walletId,
    String? categoryId,
  }) => HabitDraft(
    name: name,
    kind: kind,
    iconKey: iconKey,
    colorKey: colorKey,
    scheduleType: scheduleType,
    scheduleDays: scheduleDays,
    timesPerWeek: timesPerWeek,
    costPerOccurrence: kind == HabitKind.reduce ? cost ?? defaultCost : null,
    walletId: kind == HabitKind.reduce ? walletId : null,
    categoryId: kind == HabitKind.reduce ? categoryId : null,
  );
}
