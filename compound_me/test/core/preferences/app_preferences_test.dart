import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('defaults to the system theme and the device language', () async {
    final prefs = await AppPreferences.load();

    expect(prefs.themeMode, ThemeMode.system);
    expect(prefs.localeCode, isNull);
  });

  test('persists theme and language across reloads', () async {
    final prefs = await AppPreferences.load();
    await prefs.setThemeMode(ThemeMode.dark);
    await prefs.setLocaleCode('en');

    final reloaded = await AppPreferences.load();
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.localeCode, 'en');

    await reloaded.setLocaleCode(null);
    expect((await AppPreferences.load()).localeCode, isNull);
  });

  test('ignores an unknown stored theme value', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({'themeMode': 'sepia'});

    expect((await AppPreferences.load()).themeMode, ThemeMode.system);
  });
}
