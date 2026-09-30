import 'dart:convert';

import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit_templates.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:meta/meta.dart';

/// Steps of Flow A in order.
enum OnboardingStep {
  language,
  valueGrowth,
  valueSpeed,
  valuePrivacy,
  name,
  wallet,
  habits;

  OnboardingStep? get previous => index == 0 ? null : values[index - 1];
  OnboardingStep? get next =>
      index == values.length - 1 ? null : values[index + 1];
}

/// Everything entered during onboarding, saved after every change so an
/// interrupted onboarding resumes where it stopped (PRD US-02.1).
@immutable
class OnboardingDraft {
  const OnboardingDraft({
    this.step = OnboardingStep.language,
    this.name = '',
    this.walletName,
    this.walletType = WalletType.cash,
    this.initialBalance = 0,
    this.selected = const [],
    this.costs = const {},
  });

  /// Restores a saved draft. Anything unreadable starts over instead of
  /// blocking the app.
  factory OnboardingDraft.decode(String? json) {
    if (json == null) return const OnboardingDraft();
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      return OnboardingDraft(
        step: OnboardingStep.values.byName(map['step']! as String),
        name: map['name'] as String? ?? '',
        walletName: map['walletName'] as String?,
        walletType: WalletType.values.byName(map['walletType']! as String),
        initialBalance: map['initialBalance'] as int? ?? 0,
        selected: [
          for (final name in map['selected'] as List<Object?>? ?? const [])
            HabitTemplate.values.byName(name! as String),
        ],
        costs: {
          for (final MapEntry(:key, :value)
              in (map['costs'] as Map<String, Object?>? ?? const {}).entries)
            HabitTemplate.values.byName(key): value! as int,
        },
      );
    } on Object {
      return const OnboardingDraft();
    }
  }

  static const maxTemplates = 3;

  final OnboardingStep step;
  final String name;

  /// Null until edited, so the default follows the chosen language.
  final String? walletName;
  final WalletType walletType;
  final Money initialBalance;

  /// Picked templates in the order they were picked.
  final List<HabitTemplate> selected;

  /// Edited costs; a template without one uses its default cost. Kept when
  /// a template is unpicked so picking it again keeps the edit.
  final Map<HabitTemplate, Money> costs;

  bool get canPickMore => selected.length < maxTemplates;

  Money? costOf(HabitTemplate template) =>
      costs[template] ?? template.defaultCost;

  OnboardingDraft copyWith({
    OnboardingStep? step,
    String? name,
    String? walletName,
    WalletType? walletType,
    Money? initialBalance,
    List<HabitTemplate>? selected,
    Map<HabitTemplate, Money>? costs,
  }) => OnboardingDraft(
    step: step ?? this.step,
    name: name ?? this.name,
    walletName: walletName ?? this.walletName,
    walletType: walletType ?? this.walletType,
    initialBalance: initialBalance ?? this.initialBalance,
    selected: selected ?? this.selected,
    costs: costs ?? this.costs,
  );

  /// Picks or unpicks [template]; picking past [maxTemplates] is ignored.
  OnboardingDraft toggle(HabitTemplate template) {
    if (selected.contains(template)) {
      return copyWith(selected: [...selected]..remove(template));
    }
    if (!canPickMore) return this;
    return copyWith(selected: [...selected, template]);
  }

  String encode() => jsonEncode({
    'step': step.name,
    'name': name,
    'walletName': walletName,
    'walletType': walletType.name,
    'initialBalance': initialBalance,
    'selected': [for (final t in selected) t.name],
    'costs': {
      for (final MapEntry(:key, :value) in costs.entries) key.name: value,
    },
  });
}
