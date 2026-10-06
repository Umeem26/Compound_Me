import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/onboarding/application/onboarding_status.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_draft.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late DriftWalletRepository wallets;

  setUp(() {
    db = openTestDatabase();
    wallets = DriftWalletRepository(db);
  });

  Future<AppPreferences> prefsWith(Map<String, Object> data) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData(data);
    return await AppPreferences.load();
  }

  final habitsDraft = const OnboardingDraft(
    step: OnboardingStep.habits,
    name: 'Raka',
  ).encode();

  test(
    'a wallet means onboarding finished, even if the flag was lost',
    () async {
      await seedWallet(db);
      final prefs = await prefsWith({
        'onboardingDone': false,
        'onboardingDraft': habitsDraft,
      });

      await syncOnboardingStatus(prefs: prefs, wallets: wallets);

      final reloaded = await AppPreferences.load();
      expect(reloaded.onboardingDone, isTrue);
      expect(reloaded.onboardingDraft, isNull, reason: 'no second onboarding');
    },
  );

  test('an archived wallet counts too', () async {
    final cash = await seedWallet(db);
    final bank = await seedWallet(db, name: 'Bank');
    await wallets.archive(bank);
    // Leave only the archived wallet (the repository keeps one active).
    await (db.delete(db.wallets)..where((w) => w.id.equals(cash))).go();
    final prefs = await prefsWith({'onboardingDone': false});

    await syncOnboardingStatus(prefs: prefs, wallets: wallets);

    expect((await AppPreferences.load()).onboardingDone, isTrue);
  });

  test('no wallet after a finished onboarding completes the reset', () async {
    final prefs = await prefsWith({
      'onboardingDone': true,
      'userName': 'Raka',
      'themeMode': ThemeMode.dark.name,
      'localeCode': 'en',
    });

    await syncOnboardingStatus(prefs: prefs, wallets: wallets);

    final reloaded = await AppPreferences.load();
    expect(reloaded.onboardingDone, isFalse);
    expect(reloaded.userName, isEmpty);
    expect(reloaded.themeMode, ThemeMode.system);
    expect(reloaded.localeCode, isNull);
  });

  test('an unfinished onboarding keeps its draft', () async {
    final prefs = await prefsWith({
      'onboardingDone': false,
      'onboardingDraft': habitsDraft,
      'localeCode': 'id',
    });

    await syncOnboardingStatus(prefs: prefs, wallets: wallets);

    final reloaded = await AppPreferences.load();
    expect(reloaded.onboardingDone, isFalse);
    expect(reloaded.onboardingDraft, habitsDraft);
    expect(reloaded.localeCode, 'id');
  });
}
