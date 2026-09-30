import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_preferences.g.dart';

/// Small key-value settings kept outside SQLite (05 §1).
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _themeModeKey = 'themeMode';
  static const _localeKey = 'localeCode';
  static const _onboardingDoneKey = 'onboardingDone';
  static const _onboardingDraftKey = 'onboardingDraft';
  static const _userNameKey = 'userName';
  static const _addCoachMarkSeenKey = 'addCoachMarkSeen';
  static const _hideBalanceKey = 'hideBalanceOnLaunch';

  static Future<AppPreferences> load() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {
          _themeModeKey,
          _localeKey,
          _onboardingDoneKey,
          _onboardingDraftKey,
          _userNameKey,
          _addCoachMarkSeenKey,
          _hideBalanceKey,
        },
      ),
    );
    return AppPreferences(prefs);
  }

  ThemeMode get themeMode =>
      ThemeMode.values.asNameMap()[_prefs.getString(_themeModeKey)] ??
      ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  /// Null means "follow the device language".
  String? get localeCode => _prefs.getString(_localeKey);

  Future<void> setLocaleCode(String? code) => code == null
      ? _prefs.remove(_localeKey)
      : _prefs.setString(_localeKey, code);

  bool get onboardingDone => _prefs.getBool(_onboardingDoneKey) ?? false;

  Future<void> setOnboardingDone({required bool done}) =>
      _prefs.setBool(_onboardingDoneKey, done);

  /// Onboarding progress as JSON, so an interrupted onboarding resumes at
  /// its last step (PRD US-02.1). Null once onboarding is done.
  String? get onboardingDraft => _prefs.getString(_onboardingDraftKey);

  Future<void> setOnboardingDraft(String? json) => json == null
      ? _prefs.remove(_onboardingDraftKey)
      : _prefs.setString(_onboardingDraftKey, json);

  String get userName => _prefs.getString(_userNameKey) ?? '';

  Future<void> setUserName(String name) => _prefs.setString(_userNameKey, name);

  bool get addCoachMarkSeen => _prefs.getBool(_addCoachMarkSeenKey) ?? false;

  Future<void> setAddCoachMarkSeen() =>
      _prefs.setBool(_addCoachMarkSeenKey, true);

  /// S-43: start with the Home balance hidden (used by BalanceHeader).
  bool get hideBalanceOnLaunch => _prefs.getBool(_hideBalanceKey) ?? false;

  Future<void> setHideBalanceOnLaunch({required bool hide}) =>
      _prefs.setBool(_hideBalanceKey, hide);

  /// Forgets every setting, as after a fresh install ("Hapus semua data").
  Future<void> clear() => _prefs.clear();
}

@Riverpod(keepAlive: true)
AppPreferences appPreferences(Ref ref) =>
    throw UnimplementedError('appPreferencesProvider must be overridden');

/// Read at bootstrap so the chosen theme applies before the first frame.
@Riverpod(keepAlive: true)
class ThemeModeSetting extends _$ThemeModeSetting {
  @override
  ThemeMode build() => ref.watch(appPreferencesProvider).themeMode;

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(appPreferencesProvider).setThemeMode(mode);
  }
}

@Riverpod(keepAlive: true)
class LocaleSetting extends _$LocaleSetting {
  @override
  Locale? build() {
    final code = ref.watch(appPreferencesProvider).localeCode;
    return code == null ? null : Locale(code);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    await ref.read(appPreferencesProvider).setLocaleCode(locale?.languageCode);
  }
}

/// Whether onboarding finished. The router sends everyone else to it.
@Riverpod(keepAlive: true)
class OnboardingDone extends _$OnboardingDone {
  @override
  bool build() => ref.watch(appPreferencesProvider).onboardingDone;

  Future<void> set({required bool done}) async {
    await ref.read(appPreferencesProvider).setOnboardingDone(done: done);
    state = done;
  }
}

/// The name used to greet the user (onboarding, S-40).
@Riverpod(keepAlive: true)
class UserName extends _$UserName {
  @override
  String build() => ref.watch(appPreferencesProvider).userName;

  Future<void> set(String name) async {
    state = name;
    await ref.read(appPreferencesProvider).setUserName(name);
  }
}

/// Flow A ends with a one-time hint on the add button.
@Riverpod(keepAlive: true)
class AddCoachMarkSeen extends _$AddCoachMarkSeen {
  @override
  bool build() => ref.watch(appPreferencesProvider).addCoachMarkSeen;

  Future<void> markSeen() async {
    state = true;
    await ref.read(appPreferencesProvider).setAddCoachMarkSeen();
  }
}

@Riverpod(keepAlive: true)
class HideBalanceOnLaunch extends _$HideBalanceOnLaunch {
  @override
  bool build() => ref.watch(appPreferencesProvider).hideBalanceOnLaunch;

  Future<void> set({required bool hide}) async {
    state = hide;
    await ref.read(appPreferencesProvider).setHideBalanceOnLaunch(hide: hide);
  }
}
