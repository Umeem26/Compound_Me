import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/onboarding/application/onboarding_controller.dart';
import 'package:compound_me/features/onboarding/data/drift_onboarding_setup.dart';
import 'package:compound_me/features/onboarding/domain/habit_templates.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_draft.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_setup.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Records what onboarding saves, or fails like a full disk.
class _FakeSetup implements OnboardingSetup {
  _FakeSetup({this.fail = false});

  final bool fail;
  WalletDraft? wallet;
  List<StarterHabit>? habits;

  @override
  Future<String> complete({
    required WalletDraft wallet,
    required List<StarterHabit> habits,
  }) async {
    if (fail) throw StateError('disk full');
    this.wallet = wallet;
    this.habits = habits;
    return 'w';
  }
}

void main() {
  late _FakeSetup setup;

  Future<ProviderContainer> start({bool fail = false}) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'onboardingDraft': const OnboardingDraft(
            step: OnboardingStep.habits,
            name: ' Raka ',
            selected: [HabitTemplate.cafeCoffee],
          ).encode(),
        });
    final prefs = await AppPreferences.load();
    setup = _FakeSetup(fail: fail);
    final container = ProviderContainer(
      overrides: [
        appPreferencesProvider.overrideWithValue(prefs),
        onboardingSetupProvider.overrideWithValue(setup),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> finish(ProviderContainer container) => container
      .read(onboardingControllerProvider.notifier)
      .finish(
        defaultWalletName: 'Tunai',
        templateName: (template) => template.name,
      );

  test('the name is saved before the database write', () async {
    final container = await start(fail: true);

    await expectLater(finish(container), throwsStateError);

    final prefs = await AppPreferences.load();
    expect(prefs.userName, 'Raka');
    expect(prefs.onboardingDone, isFalse, reason: 'nothing was created');
    expect(prefs.onboardingDraft, isNotNull, reason: 'can be retried');
  });

  test('a finished onboarding saves everything and clears the draft', () async {
    final container = await start();

    await finish(container);

    expect(setup.wallet!.name, 'Tunai');
    expect(setup.habits!.single.cost, 25000);
    final prefs = await AppPreferences.load();
    expect(prefs.userName, 'Raka');
    expect(prefs.onboardingDone, isTrue);
    expect(prefs.onboardingDraft, isNull);
  });
}
