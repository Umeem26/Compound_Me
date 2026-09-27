import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_draft.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _typeAmount(WidgetTester tester, List<String> keys) async {
  await tester.longPress(find.bySemanticsLabel('Hapus satu angka'));
  await tester.pump();
  for (final key in keys) {
    await tester.tap(find.bySemanticsLabel(key));
    await tester.pump();
  }
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

String _draftAt(OnboardingStep step) => OnboardingDraft(
  step: step,
  name: 'Raka',
  walletName: 'Dompet utama',
).encode();

void main() {
  testWidgets('a new user goes from language to Home in one pass', (
    tester,
  ) async {
    final db = await pumpApp(
      tester,
      onboarded: false,
      localeCode: null,
      prefs: {'addCoachMarkSeen': false},
    );

    // The test device speaks English; picking Indonesian switches at once.
    expect(find.text('Choose your language'), findsOneWidget);
    await _tap(tester, find.text('Bahasa Indonesia'));
    expect(find.text('Pilih bahasa'), findsOneWidget);
    await _tap(tester, find.text('Lanjut'));

    expect(find.text('Kebiasaan kecil, dampak besar'), findsOneWidget);
    await _tap(tester, find.text('Lewati'));

    await _tap(tester, find.text('Lanjut'));
    expect(find.text('Nama belum diisi.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Raka');
    await _tap(tester, find.text('Lanjut'));

    expect(find.text('Dompet pertama'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Tunai'), findsOneWidget);
    await _tap(tester, find.text('Bank'));
    await _tap(tester, find.bySemanticsLabel('Saldo awal, Rp 0'));
    await _typeAmount(tester, ['1', '0', '0', '000']);
    expect(find.bySemanticsLabel('Saldo awal, Rp 100.000'), findsOneWidget);
    await _tap(tester, find.text('Lanjut'));

    expect(find.text('Lewati dulu'), findsOneWidget);
    await _tap(tester, find.text('Baca 10 halaman'));
    await _tap(tester, find.text('Kopi kekinian'));
    await _tap(
      tester,
      find.bySemanticsLabel('Ubah biaya Kopi kekinian, sekarang Rp 25.000'),
    );
    await _typeAmount(tester, ['3', '0', '000']);
    await _tap(tester, find.text('Mulai'));

    expect(find.text('Belum ada transaksi'), findsOneWidget);
    final wallet = await db.select(db.wallets).getSingle();
    expect(wallet.name, 'Tunai');
    expect(wallet.type, WalletType.bank);
    expect(wallet.initialBalance, 100000);
    final habits = await db.select(db.habits).get();
    expect(habits.map((h) => h.name), ['Baca 10 halaman', 'Kopi kekinian']);
    expect(habits.last.kind, HabitKind.reduce);
    expect(habits.last.costPerOccurrence, 30000);
    expect(habits.last.walletId, wallet.id);

    final prefs = await AppPreferences.load();
    expect(prefs.onboardingDone, isTrue);
    expect(prefs.userName, 'Raka');
    expect(prefs.onboardingDraft, isNull);

    // Flow A ends with a one-time hint on the add button.
    expect(find.byType(CoachMark), findsOneWidget);
    await _tap(tester, find.text('Mengerti'));
    expect(find.byType(CoachMark), findsNothing);
    expect((await AppPreferences.load()).addCoachMarkSeen, isTrue);
  });

  testWidgets('an empty name is rejected', (tester) async {
    await pumpApp(
      tester,
      onboarded: false,
      prefs: {
        'onboardingDraft': const OnboardingDraft(step: OnboardingStep.name)
            .encode(),
      },
    );

    await tester.enterText(find.byType(TextField), '   ');
    await _tap(tester, find.text('Lanjut'));

    expect(find.text('Nama belum diisi.'), findsOneWidget);
    expect(find.text('Panggil kamu siapa?'), findsOneWidget);
  });

  testWidgets('system back returns to the previous step with its input', (
    tester,
  ) async {
    await pumpApp(
      tester,
      onboarded: false,
      prefs: {'onboardingDraft': _draftAt(OnboardingStep.name)},
    );
    expect(find.widgetWithText(TextField, 'Raka'), findsOneWidget);
    await _tap(tester, find.text('Lanjut'));
    expect(find.text('Dompet pertama'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Panggil kamu siapa?'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Raka'), findsOneWidget);
  });

  testWidgets('an interrupted onboarding resumes at its last step', (
    tester,
  ) async {
    await pumpApp(
      tester,
      onboarded: false,
      prefs: {'onboardingDraft': _draftAt(OnboardingStep.wallet)},
    );

    expect(find.text('Dompet pertama'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Dompet utama'), findsOneWidget);
  });

  testWidgets('at most three habits can be picked, zero skips', (tester) async {
    final db = await pumpApp(
      tester,
      onboarded: false,
      prefs: {'onboardingDraft': _draftAt(OnboardingStep.habits)},
    );
    const build = [
      'Olahraga',
      'Baca 10 halaman',
      'Bawa bekal',
      'Minum air 8 gelas',
    ];
    for (final name in build) {
      await _tap(tester, find.text(name));
    }

    bool selected(String name) => tester
        .widget<SelectableCard>(find.widgetWithText(SelectableCard, name))
        .selected;
    expect(build.map(selected), [true, true, true, false]);

    for (final name in build.take(3)) {
      await _tap(tester, find.text(name));
    }
    await _tap(tester, find.text('Lewati dulu'));

    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(await db.select(db.habits).get(), isEmpty);
    expect((await db.select(db.wallets).getSingle()).name, 'Dompet utama');
  });

  testWidgets('a finished onboarding cannot be reopened', (tester) async {
    await pumpApp(tester);

    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(find.text('Pilih bahasa'), findsNothing);
  });
}
