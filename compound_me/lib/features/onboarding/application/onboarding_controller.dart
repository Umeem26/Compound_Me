import 'dart:async';

import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/onboarding/data/drift_onboarding_setup.dart';
import 'package:compound_me/features/onboarding/domain/habit_templates.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_draft.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_setup.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Names are entered once and shown in greetings (Flow A: 1–24 chars).
const onboardingNameMaxLength = 24;

/// Holds Flow A's progress and saves it after every change.
@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingDraft build() =>
      OnboardingDraft.decode(ref.watch(appPreferencesProvider).onboardingDraft);

  void _update(OnboardingDraft draft) {
    state = draft;
    unawaited(
      ref.read(appPreferencesProvider).setOnboardingDraft(draft.encode()),
    );
  }

  void goTo(OnboardingStep step) => _update(state.copyWith(step: step));

  void next() {
    final next = state.step.next;
    if (next != null) goTo(next);
  }

  /// Returns false on the first step, where back leaves the app.
  bool back() {
    final previous = state.step.previous;
    if (previous == null) return false;
    goTo(previous);
    return true;
  }

  void setName(String name) => _update(state.copyWith(name: name));

  void setWalletName(String name) => _update(state.copyWith(walletName: name));

  void setWalletType(WalletType type) =>
      _update(state.copyWith(walletType: type));

  void setInitialBalance(Money amount) =>
      _update(state.copyWith(initialBalance: amount));

  void toggleTemplate(HabitTemplate template) =>
      _update(state.toggle(template));

  void setTemplateCost(HabitTemplate template, Money cost) =>
      _update(state.copyWith(costs: {...state.costs, template: cost}));

  /// Saves the wallet and habits, then marks onboarding as done, which
  /// sends the router to Home. [defaultWalletName] and [templateName] come
  /// from the language chosen during onboarding.
  ///
  /// The name is saved first: once the database transaction commits,
  /// bootstrap treats onboarding as finished even if the app dies before
  /// the steps after it, so nothing it needs may come later.
  Future<void> finish({
    required String defaultWalletName,
    required String Function(HabitTemplate template) templateName,
  }) async {
    final draft = state;
    final walletName = draft.walletName?.trim();
    await ref.read(userNameProvider.notifier).set(draft.name.trim());
    await ref
        .read(onboardingSetupProvider)
        .complete(
          wallet: WalletDraft(
            name: walletName == null || walletName.isEmpty
                ? defaultWalletName
                : walletName,
            type: draft.walletType,
            iconKey: draft.walletType.defaultIconKey,
            colorKey: 'teal',
            initialBalance: draft.initialBalance,
          ),
          habits: [
            for (final template in draft.selected)
              StarterHabit(
                template: template,
                name: templateName(template),
                cost: template.kind == HabitKind.reduce
                    ? draft.costOf(template)
                    : null,
              ),
          ],
        );
    await ref.read(appPreferencesProvider).setOnboardingDraft(null);
    await ref.read(onboardingDoneProvider.notifier).set(done: true);
  }
}
