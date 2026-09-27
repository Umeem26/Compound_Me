import 'package:compound_me/app.dart';
import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Pixel 9 in logical pixels, so layouts are tested at a real phone size.
const pixel9 = Size(1080, 2424);
const pixel9Ratio = 2.625;

/// Builds the full app the way bootstrap does, with in-memory storage.
/// By default onboarding is done and its hint dismissed; [prefs] adds or
/// overrides stored preferences. Returns the in-memory database.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  ThemeMode themeMode = ThemeMode.light,
  String? localeCode = 'id',
  bool onboarded = true,
  Map<String, Object> prefs = const {},
  double textScale = 1,
  Size physicalSize = pixel9,
  double devicePixelRatio = pixel9Ratio,
}) async {
  tester.view
    ..physicalSize = physicalSize
    ..devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  PackageInfo.setMockInitialValues(
    appName: 'CompoundMe',
    packageName: 'com.umem.compound_me',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({
        'themeMode': themeMode.name,
        'localeCode': ?localeCode,
        'onboardingDone': onboarded,
        'addCoachMarkSeen': true,
        if (onboarded) 'userName': 'Raka',
        ...prefs,
      });
  final preferences = await AppPreferences.load();
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        appPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const CompoundMeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return database;
}

/// Navigates the running app, like following a link.
Future<void> goTo(WidgetTester tester, String location) async {
  ProviderScope.containerOf(tester.element(find.byType(CompoundMeApp)))
      .read(appRouterProvider)
      .go(location);
  await tester.pumpAndSettle();
}

/// [testWidgets] for tests that pump the whole app. Drift closes stream
/// queries on a zero-length timer, so the app is unmounted and that timer
/// runs before the test ends instead of failing it as pending.
@isTest
void testApp(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    // A plain pump() doesn't advance fake time, so the timer wouldn't fire.
    await tester.pump(Duration.zero);
  });
}
