// Scroll performance of the history with 1.000 transactions (06 phase 6,
// PRD §8: 60 fps). Run in profile mode on the emulator; the driver writes
// build/history_scroll.timeline_summary.json:
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_history_test.dart -d <device>
// It starts from the app's own database, adds a wallet and 1.000
// transactions across 200 days if the history is smaller, and leaves them.

import 'package:compound_me/app.dart';
import 'package:compound_me/bootstrap/app_bootstrap.dart';
import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/router/app_router.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _transactions = 1000;
const _days = 200;

Future<void> _fill(AppDatabase db) async {
  final existing = await db.select(db.transactions).get();
  if (existing.length >= _transactions) return;
  var wallets = await db.select(db.wallets).get();
  if (wallets.isEmpty) {
    await DriftWalletRepository(db).create(
      WalletDraft(
        name: 'Tunai',
        type: WalletType.cash,
        iconKey: WalletType.cash.defaultIconKey,
        colorKey: 'teal',
        initialBalance: 0,
      ),
    );
    wallets = await db.select(db.wallets).get();
  }
  final expense = (await db.select(db.categories).get())
      .where((c) => c.kind.name == 'expense')
      .toList();
  final now = DateTime.now();
  await db.batch((batch) {
    batch.insertAll(db.transactions, [
      for (var i = 0; i < _transactions; i++)
        TransactionsCompanion.insert(
          id: newId(),
          kind: TransactionKind.expense,
          amount: 5000 + (i * 7919) % 95000,
          walletId: wallets.first.id,
          categoryId: expense[i % expense.length].id,
          occurredAt: toStoredUtc(
            now.subtract(Duration(days: i % _days, hours: i % 23)),
          ),
          createdAt: toStoredUtc(now),
          updatedAt: toStoredUtc(now),
        ),
    ]);
  });
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('history scroll with 1.000 transactions', (tester) async {
    // Fills first, then boots on that data, so onboarding counts as done.
    final seed = await AppBootstrap.load();
    await _fill(seed.database);
    await seed.database.close();
    final app = await AppBootstrap.load();
    await tester.pumpWidget(
      ProviderScope(overrides: app.overrides, child: const CompoundMeApp()),
    );
    await tester.pumpAndSettle();

    ProviderScope.containerOf(tester.element(find.byType(CompoundMeApp)))
        .read(appRouterProvider)
        .go(AppRoutes.transactions);
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable).first;

    await binding.traceAction(() async {
      // Down through the month, then back up, a few times over.
      for (var round = 0; round < 3; round++) {
        for (var i = 0; i < 6; i++) {
          await tester.fling(list, const Offset(0, -700), 1800);
          await tester.pumpAndSettle();
        }
        for (var i = 0; i < 6; i++) {
          await tester.fling(list, const Offset(0, 700), 1800);
          await tester.pumpAndSettle();
        }
      }
    }, reportKey: 'history_scroll');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await app.database.close();
  });

  // The emulator's own floor: a plain list of 1.000 Material tiles, no
  // CompoundMe code, scrolled the same way. Raster time on the emulator
  // is mostly its GPU bridge, so this is what the history is judged against.
  testWidgets('baseline: plain ListView of 1.000 tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: 1000,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.circle),
              title: Text('Row $i'),
              subtitle: const Text('Plain Material tile'),
              trailing: Text('Rp $i'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final list = find.byType(Scrollable).first;

    await binding.traceAction(() async {
      for (var round = 0; round < 3; round++) {
        for (var i = 0; i < 6; i++) {
          await tester.fling(list, const Offset(0, -700), 1800);
          await tester.pumpAndSettle();
        }
        for (var i = 0; i < 6; i++) {
          await tester.fling(list, const Offset(0, 700), 1800);
          await tester.pumpAndSettle();
        }
      }
    }, reportKey: 'baseline_scroll');
  });
}
