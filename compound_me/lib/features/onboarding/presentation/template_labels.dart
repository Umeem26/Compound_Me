import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/onboarding/domain/habit_templates.dart';

String templateName(AppLocalizations l10n, HabitTemplate template) =>
    switch (template) {
      HabitTemplate.exercise => l10n.templateExercise,
      HabitTemplate.read => l10n.templateRead,
      HabitTemplate.packLunch => l10n.templatePackLunch,
      HabitTemplate.drinkWater => l10n.templateDrinkWater,
      HabitTemplate.cafeCoffee => l10n.templateCafeCoffee,
      HabitTemplate.lateSnacks => l10n.templateLateSnacks,
      HabitTemplate.shortRides => l10n.templateShortRides,
      HabitTemplate.impulseBuys => l10n.templateImpulseBuys,
    };

String templateSchedule(AppLocalizations l10n, HabitTemplate template) =>
    switch (template.scheduleType) {
      ScheduleType.daily => l10n.scheduleDaily,
      ScheduleType.weekdays => l10n.scheduleWorkdays,
      ScheduleType.timesPerWeek => l10n.scheduleTimesPerWeek(
        template.timesPerWeek ?? 1,
      ),
    };
