import 'package:compound_me/core/database/seed.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/onboarding/domain/habit_templates.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_draft.dart';
import 'package:compound_me/features/onboarding/presentation/template_labels.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HabitTemplate', () {
    test('offers four build and four reduce habits (US-02.2)', () {
      final kinds = HabitTemplate.values.map((t) => t.kind);
      expect(kinds.where((k) => k == HabitKind.build), hasLength(4));
      expect(kinds.where((k) => k == HabitKind.reduce), hasLength(4));
    });

    test('reduce templates carry a cost and a default expense category', () {
      final expenseKeys = {for (final c in defaultCategories) c.nameKey};
      for (final t in HabitTemplate.values) {
        expect(AppIcons.byKey, contains(t.iconKey), reason: t.name);
        expect(
          AppPresetColor.values.map((c) => c.key),
          contains(t.colorKey),
          reason: t.name,
        );
        if (t.kind == HabitKind.reduce) {
          expect(t.defaultCost, greaterThan(0), reason: t.name);
          expect(expenseKeys, contains(t.categoryNameKey), reason: t.name);
        } else {
          expect(t.defaultCost, isNull, reason: t.name);
        }
      }
    });

    test('drafts keep reduce-only fields off build habits', () {
      final exercise = HabitTemplate.exercise.toDraft(
        name: 'Olahraga',
        cost: 5000,
        walletId: 'w',
        categoryId: 'c',
      );
      expect(exercise.scheduleType, ScheduleType.timesPerWeek);
      expect(exercise.timesPerWeek, 3);
      expect(exercise.costPerOccurrence, isNull);
      expect(exercise.walletId, isNull);

      final coffee = HabitTemplate.cafeCoffee.toDraft(
        name: 'Kopi',
        walletId: 'w',
        categoryId: 'c',
      );
      expect(coffee.costPerOccurrence, 25000, reason: 'default cost');
      expect(coffee.walletId, 'w');
      expect(coffee.weeklyLimit, isNull);
    });

    test('every template has a name and schedule in id and en', () {
      for (final code in ['id', 'en']) {
        final l10n = lookupAppLocalizations(Locale(code));
        for (final t in HabitTemplate.values) {
          expect(templateName(l10n, t), isNotEmpty);
          expect(templateSchedule(l10n, t), isNotEmpty);
        }
      }
      final id = lookupAppLocalizations(const Locale('id'));
      expect(templateName(id, HabitTemplate.cafeCoffee), 'Kopi kekinian');
      expect(templateSchedule(id, HabitTemplate.exercise), '3x seminggu');
    });
  });

  group('OnboardingDraft', () {
    test('survives a save and restore', () {
      final draft = const OnboardingDraft()
          .copyWith(
            step: OnboardingStep.habits,
            name: 'Raka',
            walletName: 'BCA',
            walletType: WalletType.bank,
            initialBalance: 150000,
            costs: {HabitTemplate.cafeCoffee: 30000},
          )
          .toggle(HabitTemplate.read)
          .toggle(HabitTemplate.cafeCoffee);

      final restored = OnboardingDraft.decode(draft.encode());
      expect(restored.step, OnboardingStep.habits);
      expect(restored.name, 'Raka');
      expect(restored.walletName, 'BCA');
      expect(restored.walletType, WalletType.bank);
      expect(restored.initialBalance, 150000);
      expect(restored.selected, [HabitTemplate.read, HabitTemplate.cafeCoffee]);
      expect(restored.costOf(HabitTemplate.cafeCoffee), 30000);
      expect(restored.costOf(HabitTemplate.lateSnacks), 20000);
    });

    test('starts over when the saved draft is unreadable', () {
      for (final json in [null, '', 'not json', '{"step":"gone"}']) {
        final draft = OnboardingDraft.decode(json);
        expect(draft.step, OnboardingStep.language, reason: '$json');
        expect(draft.selected, isEmpty);
      }
    });

    test('allows at most three templates and keeps edited costs', () {
      var draft = const OnboardingDraft();
      for (final t in HabitTemplate.values.take(4)) {
        draft = draft.toggle(t);
      }
      expect(draft.selected, HabitTemplate.values.take(3));
      expect(draft.canPickMore, isFalse);

      draft = draft
          .copyWith(costs: {HabitTemplate.impulseBuys: 75000})
          .toggle(HabitTemplate.exercise)
          .toggle(HabitTemplate.impulseBuys)
          .toggle(HabitTemplate.impulseBuys);
      expect(draft.selected, isNot(contains(HabitTemplate.impulseBuys)));
      expect(draft.costOf(HabitTemplate.impulseBuys), 75000);
    });

    test('steps know their neighbours', () {
      expect(OnboardingStep.language.previous, isNull);
      expect(OnboardingStep.language.next, OnboardingStep.valueGrowth);
      expect(OnboardingStep.habits.next, isNull);
      expect(OnboardingStep.wallet.previous, OnboardingStep.name);
    });
  });
}
