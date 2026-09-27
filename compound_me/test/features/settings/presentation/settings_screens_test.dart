import 'package:compound_me/bootstrap/licenses.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openProfile(WidgetTester tester) =>
    _tap(tester, find.text('Profil'));

void main() {
  group('Profile (S-40)', () {
    testApp('shows the name, active wallets and every destination', (
      tester,
    ) async {
      await pumpApp(
        tester,
        seed: (db) async {
          await seedWallet(db);
          await seedWallet(db, name: 'Bank');
        },
      );
      await _openProfile(tester);

      expect(find.text('Raka'), findsOneWidget);
      expect(find.text('R'), findsOneWidget, reason: 'avatar initial');
      expect(find.text('2 aktif'), findsOneWidget);

      await _tap(tester, find.text('Dompet'));
      expect(find.text('Tambah dompet'), findsOneWidget);
      await _tap(tester, find.byTooltip('Kembali'));
      await _tap(tester, find.text('Kategori'));
      expect(find.text('Tambah kategori'), findsOneWidget);
      await _tap(tester, find.byTooltip('Kembali'));
      await _tap(tester, find.text('Pengaturan'));
      expect(find.text('Tampilan'), findsOneWidget);
      // App details live on the About screen only (review PR #6).
      expect(find.text('Dibuat oleh Hisyam Khaeru Umam'), findsNothing);
      expect(find.text('Lisensi open source'), findsNothing);
      await _tap(tester, find.byTooltip('Kembali'));
      await _tap(tester, find.text('Tentang CompoundMe'));
      expect(find.text('Dibuat oleh Hisyam Khaeru Umam'), findsOneWidget);
      expect(find.text('1.0.0 (1)'), findsOneWidget, reason: 'version once');
    });

    testApp('the name can be changed but not emptied', (tester) async {
      await pumpApp(tester);
      await _openProfile(tester);

      await _tap(tester, find.bySemanticsLabel('Ubah nama, Raka'));
      await tester.enterText(find.byType(TextField), '  ');
      await _tap(tester, find.text('Simpan'));
      expect(find.text('Nama belum diisi.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Sari');
      await _tap(tester, find.text('Simpan'));
      expect(find.text('Sari'), findsOneWidget);
      expect((await AppPreferences.load()).userName, 'Sari');
    });
  });

  group('Settings (S-43)', () {
    testApp('language and theme apply at once and are remembered', (
      tester,
    ) async {
      await pumpApp(tester);
      await goTo(tester, AppRoutes.settings);

      await _tap(tester, find.text('English'));
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('Tampilan'), findsNothing);

      await _tap(tester, find.text('Dark'));
      expect(
        Theme.of(tester.element(find.text('Display'))).brightness,
        Brightness.dark,
      );

      await _tap(tester, find.text('Hide balance when opening the app'));
      final prefs = await AppPreferences.load();
      expect(prefs.localeCode, 'en');
      expect(prefs.themeMode, ThemeMode.dark);
      expect(prefs.hideBalanceOnLaunch, isTrue);
    });

    testApp('deleting all data needs two steps and the typed word', (
      tester,
    ) async {
      final db = await pumpApp(tester);
      await goTo(tester, AppRoutes.settings);

      await _tap(tester, find.text('Hapus semua data'));
      expect(find.text('Hapus semua data?'), findsOneWidget);
      await _tap(tester, find.text('Lanjutkan'));

      final confirm = find.byType(DestructiveButton);
      await tester.enterText(find.byType(TextField), 'hapu');
      await tester.pump();
      await _tap(tester, confirm);
      expect(find.text('Hapus semua data?'), findsOneWidget, reason: 'locked');

      await tester.enterText(find.byType(TextField), 'hapus');
      await tester.pump();
      await _tap(tester, confirm);

      // Back to a fresh start: onboarding in the device language.
      expect(find.text('Choose your language'), findsOneWidget);
      expect(await db.select(db.wallets).get(), isEmpty);
      expect(await db.select(db.categories).get(), hasLength(12));
      final prefs = await AppPreferences.load();
      expect(prefs.onboardingDone, isFalse);
      expect(prefs.userName, isEmpty);
      expect(prefs.localeCode, isNull);
    });
  });

  testApp('the licenses page lists the bundled font licenses', (tester) async {
    registerBundledLicenses();
    await pumpApp(tester);
    await goTo(tester, AppRoutes.about);

    await _tap(tester, find.text('Lisensi open source'));
    // Licenses are collected with real async work (asset loading).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plus Jakarta Sans'), findsOneWidget);
    expect(find.text('Phosphor Icons'), findsOneWidget);
  });
}
