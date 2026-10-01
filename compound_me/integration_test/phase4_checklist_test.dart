// Phase 4 checklist, run on a device or emulator (06 §1):
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/phase4_checklist_test.dart -d <device>
// `flutter drive` keeps the app and its data afterwards, so
// tool/qa/qa_phase4.py can take screenshots of what these tests built
// (a habit with a grace day in its history). The tests run in order.

import 'package:compound_me/app.dart';
import 'package:compound_me/bootstrap/app_bootstrap.dart';
import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart'
    show BooleanExpressionOperators, driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

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

Future<AppBootstrap> _start(WidgetTester tester) async {
  final bootstrap = await AppBootstrap.load();
  await tester.pumpWidget(
    ProviderScope(overrides: bootstrap.overrides, child: const CompoundMeApp()),
  );
  await tester.pumpAndSettle();
  return bootstrap;
}

Future<void> _stop(WidgetTester tester, AppBootstrap bootstrap) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await bootstrap.database.close();
}

/// A press held in real time: on a device, tester.longPress doesn't wait
/// long enough and lands as a tap.
Future<void> _longPress(WidgetTester tester, Finder finder) async {
  final gesture = await tester.startGesture(tester.getCenter(finder));
  await Future<void>.delayed(const Duration(milliseconds: 900));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

Finder _labelled(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Balance per wallet name and active check-in expenses, from the
/// database.
Future<Map<String, int>> _balances(AppDatabase db) async => {
  for (final w in await DriftWalletRepository(
    db,
  ).watchActiveWithBalance().first)
    w.wallet.name: w.balance,
};

Future<List<TransactionRow>> _checkInExpenses(AppDatabase db) => (db.select(
  db.transactions,
)..where((t) => t.deletedAt.isNull() & t.habitLogId.isNotNull())).get();

bool get _onOnboarding =>
    find.text('Pilih bahasa').evaluate().isNotEmpty ||
    find.text('Choose your language').evaluate().isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a. Data awal: Tunai Rp 100.000 dan GoPay Rp 200.000', (
    tester,
  ) async {
    var app = await _start(tester);
    if (!_onOnboarding) {
      if (find.text('Mengerti').evaluate().isNotEmpty) {
        await _tap(tester, find.text('Mengerti'));
      }
      await _tap(tester, find.text('Profil'));
      await _tap(tester, find.text('Pengaturan'));
      await _tap(tester, find.text('Hapus semua data'));
      await _tap(tester, find.text('Lanjutkan'));
      await tester.enterText(find.byType(TextField), 'HAPUS');
      await tester.pumpAndSettle();
      await _tap(tester, find.byType(DestructiveButton));
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
    if (find.text('Mengerti').evaluate().isNotEmpty) {
      await _tap(tester, find.text('Mengerti'));
    }
    await _stop(tester, app);

    app = await _start(tester);
    await DriftWalletRepository(app.database).create(
      WalletDraft(
        name: 'GoPay',
        type: WalletType.ewallet,
        iconKey: WalletType.ewallet.defaultIconKey,
        colorKey: 'blue',
        initialBalance: 200000,
      ),
    );
    expect(await _balances(app.database), {'Tunai': 100000, 'GoPay': 200000});
    await _stop(tester, app);
  });

  testWidgets('b. Buat "Kopi Rp 25.000, GoPay, Makanan" → check-in → '
      'transaksi masuk ke GoPay', (tester) async {
    final app = await _start(tester);
    await _tap(tester, find.text('Kebiasaan'));
    await _tap(tester, find.byTooltip('Buat kebiasaan'));
    await _tap(tester, find.text('Kurangi'));
    await tester.enterText(find.byType(TextField), 'Kopi');
    await tester.pumpAndSettle();
    final cost = _labelled('Biaya per kali, Atur biaya');
    await _scrollTo(tester, cost);
    await _tap(tester, cost);
    for (final key in ['2', '5', '000']) {
      await _tap(tester, find.bySemanticsLabel(key));
    }
    await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan').last);
    final wallet = _labelled('Dompet, Tunai');
    await _scrollTo(tester, wallet);
    await _tap(tester, wallet);
    await _tap(tester, find.text('GoPay'));
    final category = _labelled('Kategori, Pilih kategori');
    await _scrollTo(tester, category);
    await _tap(tester, category);
    await _tap(tester, find.text('Makanan & minuman'));
    await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));
    await _waitFor(tester, find.text('Kopi'));

    await _tap(tester, find.text('Beranda'));
    await _tap(tester, find.byType(HabitChip));
    await _waitFor(tester, find.text('Dicatat'));

    final db = app.database;
    final gopay = (await (db.select(
      db.wallets,
    )..where((w) => w.name.equals('GoPay'))).getSingle()).id;
    final expenses = await _checkInExpenses(db);
    expect(expenses, hasLength(1));
    expect(expenses.single.walletId, gopay, reason: 'not the first wallet');
    expect(expenses.single.amount, 25000);
    expect(await _balances(db), {'Tunai': 100000, 'GoPay': 175000});
    await _stop(tester, app);
  });

  testWidgets('c. Long-press → 2 kopi → 2 transaksi; turunkan ke 1 → '
      'tinggal 1', (tester) async {
    final app = await _start(tester);
    final db = app.database;

    await _longPress(tester, find.byType(HabitChip));
    await _tap(tester, find.byTooltip('Tambah satu'));
    await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));
    await _waitFor(tester, find.bySemanticsLabel(RegExp('2 kali hari ini')));
    expect(await _checkInExpenses(db), hasLength(2));
    expect((await _balances(db))['GoPay'], 150000);

    // The second change from the habits tab's check button, which has the
    // same long-press.
    await _tap(tester, find.text('Kebiasaan'));
    await _longPress(
      tester,
      find.byWidgetPredicate(
        (w) => w is CheckButton && w.semanticLabel.startsWith('Kopi'),
      ),
    );
    await _tap(tester, find.byTooltip('Kurangi satu'));
    await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));
    await _waitFor(tester, find.bySemanticsLabel(RegExp('1 kali hari ini')));
    expect(await _checkInExpenses(db), hasLength(1));
    expect((await _balances(db))['GoPay'], 175000);
    await _stop(tester, app);
  });

  testWidgets('d. Bolong satu hari (data uji) → streak tidak putus, '
      'ditandai hari longgar', (tester) async {
    var app = await _start(tester);
    final now = DateTime.now();
    final today = LocalDate.fromDateTime(now);
    // "Baca" started ten days ago, checked in every day but one.
    final started = today.addDays(-10).atLocalHour(9);
    final id = await DriftHabitRepository(app.database, clock: () => started)
        .create(
          const HabitDraft(
            name: 'Baca',
            kind: HabitKind.build,
            iconKey: 'bookOpen',
            colorKey: 'blue',
            scheduleType: ScheduleType.daily,
          ),
        );
    final habits = DriftHabitRepository(app.database);
    final missed = today.addDays(-3);
    for (var back = 10; back >= 1; back--) {
      final day = today.addDays(-back);
      if (day != missed) await habits.setCount(id, day, 1);
    }
    await _stop(tester, app);

    app = await _start(tester);
    await _tap(tester, find.text('Kebiasaan'));
    await _tap(tester, find.text('Baca'));
    expect(_labelled('Streak, 9 hari'), findsOneWidget);
    if (missed.month != today.month) {
      await _tap(tester, find.byTooltip('Bulan sebelumnya'));
    }
    final date = DateFormat('EEEE, d MMMM y', 'id').format(missed.startLocal);
    final grace = _labelled('$date, Hari longgar');
    await _scrollTo(tester, grace);
    expect(grace, findsOneWidget);
    await _stop(tester, app);
  });

  testWidgets('e. Tap cepat 5x di tombol check → log dan transaksi tetap '
      'sama', (tester) async {
    final app = await _start(tester);
    final db = app.database;
    await _tap(tester, find.text('Kebiasaan'));
    final kopi = find.byWidgetPredicate(
      (w) => w is CheckButton && w.semanticLabel.startsWith('Kopi'),
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(kopi, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    final logs = await (db.select(
      db.habitLogs,
    )..where((l) => l.deletedAt.isNull() & l.habitId.isNotNull())).get();
    final kopiId = (await (db.select(
      db.habits,
    )..where((h) => h.name.equals('Kopi'))).getSingle()).id;
    final count = logs
        .where((l) => l.habitId == kopiId)
        .fold<int>(0, (sum, l) => sum + l.count);
    expect(await _checkInExpenses(db), hasLength(count));
    expect(
      (await _balances(db))['GoPay'],
      200000 - 25000 * count,
      reason: 'the balance follows the check-ins',
    );
    expect(tester.widget<CheckButton>(kopi).done, count > 0);
    // Leaves Kopi checked in once for the screenshots after this run.
    if (count == 0) await _tap(tester, kopi);
    await _stop(tester, app);
  });
}
