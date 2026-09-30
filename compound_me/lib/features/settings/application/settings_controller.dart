import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/onboarding/application/onboarding_controller.dart';
import 'package:compound_me/features/settings/data/drift_data_reset.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

/// "1.0.0 (1)": version name and build number from the platform.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// Deletes all data and settings, then lets the router send the user back
/// to onboarding, as after a fresh install.
@Riverpod(keepAlive: true)
class DeleteAllData extends _$DeleteAllData {
  @override
  void build() {}

  Future<void> run() async {
    await ref.read(dataResetProvider).deleteEverything();
    await ref.read(appPreferencesProvider).clear();
    ref
      ..invalidate(themeModeSettingProvider)
      ..invalidate(localeSettingProvider)
      ..invalidate(userNameProvider)
      ..invalidate(addCoachMarkSeenProvider)
      ..invalidate(hideBalanceOnLaunchProvider)
      ..invalidate(onboardingControllerProvider);
    // Last: this redirects to onboarding.
    await ref.read(onboardingDoneProvider.notifier).set(done: false);
  }
}
