// Every screen that reads data shows a friendly error state with "Coba
// lagi" when its data fails to load (03 §4, CLAUDE.md rule 6), and loads
// again when the user retries.

import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/presentation/category_providers.dart';
import 'package:compound_me/features/habits/presentation/habit_providers.dart';
import 'package:compound_me/features/home/presentation/home_screen.dart';
import 'package:compound_me/features/insights/presentation/insights_providers.dart';
import 'package:compound_me/features/settings/data/debug_sample_data.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/transaction_providers.dart';
import 'package:compound_me/features/wallets/presentation/wallet_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// Friday morning, 25 September 2026.
final _now = DateTime(2026, 9, 25, 8, 12);
final _month = YearMonth.of(_now);

Future<void> _sample(AppDatabase db) async {
  await seedWallet(db, initialBalance: 0);
  await DebugSampleData(db, clock: () => _now).fill();
}

final _boom = StateError('the data could not be read');

Stream<T> _fails<T>() => Stream<T>.error(_boom);

AsyncValue<T> _failed<T>() => AsyncError<T>(_boom, StackTrace.empty);

void _expectErrorState(WidgetTester tester) {
  expect(find.text('Data belum bisa dimuat'), findsOneWidget);
  expect(find.text('Coba lagi'), findsOneWidget);
}

void main() {
  final cases = <(String, String, List<Override> Function())>[
    (
      'Home',
      AppRoutes.home,
      () => [recentTransactionsProvider.overrideWith((ref) => _fails())],
    ),
    (
      'History (S-13)',
      AppRoutes.transactions,
      () => [
        transactionHistoryProvider(
          TransactionFilter(year: _month.year, month: _month.month),
          null,
        ).overrideWith((ref) => _fails()),
      ],
    ),
    (
      'Habits (S-20)',
      AppRoutes.habits,
      () => [habitProgressProvider.overrideWith((ref) => _failed())],
    ),
    (
      'Insights (S-30)',
      AppRoutes.insights,
      () => [recordedDaysProvider.overrideWith((ref) => _failed())],
    ),
    (
      'Insights month (S-30)',
      AppRoutes.insights,
      () => [monthInsightsProvider(_month).overrideWith((ref) => _failed())],
    ),
    (
      'Wallets (S-41)',
      AppRoutes.wallets,
      () => [activeWalletsProvider.overrideWith((ref) => _fails())],
    ),
    (
      'Categories (S-42)',
      AppRoutes.categories,
      () => [
        categoriesOfKindProvider(CategoryKind.expense)
            .overrideWith((ref) => _fails()),
      ],
    ),
  ];

  for (final (name, route, overrides) in cases) {
    testApp('$name shows an error state with Coba lagi', (tester) async {
      await pumpApp(tester, now: _now, seed: _sample, overrides: overrides());

      await goTo(tester, route);

      _expectErrorState(tester);
      // Retrying asks again (it fails again here) without crashing.
      await tester.ensureVisible(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      _expectErrorState(tester);
    });
  }

  testApp('Home loads again after a retry', (tester) async {
    var failing = true;
    await pumpApp(
      tester,
      now: _now,
      seed: _sample,
      overrides: [
        recentTransactionsProvider.overrideWith((ref) {
          if (failing) return _fails();
          return ref
              .watch(transactionRepositoryProvider)
              .watchItems(const TransactionFilter(), limit: homeRecentLimit);
        }),
      ],
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    _expectErrorState(tester);

    failing = false;
    // The error sits under the Home header, below the fold.
    await tester.ensureVisible(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Coba lagi'), findsNothing);
    expect(find.text('Transaksi terbaru'), findsOneWidget);
  });
}
