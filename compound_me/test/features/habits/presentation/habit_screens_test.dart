import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_database.dart';

/// Friday morning, 25 September 2026.
final _now = DateTime(2026, 9, 25, 8, 12);
final _today = LocalDate(2026, 9, 25);

Future<String> _wallet(AppDatabase db, String name, int balance) =>
    DriftWalletRepository(db).create(
      WalletDraft(
        name: name,
        type: WalletType.cash,
        iconKey: 'wallet',
        colorKey: 'teal',
        initialBalance: balance,
      ),
    );

/// Created on 1 September, so the habit has a history to show.
Future<String> _habit(AppDatabase db, HabitDraft draft) => DriftHabitRepository(
  db,
  clock: FakeClock(DateTime(2026, 9, 1, 9)).call,
).create(draft);

Future<void> _log(AppDatabase db, String id, LocalDate date, int count) =>
    DriftHabitRepository(db, clock: () => _now).setCount(id, date, count);

const _reading = HabitDraft(
  name: 'Baca',
  kind: HabitKind.build,
  iconKey: 'bookOpen',
  colorKey: 'blue',
  scheduleType: ScheduleType.daily,
);

HabitDraft _coffee(String wallet, String category, {int? limit}) => HabitDraft(
  name: 'Kopi',
  kind: HabitKind.reduce,
  iconKey: 'coffee',
  colorKey: 'coral',
  scheduleType: ScheduleType.daily,
  costPerOccurrence: 25000,
  walletId: wallet,
  categoryId: category,
  weeklyLimit: limit,
);

/// Plain queries only: awaiting a Drift stream in the test body would wait
/// on a timer that fake time never fires.
Future<({int count, int expenses})> _state(AppDatabase db) async {
  final logs = await (db.select(
    db.habitLogs,
  )..where((l) => l.deletedAt.isNull())).get();
  final expenses = await (db.select(
    db.transactions,
  )..where((t) => t.deletedAt.isNull() & t.habitLogId.isNotNull())).get();
  return (
    count: logs.fold<int>(0, (sum, l) => sum + l.count),
    expenses: expenses.length,
  );
}

Finder _balance(String text) =>
    find.descendant(of: find.byType(BalanceHeader), matching: find.text(text));

/// A widget with this semantics label, built even when scrolled away.
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

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('check-in (Flow C)', () {
    testApp('five fast taps stay consistent', (tester) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          final cash = await _wallet(db, 'Tunai', 100000);
          await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
        },
      );
      await goTo(tester, AppRoutes.habits);

      final check = find.byType(CheckButton);
      for (var i = 0; i < 5; i++) {
        await tester.tap(check, warnIfMissed: false);
      }
      await tester.pumpAndSettle();

      final state = await _state(database);
      expect(state.count, anyOf(0, 1));
      expect(state.expenses, state.count, reason: 'one expense per check-in');
      expect(tester.widget<CheckButton>(check).done, state.count > 0);
    });

    testApp('a reduce check-in lowers the balance; unchecking restores it', (
      tester,
    ) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 100000);
          await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
        },
      );
      expect(_balance('Rp 100.000'), findsOneWidget);

      await _tap(tester, find.byType(HabitChip));
      expect(_balance('Rp 75.000'), findsOneWidget);
      expect(find.text('Dicatat'), findsOneWidget);
      expect(tester.widget<HabitChip>(find.byType(HabitChip)).badge, 1);

      await _tap(tester, find.byType(HabitChip));
      expect(_balance('Rp 100.000'), findsOneWidget);
    });

    testApp('a check-in expense goes to the habit wallet', (tester) async {
      late AppDatabase database;
      late String gopay;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          await _wallet(db, 'Tunai', 100000);
          gopay = await _wallet(db, 'GoPay', 50000);
          await _habit(
            db,
            _coffee(gopay, await defaultCategoryId(db, 'catFood')),
          );
        },
      );
      await _tap(tester, find.byType(HabitChip));

      final expense = await (database.select(
        database.transactions,
      )..where((t) => t.habitLogId.isNotNull())).getSingle();
      expect(expense.walletId, gopay);
      expect(expense.amount, 25000);
    });

    testApp('long-press sets a count; the stepper stops at 10 but shows '
        'the real count', (tester) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          final cash = await _wallet(db, 'Tunai', 1000000);
          await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
        },
      );

      await tester.longPress(find.byType(HabitChip));
      await tester.pumpAndSettle();
      await _tap(tester, find.byTooltip('Tambah satu'));
      await _tap(tester, find.byTooltip('Tambah satu'));
      expect(find.text('2 × Rp 25.000 = Rp 50.000'), findsOneWidget);
      await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));
      expect((await _state(database)).expenses, 2);

      await tester.longPress(find.byType(HabitChip));
      await tester.pumpAndSettle();
      await _tap(tester, find.byTooltip('Kurangi satu'));
      await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));
      expect((await _state(database)).expenses, 1);
    });

    testApp('a count above 10 shows as it is; plus is off', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 1000000);
          final id = await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
          await _log(db, id, _today, 10);
          // A restored expense can push the count past the stepper's max.
          final logId = (await db.select(db.habitLogs).getSingle()).id;
          await db
              .update(db.habitLogs)
              .write(const HabitLogsCompanion(count: Value(11)));
          expect(logId, isNotEmpty);
        },
      );

      await tester.longPress(find.byType(HabitChip));
      await tester.pumpAndSettle();
      expect(find.text('11'), findsWidgets);
      final plus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, AppIcons.plus).last,
      );
      expect(plus.onPressed, isNull);
      final minus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, AppIcons.minus).last,
      );
      expect(minus.onPressed, isNotNull);
    });
  });

  group('habits (S-20)', () {
    testApp('today and all; archived habits fold away', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          await _wallet(db, 'Tunai', 0);
          await _habit(db, _reading);
          await _habit(
            db,
            const HabitDraft(
              name: 'Lari akhir pekan',
              kind: HabitKind.build,
              iconKey: 'personSimpleRun',
              colorKey: 'green',
              scheduleType: ScheduleType.weekdays,
              scheduleDays: Weekdays.saturday | Weekdays.sunday,
            ),
          );
          final old = await _habit(
            db,
            const HabitDraft(
              name: 'Jajan',
              kind: HabitKind.build,
              iconKey: 'cookie',
              colorKey: 'rose',
              scheduleType: ScheduleType.daily,
            ),
          );
          await DriftHabitRepository(db).archive(old);
        },
      );
      await goTo(tester, AppRoutes.habits);

      expect(find.text('Baca'), findsOneWidget);
      expect(find.text('Lari akhir pekan'), findsNothing, reason: 'Friday');

      await _tap(tester, find.text('Semua'));
      expect(find.text('Lari akhir pekan'), findsOneWidget);
      expect(find.text('Jajan'), findsNothing);
      await _tap(tester, find.text('Diarsipkan (1)'));
      expect(find.text('Jajan'), findsOneWidget);
    });

    testApp('the empty state offers the onboarding templates', (tester) async {
      await pumpApp(tester, now: _now);
      await goTo(tester, AppRoutes.habits);

      expect(find.text('Mulai dari satu kebiasaan'), findsOneWidget);
      await _tap(tester, find.text('Pilih dari template'));
      expect(find.byType(SelectableCard), findsNWidgets(8));

      await _tap(tester, find.text('Kopi kekinian'));
      expect(find.text('Kebiasaan baru'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Kopi kekinian'), findsOneWidget);
      final reduce = tester.widget<SelectableCard>(
        find.widgetWithText(SelectableCard, 'Kurangi'),
      );
      expect(reduce.selected, isTrue);
      await _scrollTo(tester, _labelled('Kategori, Makanan & minuman'));
      expect(_labelled('Biaya per kali, Rp 25.000'), findsOneWidget);
    });

    testApp('a reduce habit without a limit invites one', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 0);
          await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
        },
      );
      await goTo(tester, AppRoutes.habits);

      await _tap(tester, find.text('Atur batas mingguan untuk mulai streak'));
      expect(find.text('Edit kebiasaan'), findsOneWidget);
      await _tap(tester, find.byTooltip('Tutup'));

      await _tap(tester, find.text('Kopi'));
      expect(
        find.text('Atur batas mingguan untuk mulai streak'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Streak, –'), findsOneWidget);
    });

    testApp('reorder mode shows drag handles', (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          await _wallet(db, 'Tunai', 0);
          await _habit(db, _reading);
          await _habit(db, _reading.copyWithName('Minum air'));
        },
      );
      await goTo(tester, AppRoutes.habits);

      await _tap(tester, find.byTooltip('Menu lainnya'));
      await _tap(tester, find.text('Atur urutan'));
      expect(_labelled('Geser untuk mengurutkan Baca'), findsOneWidget);
      await _tap(tester, find.text('Selesai'));
      expect(find.byType(CheckButton), findsNWidgets(2));
    });
  });

  group('habit form (S-21)', () {
    testApp('a build habit on chosen days, Monday first', (tester) async {
      late AppDatabase database;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          database = db;
          await _wallet(db, 'Tunai', 0);
        },
      );
      await goTo(tester, AppRoutes.habits);
      await _tap(tester, find.byTooltip('Buat kebiasaan'));

      await tester.enterText(find.byType(TextField), 'Olahraga pagi');
      await _tap(tester, find.text('Hari tertentu'));
      final monday = tester.getCenter(find.bySemanticsLabel('Senin'));
      final sunday = tester.getCenter(find.bySemanticsLabel('Minggu'));
      expect(monday.dx, lessThan(sunday.dx), reason: 'weeks start on Monday');
      await _tap(tester, find.bySemanticsLabel('Senin'));
      await _tap(tester, find.bySemanticsLabel('Sabtu'));
      await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));

      final habit = await database.select(database.habits).getSingle();
      expect(habit.name, 'Olahraga pagi');
      expect(
        habit.scheduleDays,
        Weekdays.tuesday |
            Weekdays.wednesday |
            Weekdays.thursday |
            Weekdays.friday |
            Weekdays.saturday,
      );
    });

    testApp('closing with changes asks first', (tester) async {
      await pumpApp(tester, now: _now);
      await goTo(tester, AppRoutes.habits);
      await _tap(tester, find.byTooltip('Buat kebiasaan'));
      await tester.enterText(find.byType(TextField), 'Baca');
      await tester.pump();

      await _tap(tester, find.byTooltip('Tutup'));
      expect(find.text('Buang perubahan?'), findsOneWidget);
      await _tap(tester, find.text('Buang'));
      expect(find.text('Kebiasaan baru'), findsNothing);
    });

    testApp('a reduce habit needs a cost and a category', (tester) async {
      await pumpApp(tester, now: _now, seed: (db) => _wallet(db, 'Tunai', 0));
      await goTo(tester, AppRoutes.habits);
      await _tap(tester, find.byTooltip('Buat kebiasaan'));
      await tester.enterText(find.byType(TextField), 'Rokok');
      await _tap(tester, find.text('Kurangi'));
      await _tap(tester, find.widgetWithText(PrimaryButton, 'Simpan'));

      await _scrollTo(tester, find.text('Pilih kategori pengeluaran.'));
      expect(find.text('Isi biaya lebih dari Rp 0.'), findsOneWidget);
      expect(find.text('Kebiasaan baru'), findsOneWidget, reason: 'stays');
    });

    testApp('a habit with check-ins keeps its kind and offers a new one', (
      tester,
    ) async {
      late String id;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          await _wallet(db, 'Tunai', 0);
          id = await _habit(db, _reading);
          await _log(db, id, _today, 1);
        },
      );
      await goTo(tester, AppRoutes.habitEdit(id));

      await _tap(tester, find.text('Kurangi'));
      expect(find.text('Jenis tidak bisa diganti'), findsOneWidget);
      await _tap(tester, find.text('Buat kebiasaan baru'));

      expect(find.text('Kebiasaan baru'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Baca'), findsOneWidget);
      final reduce = tester.widget<SelectableCard>(
        find.widgetWithText(SelectableCard, 'Kurangi'),
      );
      expect(reduce.selected, isTrue);
    });
  });

  group('habit detail (S-22)', () {
    testApp('a single missed day is a grace day in the calendar', (
      tester,
    ) async {
      late String id;
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          await _wallet(db, 'Tunai', 0);
          id = await _habit(db, _reading);
          for (var day = 1; day <= 24; day++) {
            if (day == 20) continue;
            await _log(db, id, LocalDate(2026, 9, day), 1);
          }
        },
      );
      await goTo(tester, AppRoutes.habit(id));

      expect(_labelled('Streak, 23 hari'), findsOneWidget);
      final grace = _labelled('Minggu, 20 September 2026, Hari longgar');
      await _scrollTo(tester, grace);
      expect(grace, findsOneWidget);
      // Its own node for screen readers, not merged into the month.
      expect(
        find.bySemanticsLabel('Minggu, 20 September 2026, Hari longgar'),
        findsOneWidget,
      );
      expect(find.text('Hari longgar'), findsOneWidget, reason: 'legend');
      final monday = tester.getCenter(_labelled('Senin'));
      final sunday = tester.getCenter(_labelled('Minggu'));
      expect(monday.dx, lessThan(sunday.dx));
    });

    testApp('"Dari kebiasaan" in a transaction opens the habit', (
      tester,
    ) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 100000);
          final id = await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
          await _log(db, id, _today, 1);
        },
      );

      await _tap(tester, find.byType(TransactionTile));
      await _tap(tester, find.text('Dari kebiasaan: Kopi'));
      await _scrollTo(tester, find.text('Check-in terakhir'));
      expect(find.text('Biaya bulan ini'), findsOneWidget);
      expect(find.text('Simulasikan'), findsOneWidget);
    });
  });

  group('home strip and calendars', () {
    testApp("the strip holds today's habits, open ones first", (tester) async {
      await pumpApp(
        tester,
        now: _now,
        seed: (db) async {
          final cash = await _wallet(db, 'Tunai', 100000);
          final reading = await _habit(db, _reading);
          await _log(db, reading, _today, 1);
          await _habit(
            db,
            _coffee(cash, await defaultCategoryId(db, 'catFood')),
          );
          await _habit(
            db,
            const HabitDraft(
              name: 'Lari akhir pekan',
              kind: HabitKind.build,
              iconKey: 'personSimpleRun',
              colorKey: 'green',
              scheduleType: ScheduleType.weekdays,
              scheduleDays: Weekdays.saturday | Weekdays.sunday,
            ),
          );
        },
      );

      final chips = tester.widgetList<HabitChip>(find.byType(HabitChip));
      expect([for (final c in chips) c.label], ['Kopi', 'Baca']);
      expect(chips.last.done, isTrue);
    });

    testApp('the transaction date calendar starts on Monday', (tester) async {
      await pumpApp(tester, now: _now);
      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();
      await _tap(tester, find.bySemanticsLabel(RegExp('^Tanggal')));

      final monday = tester.getCenter(_labelled('Senin'));
      final sunday = tester.getCenter(_labelled('Minggu'));
      expect(monday.dx, lessThan(sunday.dx));
      await _tap(tester, _labelled('Kamis, 24 September 2026'));
      expect(
        find.bySemanticsLabel(RegExp('^Tanggal, Kemarin')),
        findsOneWidget,
      );
    });
  });
}

extension on HabitDraft {
  HabitDraft copyWithName(String name) => HabitDraft(
    name: name,
    kind: kind,
    iconKey: iconKey,
    colorKey: colorKey,
    scheduleType: scheduleType,
    scheduleDays: scheduleDays,
    timesPerWeek: timesPerWeek,
  );
}
