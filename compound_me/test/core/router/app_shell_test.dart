import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Tab label in the bottom nav paired with the empty state title it shows.
typedef _Tab = ({String label, String emptyTitle});

const _idTabs = <_Tab>[
  (label: 'Beranda', emptyTitle: 'Belum ada transaksi'),
  (label: 'Kebiasaan', emptyTitle: 'Mulai dari satu kebiasaan'),
  (label: 'Wawasan', emptyTitle: 'Wawasan muncul setelah seminggu mencatat'),
  (label: 'Profil', emptyTitle: 'Profil belum diatur'),
];

const _enTabs = <_Tab>[
  (label: 'Home', emptyTitle: 'No transactions yet'),
  (label: 'Habits', emptyTitle: 'Start with one habit'),
  (label: 'Insights', emptyTitle: 'Insights appear after a week of logging'),
  (label: 'Profile', emptyTitle: "Your profile isn't set up yet"),
];

Finder _navTab(String label) =>
    find.descendant(of: find.byType(AppBottomNav), matching: find.text(label));

Future<void> _visitAllTabs(WidgetTester tester, List<_Tab> tabs) async {
  for (final tab in [...tabs.skip(1), tabs.first]) {
    await tester.tap(_navTab(tab.label));
    await tester.pumpAndSettle();
    expect(find.text(tab.emptyTitle), findsOneWidget, reason: tab.label);
    expect(tester.takeException(), isNull, reason: tab.label);
  }
}

void main() {
  group('AppShell', () {
    testWidgets('opens on Beranda with its empty state', (tester) async {
      await pumpApp(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Belum ada transaksi'), findsOneWidget);
      expect(find.text('Catat transaksi pertama'), findsOneWidget);
    });

    testWidgets('bottom nav switches between the four tabs', (tester) async {
      await pumpApp(tester);

      await _visitAllTabs(tester, _idTabs);
    });

    testWidgets('every tab has an English empty state', (tester) async {
      await pumpApp(tester, localeCode: 'en');

      expect(find.text(_enTabs.first.emptyTitle), findsOneWidget);
      await _visitAllTabs(tester, _enTabs);
    });

    testWidgets('center add button opens the add transaction sheet', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Tambah transaksi'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Tambah transaksi'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('home empty state action opens the same sheet', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Catat transaksi pertama'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('dark theme renders every tab without errors', (tester) async {
      await pumpApp(tester, themeMode: ThemeMode.dark);

      final context = tester.element(find.byType(HomeScreen));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(context.tokens.colors.bg, AppColors.dark.bg);
      await _visitAllTabs(tester, _idTabs);
    });

    testWidgets('layout holds at text scale 1.3 on a small phone', (
      tester,
    ) async {
      await pumpApp(
        tester,
        textScale: 1.3,
        physicalSize: const Size(720, 1280),
        devicePixelRatio: 2,
      );

      expect(tester.takeException(), isNull);
      await _visitAllTabs(tester, _idTabs);
    });
  });
}
