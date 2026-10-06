import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/wallets/domain/wallet_repository.dart';

/// Makes the cached onboarding flag agree with the database, which is the
/// source of truth: onboarding always creates a wallet, and "delete all
/// data" always removes every wallet. Runs at bootstrap, behind the splash,
/// so an app killed between the database write and the preference write
/// never reopens in the wrong place.
Future<void> syncOnboardingStatus({
  required AppPreferences prefs,
  required WalletRepository wallets,
}) async {
  if (await wallets.hasAny()) {
    // Finished, even if the flag write was lost: never offer onboarding
    // (and its wallet and habits) a second time.
    if (!prefs.onboardingDone) await prefs.setOnboardingDone(done: true);
    if (prefs.onboardingDraft != null) await prefs.setOnboardingDraft(null);
  } else if (prefs.onboardingDone) {
    // "Delete all data" emptied the database but was stopped before it
    // cleared the preferences: finish that reset.
    await prefs.clear();
  }
}
