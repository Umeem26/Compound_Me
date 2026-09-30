// Phase 2 checklist, run on a device or emulator (06 §1):
//   flutter test integration_test/phase2_checklist_test.dart -d <device>
// The app starts through the real bootstrap, so it uses the device's own
// database and preferences. The tests run in order and each continues
// from the state the previous one left.

import 'package:compound_me/app.dart';
import 'package:compound_me/bootstrap/app_bootstrap.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

/// Taps and screens of the onboarding flow, reported at the end of b.
int _taps = 0;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  _taps++;
}

/// On a device, database writes and the streams that follow them are
/// real async work that can land after pumpAndSettle returns.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
}

Future<void> _tapIfShown(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isNotEmpty) {
    await _tap(tester, find.text(text));
  }
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
}

Future<AppBootstrap> _start(WidgetTester tester) async {
  final bootstrap = await AppBootstrap.load();
  await tester.pumpWidget(
    ProviderScope(overrides: bootstrap.overrides, child: const CompoundMeApp()),
  );
  await tester.pumpAndSettle();
  return bootstrap;
}

/// Unmounts the app so its streams close, then closes its database.
Future<void> _stop(WidgetTester tester, AppBootstrap bootstrap) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await bootstrap.database.close();
}

bool get _onOnboarding =>
    find.text('Pilih bahasa').evaluate().isNotEmpty ||
    find.text('Choose your language').evaluate().isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a. Hapus semua data kembali ke onboarding', (tester) async {
    final app = await _start(tester);
    if (_onOnboarding) {
      // A fresh device: onboard quickly so there is data to delete.
      await _tap(tester, find.text('Bahasa Indonesia'));
      await _tap(tester, find.text('Lanjut'));
      await _tap(tester, find.text('Lewati'));
      await _type(tester, 'Raka');
      await _tap(tester, find.text('Lanjut'));
      await _tap(tester, find.text('Lanjut'));
      await _tap(tester, find.text('Lewati dulu'));
    }
    await _tapIfShown(tester, 'Mengerti');
    expect(await app.database.select(app.database.wallets).get(), isNotEmpty);

    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Pengaturan'));
    await _tap(tester, find.text('Hapus semua data'));
    await _tap(tester, find.text('Lanjutkan'));
    await _type(tester, 'HAPUS');
    await _tap(tester, find.byType(DestructiveButton));

    await _waitFor(
      tester,
      find.textContaining(RegExp('^(Pilih bahasa|Choose your language)')),
    );
    expect(await app.database.select(app.database.wallets).get(), isEmpty);
    expect(await app.database.select(app.database.habits).get(), isEmpty);
    expect(app.preferences.onboardingDone, isFalse);
    await _stop(tester, app);
  });

  testWidgets('b. Onboarding lengkap dengan template Kurangi', (tester) async {
    final app = await _start(tester);
    expect(_onOnboarding, isTrue);
    _taps = 0;
    final screens = <String>['bahasa'];

    await _tap(tester, find.text('Bahasa Indonesia'));
    await _tap(tester, find.text('Lanjut'));
    screens.add('nilai 1');
    await _tap(tester, find.text('Lewati'));
    screens.add('nama');
    await _type(tester, 'Raka');
    await _tap(tester, find.text('Lanjut'));
    screens.add('dompet');
    await _tap(tester, find.bySemanticsLabel('Saldo awal, Rp 0'));
    for (final key in ['2', '5', '000']) {
      await _tap(tester, find.bySemanticsLabel(key));
    }
    await _tap(tester, find.text('Simpan'));
    await _tap(tester, find.text('Lanjut'));
    screens.add('kebiasaan');
    await _tap(tester, find.text('Kopi kekinian'));
    await _tap(
      tester,
      find.bySemanticsLabel('Ubah biaya Kopi kekinian, sekarang Rp 25.000'),
    );
    await tester.longPress(find.bySemanticsLabel('Hapus satu angka'));
    await tester.pumpAndSettle();
    _taps++;
    for (final key in ['3', '0', '000']) {
      await _tap(tester, find.bySemanticsLabel(key));
    }
    await _tap(tester, find.text('Simpan'));
    await _tap(tester, find.text('Mulai'));
    screens.add('beranda');

    await _waitFor(tester, find.text('Belum ada transaksi'));
    final db = app.database;
    final wallet = await db.select(db.wallets).getSingle();
    expect(wallet.name, 'Tunai');
    expect(wallet.initialBalance, 25000);
    final habit = await db.select(db.habits).getSingle();
    expect(habit.name, 'Kopi kekinian');
    expect(habit.kind, HabitKind.reduce);
    expect(habit.costPerOccurrence, 30000);
    expect(habit.walletId, wallet.id);
    final food = await (db.select(
      db.categories,
    )..where((c) => c.nameKey.equals('catFood'))).getSingle();
    expect(habit.categoryId, food.id);
    expect(app.preferences.userName, 'Raka');

    // Picked up by the QA report (tool/qa/README.md).
    debugPrint(
      'QA onboarding: $_taps tap, 1 isian teks, ${screens.length} layar '
      '(${screens.join(' → ')})',
    );
    await _tapIfShown(tester, 'Mengerti');
    await _stop(tester, app);
  });

  testWidgets('c. Ganti ke English', (tester) async {
    final app = await _start(tester);
    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Pengaturan'));
    await _tap(tester, find.text('English'));

    // The large title is drawn twice (large, and small once scrolled).
    expect(find.text('Settings'), findsWidgets);
    for (final text in ['Display', 'Language', 'Theme', 'Data']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    for (final text in ['Home', 'Habits', 'Insights', 'Profile']) {
      expect(find.text(text), findsOneWidget, reason: 'tab $text');
    }
    expect(find.text('Pengaturan'), findsNothing);

    // Phase 2 screens show no dates yet; check the locale data the app
    // formats dates with (bootstrap loads it; v1 crashed without it).
    final context = tester.element(find.text('Display'));
    final code = Localizations.localeOf(context).languageCode;
    expect(code, 'en');
    expect(
      DateFormat('EEEE, d MMMM', code).format(DateTime(2026, 9, 25)),
      'Friday, 25 September',
    );

    await _tap(tester, find.byTooltip('Back'));
    await _tap(tester, find.text('Wallets'));
    expect(find.text('Rp 25.000'), findsWidgets, reason: 'IDR in English');

    // Back to Indonesian for the next checks.
    await _tap(tester, find.byTooltip('Back'));
    await _tap(tester, find.text('Settings'));
    await _tap(tester, find.text('Indonesia'));
    expect(find.text('Pengaturan'), findsWidgets);
    expect(find.text('Settings'), findsNothing);
    await _stop(tester, app);
  });

  testWidgets('d. Buang perubahan di editor dompet', (tester) async {
    final app = await _start(tester);
    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Dompet'));
    await _tap(tester, find.text('Tunai').first);
    await _type(tester, 'Tunai harian');

    await _tap(tester, find.byTooltip('Tutup'));
    expect(find.text('Buang perubahan?'), findsOneWidget);
    await _tap(tester, find.text('Lanjut edit'));
    expect(find.text('Buang perubahan?'), findsNothing);
    expect(find.widgetWithText(TextField, 'Tunai harian'), findsOneWidget);

    await _tap(tester, find.text('Simpan'));
    expect(find.text('Buang perubahan?'), findsNothing);
    await _waitFor(tester, find.text('Tunai harian'));
    final wallet = await app.database.select(app.database.wallets).getSingle();
    expect(wallet.name, 'Tunai harian');
    await _stop(tester, app);
  });

  testWidgets('e. Tambah dompet, Profil langsung 2 aktif', (tester) async {
    final app = await _start(tester);
    await _tap(tester, find.text('Profil'));
    await _waitFor(tester, find.text('1 aktif'));
    await _tap(tester, find.text('Dompet'));
    await _tap(tester, find.text('Tambah dompet'));
    await _type(tester, 'BCA');
    await _tap(tester, find.text('Simpan'));
    await _waitFor(tester, find.text('BCA'));

    await _tap(tester, find.byTooltip('Kembali'));
    await _waitFor(tester, find.text('2 aktif'));
    await _stop(tester, app);
  });
}
