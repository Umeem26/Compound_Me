// Phase 5 checklist, run on a device or emulator (06 §1):
//   flutter drive --keep-app-running \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/phase5_checklist_test.dart -d <device>
// `flutter drive` keeps the app and its data afterwards, so
// tool/qa/qa_phase5.py can take screenshots of the 60 days of sample data
// these tests fill in. The tests run in order. The expected numbers are
// worked out here from the database rows and the sample data's own
// pattern, never from the Insights code.

import 'package:compound_me/app.dart';
import 'package:compound_me/bootstrap/app_bootstrap.dart';
import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
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

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

String _rupiah(int value) => formatRupiah(value);

bool get _onOnboarding =>
    find.text('Pilih bahasa').evaluate().isNotEmpty ||
    find.text('Choose your language').evaluate().isNotEmpty;

/// What the database says about one month's spending, in local time.
class _Month {
  _Month(this.year, this.month);

  final int year;
  final int month;

  bool contains(DateTime utc) {
    final local = utc.toLocal();
    return local.year == year && local.month == month;
  }

  String get label => DateFormat('MMMM y', 'id').format(DateTime(year, month));
}

Future<({int total, int reduce, int coffee})> _spending(
  AppDatabase db,
  _Month month,
) async {
  final rows = await (db.select(
    db.transactions,
  )..where((t) => t.deletedAt.isNull())).get();
  final logs = await db.select(db.habitLogs).get();
  final habits = await db.select(db.habits).get();
  final kopi = habits.firstWhere((h) => h.name == 'Kopi').id;
  final reduceHabits = {
    for (final h in habits)
      if (h.kind.name == 'reduce') h.id,
  };
  final habitOfLog = {for (final l in logs) l.id: l.habitId};
  var total = 0;
  var reduce = 0;
  var coffee = 0;
  for (final t in rows) {
    if (t.kind != TransactionKind.expense || !month.contains(t.occurredAt)) {
      continue;
    }
    total += t.amount;
    final habit = habitOfLog[t.habitLogId];
    if (habit != null && reduceHabits.contains(habit)) reduce += t.amount;
    if (habit == kopi) coffee += t.amount;
  }
  return (total: total, reduce: reduce, coffee: coffee);
}

/// Coffee on Monday, Wednesday and Friday of the sample data's 60 days,
/// Rp 25.000 each, counted from the calendar.
int _coffeePattern(_Month month, LocalDate today) {
  final windowStart = today.addDays(-59);
  var days = 0;
  for (var day = windowStart; !day.isAfter(today); day = day.addDays(1)) {
    if (day.year == month.year &&
        day.month == month.month &&
        const {1, 3, 5}.contains(day.weekday)) {
      days++;
    }
  }
  return days * 25000;
}

Future<void> _expectMonthNumbers(
  WidgetTester tester,
  AppDatabase db,
  _Month month,
  LocalDate today,
) async {
  final spending = await _spending(db, month);
  expect(
    spending.coffee,
    _coffeePattern(month, today),
    reason: 'the database holds what the sample pattern says',
  );
  expect(find.text(_rupiah(spending.coffee)), findsWidgets);
  if (spending.total > 0) {
    final percent = (spending.reduce / spending.total * 100).round();
    expect(find.text('$percent%'), findsWidgets);
    expect(
      find.textContaining('kamu kurangi · ${_rupiah(spending.reduce)}'),
      findsOneWidget,
    );
  } else {
    expect(find.textContaining('Belum ada pengeluaran'), findsWidgets);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('a. Data bersih, lalu belum 7 hari: progres 0 dan 3 dari 7', (
    tester,
  ) async {
    final app = await _start(tester);
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

    await _tap(tester, find.text('Wawasan'));
    expect(find.text('Wawasan muncul setelah seminggu mencatat'), findsOne);
    expect(find.text('0 dari 7 hari'), findsOne);
    expect(find.byType(CategoryDonut), findsNothing);

    // One expense two days ago: the third day of recording.
    final db = app.database;
    final wallet = (await db.select(db.wallets).getSingle()).id;
    final food = (await (db.select(
      db.categories,
    )..where((c) => c.nameKey.equals('catFood'))).getSingle()).id;
    final id = await DriftTransactionRepository(db).add(
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: 22000,
        walletId: wallet,
        categoryId: food,
        occurredAt: DateTime.now().subtract(const Duration(days: 2)).toUtc(),
      ),
    );
    await _waitFor(tester, find.text('3 dari 7 hari'));
    expect(find.text('Wawasan muncul setelah seminggu mencatat'), findsOne);

    // Back to a clean slate for the sample data.
    await DriftTransactionRepository(db).softDelete(id);
    await db.delete(db.transactions).go();
    await _stop(tester, app);
  });

  testWidgets('b. Data contoh 60 hari dari Pengaturan (hanya build debug)', (
    tester,
  ) async {
    final app = await _start(tester);
    await _tap(tester, find.text('Profil'));
    await _tap(tester, find.text('Pengaturan'));
    await _scrollTo(tester, find.text('Isi data contoh 60 hari'));
    await _tap(tester, find.text('Isi data contoh 60 hari'));
    await _waitFor(
      tester,
      find.text('Data contoh terisi.'),
      timeout: const Duration(seconds: 180),
    );

    final db = app.database;
    final habits = await db.select(db.habits).get();
    expect(habits.map((h) => h.name), containsAll(['Kopi', 'Baca']));
    // Pressing it twice must not double the data.
    await tester.pump(const Duration(seconds: 5));
    await _tap(tester, find.text('Isi data contoh 60 hari'));
    await _waitFor(tester, find.text('Data contoh sudah ada.'));
    expect((await db.select(db.habits).get()).length, habits.length);
    await _stop(tester, app);
  });

  testWidgets('c. Angka di Wawasan cocok dengan hitungan manual', (
    tester,
  ) async {
    final app = await _start(tester);
    final db = app.database;
    final now = DateTime.now();
    final today = LocalDate.fromDateTime(now);
    final current = _Month(now.year, now.month);
    final previousDate = DateTime(now.year, now.month - 1);
    final previous = _Month(previousDate.year, previousDate.month);

    await _tap(tester, find.text('Wawasan'));
    expect(find.text('Kebiasaan yang dikurangi'), findsOne);
    expect(find.text('Kebiasaan yang dibangun'), findsOne);
    await _expectMonthNumbers(tester, db, current, today);

    // 3 coffees a week for 4 weeks at Rp 25.000: 12 x 25.000 / 4 weeks.
    expect(find.text('±3,0x/minggu\nProyeksi Rp 3,9 jt/th'), findsOneWidget);

    await _tap(tester, find.byType(PickerPill));
    await _tap(tester, find.text(previous.label));
    await _waitFor(tester, find.text('Kebiasaan yang dikurangi'));
    await _expectMonthNumbers(tester, db, previous, today);

    await _scrollTo(tester, find.text('Pengeluaran per kategori'));
    await _scrollTo(tester, find.byType(CategoryDonut));
    await _stop(tester, app);
  });

  testWidgets('d. Simulator: 50% dari kopi 3x/minggu x Rp 25.000 = '
      'Rp 1,95 jt/tahun, disclaimer selalu terlihat', (tester) async {
    final app = await _start(tester);
    const disclaimer = 'Simulasi, bukan saran keuangan.';
    await _tap(tester, find.text('Wawasan'));

    await _tap(tester, find.text('Kopi'));
    expect(find.text('Kalau Kopi dikurangi…'), findsOne);
    expect(find.text('50%'), findsOne);
    // 3 x 52 x 25.000 = 3.900.000; half of it is Rp 1,95 jt.
    expect(find.text('±Rp 1.950.000'), findsOne);
    expect(find.text(disclaimer), findsOne);

    await _tap(tester, find.text('Tabung & kembangkan'));
    expect(find.text('Rp 5.850.000'), findsOne);
    expect(find.text('Rp 9.750.000'), findsOne);
    expect(find.text(disclaimer), findsOne);

    await _tap(tester, find.widgetWithText(AppChip, '5%'));
    // A fixed Rp 162.500 a month at 5% a year, compounded monthly.
    expect(find.text('Rp 1.995.000'), findsOne);
    expect(find.text(disclaimer), findsOne);

    await _tap(tester, find.widgetWithText(AppChip, '0%'));
    await tester.drag(find.byType(Slider), const Offset(2000, 0));
    await tester.pumpAndSettle();
    expect(find.text('±Rp 3.900.000'), findsOne);
    expect(find.text(disclaimer), findsOne);
    await _stop(tester, app);
  });

  testWidgets('e. Beranda: kartu insight kontekstual', (tester) async {
    final app = await _start(tester);
    final db = app.database;
    final now = DateTime.now();
    final month = _Month(now.year, now.month);

    await _tap(tester, find.text('Beranda'));
    final spending = await _spending(db, month);
    if (spending.coffee > 0) {
      expect(
        find.text('Kopi sudah ${_rupiah(spending.coffee)} bulan ini.'),
        findsOne,
      );
      await _tap(tester, find.text('Lihat dampak'));
      expect(find.text('Kalau Kopi dikurangi…'), findsOne);
    }
    // Early in a month there is no coffee cost yet, so Home falls to the
    // streak or spending card; the widget tests cover those rules.
    await _stop(tester, app);
  });
}
