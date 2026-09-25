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

  static Future<AppPreferences> load() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {_themeModeKey, _localeKey},
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
