// Accessibility audit of every screen (06 phase 6, 03 §5, PRD §8) in both
// languages at text scale 1,3 on a 360 dp wide phone: nothing overflows,
// and everything a screen reader can activate has a name.

import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/settings/data/debug_sample_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

/// [testApp] with semantics switched on for the whole test.
@isTest
void testAudit(
  String description,
  Future<void> Function(WidgetTester tester) body,
) => testApp(description, (tester) async {
  final handle = tester.ensureSemantics();
  try {
    await body(tester);
  } finally {
    handle.dispose();
  }
});

/// Friday morning, 25 September 2026.
final _now = DateTime(2026, 9, 25, 8, 12);

/// 60 days of habits and transactions, so every list has rows.
Future<void> _sample(AppDatabase db) async {
  await seedWallet(db, initialBalance: 0);
  await DebugSampleData(db, clock: () => _now).fill();
}

/// Semantics nodes that can be activated but say nothing: no label, value,
/// tooltip or hint of their own, and no named child merged into them.
List<String> _unnamedActions(WidgetTester tester) {
  final unnamed = <String>[];
  // The nodes a screen reader would visit, in its order.
  for (final node in tester.semantics.simulatedAccessibilityTraversal()) {
    final data = node.getSemanticsData();
    final actionable =
        data.hasAction(SemanticsAction.tap) ||
        data.hasAction(SemanticsAction.longPress);
    if (actionable &&
        data.label.trim().isEmpty &&
        data.value.trim().isEmpty &&
        data.tooltip.trim().isEmpty &&
        data.hint.trim().isEmpty) {
      unnamed.add('${node.rect} (id ${node.id})');
    }
  }
  return unnamed;
}

/// Closes the topmost sheet: sheets open on the root navigator.
Future<void> _closeSheet(WidgetTester tester) async {
  Navigator.of(
    tester.element(find.byType(Scaffold).first),
    rootNavigator: true,
  ).pop();
  await tester.pumpAndSettle();
}

/// Where Flutter says the last errors came from (the widget's file and
/// line), so a failure points at the code.
final _errorSites = <String>[];

/// Opens [location], then checks it for overflow and unnamed actions.
Future<void> _check(WidgetTester tester, String location) async {
  await goTo(tester, location);
  _expectClean(tester, location);
}

void _expectClean(WidgetTester tester, String where) {
  final error = tester.takeException();
  expect(
    error,
    isNull,
    reason:
        '$where overflows or throws at text scale 1,3: $error '
        '${_errorSites.join(' | ')}',
  );
  expect(
    _unnamedActions(tester),
    isEmpty,
    reason: '$where has actions without a name',
  );
}

void main() {
  testWidgets('the audit itself catches an icon button without a name', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    Widget app({String? tooltip}) => MaterialApp(
      home: Scaffold(
        body: IconButton(
          icon: const Icon(Icons.add),
          tooltip: tooltip,
          onPressed: () {},
        ),
      ),
    );

    await tester.pumpWidget(app());
    expect(_unnamedActions(tester), hasLength(1));
    await tester.pumpWidget(app(tooltip: 'Add'));
    expect(_unnamedActions(tester), isEmpty);
    handle.dispose();
  });

  for (final language in ['id', 'en']) {
    final addLabel = language == 'id' ? 'Tambah transaksi' : 'Add transaction';
    testAudit('every screen holds up at text scale 1,3 and names its actions '
        '($language)', (tester) async {
      final db = await pumpApp(
        tester,
        now: _now,
        seed: _sample,
        localeCode: language,
        textScale: 1.3,
        physicalSize: const Size(1080, 2160),
        devicePixelRatio: 3,
      );
      _errorSites.clear();
      final report = FlutterError.onError;
      FlutterError.onError = (details) {
        _errorSites.add(
          details
              .toString()
              .split('\n')
              .where((l) => l.contains('.dart:'))
              .join(' '),
        );
        report?.call(details);
      };
      final coffee = (await db.select(db.habits).get()).firstWhere(
        (h) => h.name == 'Kopi',
      );
      final wallet = (await db.select(db.wallets).get()).first;
      final category = (await db.select(db.categories).get()).firstWhere(
        (c) => c.nameKey == 'catFood',
      );

      for (final location in [
        AppRoutes.home,
        AppRoutes.transactions,
        AppRoutes.habits,
        AppRoutes.habit(coffee.id),
        AppRoutes.habitEdit(coffee.id),
        AppRoutes.habitNew,
        AppRoutes.insights,
        AppRoutes.me,
        AppRoutes.wallets,
        AppRoutes.wallet(wallet.id),
        AppRoutes.walletNew,
        AppRoutes.categories,
        AppRoutes.category(category.id),
        AppRoutes.categoryNew('expense'),
        AppRoutes.settings,
        AppRoutes.about,
      ]) {
        await _check(tester, location);
      }

      // The sheets: add transaction, a transaction's detail, the simulator.
      await goTo(tester, AppRoutes.home);
      await tester.tap(find.bySemanticsLabel(addLabel));
      await tester.pumpAndSettle();
      _expectClean(tester, 'add transaction sheet');
      await _closeSheet(tester);

      // The recent transactions sit below the fold at this text size.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TransactionTile).first);
      await tester.pumpAndSettle();
      _expectClean(tester, 'transaction detail');
      await _closeSheet(tester);

      await goTo(tester, AppRoutes.insights);
      await tester.tap(find.byType(InsightHabitTile).first);
      await tester.pumpAndSettle();
      _expectClean(tester, 'simulator');
    });

    testAudit('onboarding holds up at text scale 1,3 and names its actions '
        '($language)', (tester) async {
      await pumpApp(
        tester,
        localeCode: language,
        onboarded: false,
        textScale: 1.3,
        physicalSize: const Size(1080, 2160),
        devicePixelRatio: 3,
      );

      _expectClean(tester, 'onboarding');
    });
  }
}
