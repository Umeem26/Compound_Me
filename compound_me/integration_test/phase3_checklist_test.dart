// Phase 3 checklist, run on a device or emulator (06 §1):
//   flutter test integration_test/phase3_checklist_test.dart -d <device>
// The app starts through the real bootstrap, so it uses the device's own
// database and preferences. The tests run in order and each continues
// from the state the previous one left.

import 'package:compound_me/app.dart';
import 'package:compound_me/bootstrap/app_bootstrap.dart';
import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
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

/// [clock] replaces the app's clock, e.g. one that runs from 23:59:57 so
/// the real midnight timer fires within seconds.
Future<AppBootstrap> _start(
  WidgetTester tester, {
  DateTime Function()? clock,
}) async {
  final bootstrap = await AppBootstrap.load();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...bootstrap.overrides,
        if (clock != null) clockProvider.overrideWithValue(clock),
      ],
      child: const CompoundMeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return bootstrap;
}

/// A clock that starts at [start] and then runs with real time.
DateTime Function() _runningFrom(DateTime start) {
  final elapsed = Stopwatch()..start();
  return () => start.add(elapsed.elapsed);
}

/// Pumps real time on the device, so real timers get to fire.
Future<void> _wait(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _monthName(int month) => const [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
][month - 1];

/// Unmounts the app so its streams close, then closes its database. The
/// next [_start] reads everything again, like opening the app anew.
Future<void> _stop(WidgetTester tester, AppBootstrap bootstrap) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await bootstrap.database.close();
}

Finder _key(String label) =>
    find.descendant(of: find.byType(AmountKeypad), matching: find.text(label));

Finder _balance(String text) =>
    find.descendant(of: find.byType(BalanceHeader), matching: find.text(text));

/// Balance per wallet name, straight from the database.
Future<Map<String, int>> _balances(AppDatabase db) async => {
  for (final w in await DriftWalletRepository(
    db,
  ).watchActiveWithBalance().first)
    w.wallet.name: w.balance,
};

bool get _onOnboarding =>
    find.text('Pilih bahasa').evaluate().isNotEmpty ||
    find.text('Choose your language').evaluate().isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a. Data awal: Tunai Rp 100.000, Bank Rp 200.000, satu '
      'pengeluaran Makanan kemarin', (tester) async {
    var app = await _start(tester);
    if (!_onOnboarding) {
      // Start from a clean install, the way a new user would.
      await _tapIfShown(tester, 'Mengerti');
      await _tap(tester, find.text('Profil'));
      await _tap(tester, find.text('Pengaturan'));
      await _tap(tester, find.text('Hapus semua data'));
      await _tap(tester, find.text('Lanjutkan'));
      await tester.enterText(find.byType(TextField), 'HAPUS');
      await tester.pumpAndSettle();
      await _tap(tester, find.byType(DestructiveButton));
      // Language follows the device again after deleting everything.
      await _waitFor(
        tester,
        find.textContaining(RegExp('^(Pilih bahasa|Choose your language)')),
      );
    }
    await _tap(tester, find.text('Bahasa Indonesia'));
    await _tap(tester, find.text('Lanjut'));
    await _tap(tester, find.text('Lewati'));
    await tester.enterText(find.byType(TextField), 'Raka');
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Lanjut'));
    await _tap(tester, find.bySemanticsLabel('Saldo awal, Rp 0'));
    for (final key in ['1', '0', '0', '000']) {
      await _tap(tester, find.bySemanticsLabel(key));
    }
    await _tap(tester, find.text('Simpan'));
    await _tap(tester, find.text('Lanjut'));
    await _tap(tester, find.text('Lewati dulu'));
    await _tapIfShown(tester, 'Mengerti');
    await _waitFor(tester, find.text('Belum ada transaksi'));
    await _stop(tester, app);

    // A second wallet and yesterday's lunch, so "last category" exists.
    app = await _start(tester);
    final db = app.database;
    final cash = (await db.select(db.wallets).getSingle()).id;
    await DriftWalletRepository(db).create(
      WalletDraft(
        name: 'Bank',
        type: WalletType.bank,
        iconKey: WalletType.bank.defaultIconKey,
        colorKey: 'blue',
        initialBalance: 200000,
      ),
    );
    final food = await (db.select(
      db.categories,
    )..where((c) => c.nameKey.equals('catFood'))).getSingle();
    await DriftTransactionRepository(db).add(
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: 15000,
        walletId: cash,
        categoryId: food.id,
        occurredAt: DateTime.now().subtract(const Duration(days: 1)),
        note: 'nasi padang',
      ),
    );
    await _waitFor(tester, _balance('Rp 285.000'));
    await _stop(tester, app);
  });

  testWidgets('b. Catat "kopi Rp 22.000" (Flow B), hitung tap', (tester) async {
    final app = await _start(tester);
    var taps = 0;
    Future<void> tap(Finder finder) async {
      await _tap(tester, finder);
      taps++;
    }

    final clock = Stopwatch()..start();
    await tap(find.byTooltip('Tambah transaksi'));
    // The last category used for expenses is already chosen.
    final chip = tester.widget<AppChip>(
      find.widgetWithText(AppChip, 'Makanan & minuman'),
    );
    expect(chip.selected, isTrue);
    for (final key in ['2', '2', '000']) {
      await tap(_key(key));
    }
    await tap(find.widgetWithText(PrimaryButton, 'Simpan'));
    await _waitFor(tester, _balance('Rp 263.000'));
    clock.stop();

    expect(find.text('Tersimpan'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(await _balances(app.database), {'Tunai': 63000, 'Bank': 200000});
    expect(taps, 5);
    // Picked up by the QA report (tool/qa/README.md).
    debugPrint(
      'QA Flow B: $taps tap (Tambah, 2, 2, 000, Simpan) dengan kategori '
      'terakhir terpilih, ${clock.elapsedMilliseconds} ms otomatis',
    );
    await _stop(tester, app);
  });

  testWidgets('c. Hapus transaksi → Urungkan → kembali utuh, saldo benar', (
    tester,
  ) async {
    final app = await _start(tester);
    final db = app.database;

    await _tap(tester, find.text('−Rp 22.000').last);
    await _tap(tester, find.byTooltip('Hapus'));
    await _waitFor(tester, _balance('Rp 285.000'));
    expect(find.text('Transaksi dihapus'), findsOneWidget);
    expect(await _balances(db), {'Tunai': 85000, 'Bank': 200000});

    await _tap(tester, find.text('Urungkan'));
    await _waitFor(tester, _balance('Rp 263.000'));
    expect(await _balances(db), {'Tunai': 63000, 'Bank': 200000});
    final coffee = await (db.select(
      db.transactions,
    )..where((t) => t.amount.equals(22000))).getSingle();
    expect(coffee.deletedAt, isNull);
    await _stop(tester, app);
  });

  testWidgets('d. Edit transaksi pindah dompet → saldo kedua dompet benar', (
    tester,
  ) async {
    final app = await _start(tester);

    await _tap(tester, find.text('−Rp 22.000').last);
    await _tap(tester, find.text('Edit'));
    await _tap(tester, find.bySemanticsLabel('Dompet, Tunai'));
    await _tap(tester, find.text('Bank'));
    await _tap(tester, find.text('Simpan perubahan'));
    await _waitFor(tester, find.text('Tersimpan'));

    expect(await _balances(app.database), {'Tunai': 85000, 'Bank': 178000});
    expect(_balance('Rp 263.000'), findsOneWidget, reason: 'total unchanged');
    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Dompet'));
    expect(find.text('Rp 85.000'), findsOneWidget);
    expect(find.text('Rp 178.000'), findsOneWidget);
    await _stop(tester, app);
  });

  testWidgets('e. Sembunyikan saldo saat app dibuka; mata membukanya', (
    tester,
  ) async {
    var app = await _start(tester);
    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Pengaturan'));
    await _tap(tester, find.text('Sembunyikan saldo'));
    expect(app.preferences.hideBalanceOnLaunch, isTrue);
    await _stop(tester, app);

    app = await _start(tester);
    expect(_balance('Rp ••••••'), findsOneWidget, reason: 'hidden at launch');
    expect(find.text('Rp 263.000'), findsNothing);
    await _tap(tester, find.byTooltip('Tampilkan saldo'));
    expect(_balance('Rp 263.000'), findsOneWidget);
    expect(app.preferences.hideBalanceOnLaunch, isTrue, reason: 'eye only');
    await _stop(tester, app);

    app = await _start(tester);
    expect(_balance('Rp ••••••'), findsOneWidget, reason: 'next launch');
    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Pengaturan'));
    await _tap(tester, find.text('Sembunyikan saldo'));
    expect(app.preferences.hideBalanceOnLaunch, isFalse);
    await _stop(tester, app);

    app = await _start(tester);
    expect(_balance('Rp 263.000'), findsOneWidget, reason: 'setting off');
    await _stop(tester, app);
  });

  testWidgets('f. Riwayat: bulan filter tegas, "Lihat" bulan sebelumnya, '
      'pencarian semua bulan', (tester) async {
    var app = await _start(tester);
    final db = app.database;
    final now = DateTime.now();
    final previous = DateTime(now.year, now.month - 1, 10, 12);
    final cash = (await (db.select(
      db.wallets,
    )..where((w) => w.name.equals('Tunai'))).getSingle()).id;
    final transport = await (db.select(
      db.categories,
    )..where((c) => c.nameKey.equals('catTransport'))).getSingle();
    await DriftTransactionRepository(db).add(
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: 45000,
        walletId: cash,
        categoryId: transport.id,
        occurredAt: previous,
        note: 'parkir bulan lalu',
      ),
    );
    await _stop(tester, app);

    app = await _start(tester);
    await _tap(tester, find.text('Lihat semua'));
    final thisMonth = '${_monthName(now.month)} ${now.year}';
    final lastMonth = '${_monthName(previous.month)} ${previous.year}';
    expect(find.widgetWithText(AppChip, thisMonth), findsOneWidget);
    expect(find.text('−Rp 45.000'), findsNothing, reason: 'strict month');
    expect(find.text('−Rp 22.000'), findsWidgets);

    await _tap(tester, find.text('Lihat $lastMonth'));
    expect(find.widgetWithText(AppChip, lastMonth), findsOneWidget);
    await _waitFor(tester, find.text('−Rp 45.000'));
    expect(find.text('−Rp 22.000'), findsNothing);

    await tester.enterText(find.byType(TextField), 'parkir');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppChip, 'Semua bulan'), findsOneWidget);
    expect(find.text('Hasil pencarian'), findsOneWidget);
    await _waitFor(tester, find.bySemanticsLabel('Keluar, Rp 45.000'));
    await _stop(tester, app);
  });

  testWidgets('g. Lewat tengah malam akhir bulan: label dan bulan default '
      'ikut berganti (timer nyata, jam dipercepat)', (tester) async {
    final now = DateTime.now();
    // The last day of this month, three seconds before midnight.
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final start = DateTime(
      lastDay.year,
      lastDay.month,
      lastDay.day,
      23,
      59,
      57,
    );
    var app = await _start(tester);
    final db = app.database;
    final cash = (await (db.select(
      db.wallets,
    )..where((w) => w.name.equals('Tunai'))).getSingle()).id;
    final food = await (db.select(
      db.categories,
    )..where((c) => c.nameKey.equals('catFood'))).getSingle();
    await DriftTransactionRepository(db).add(
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: 11000,
        walletId: cash,
        categoryId: food.id,
        occurredAt: DateTime(start.year, start.month, start.day, 12),
        note: 'uji tengah malam',
      ),
    );
    await _stop(tester, app);

    app = await _start(tester, clock: _runningFrom(start));
    expect(find.text('Hari ini'), findsOneWidget);
    expect(find.text(_monthName(start.month)), findsOneWidget);

    await _wait(tester, const Duration(seconds: 5));
    await tester.pumpAndSettle();
    final next = DateTime(start.year, start.month + 1);
    expect(find.text('Kemarin'), findsOneWidget);
    expect(find.text('Hari ini'), findsNothing);
    expect(find.text(_monthName(next.month)), findsOneWidget);
    expect(find.bySemanticsLabel('Keluar, Rp 0'), findsOneWidget);
    await _stop(tester, app);
  });

  testWidgets('h. App kembali ke depan setelah semalam: sapaan dan label '
      'mengejar jam', (tester) async {
    final now = DateTime.now();
    var fake = DateTime(now.year, now.month, now.day, 21);
    final app = await _start(tester, clock: () => fake);
    expect(find.text('Selamat malam, Raka'), findsOneWidget);

    fake = fake.add(const Duration(hours: 11));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Selamat pagi, Raka'), findsOneWidget);
    await _stop(tester, app);
  });
}
