import 'package:compound_me/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('PrimaryButton', () {
    testWidgets('calls onPressed when enabled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Simpan', onPressed: () => taps++)),
      );

      await tester.tap(find.text('Simpan'));
      expect(taps, 1);
    });

    testWidgets('hugs its label when expand is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              PrimaryButton(label: 'Simpan', onPressed: () {}),
              PrimaryButton(label: 'Simpan', onPressed: () {}, expand: false),
            ],
          ),
        ),
      );

      final buttons = find.byType(PrimaryButton);
      final full = tester.getSize(buttons.first).width;
      final compact = tester.getSize(buttons.last).width;
      expect(
        full,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
      expect(compact, lessThan(full));
      expect(
        tester.getSize(buttons.last).height,
        greaterThanOrEqualTo(AppSizes.buttonHeight),
      );
    });

    testWidgets('is dimmed and ignores taps when disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(label: 'Simpan', onPressed: null)),
      );

      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('Simpan'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, AppOpacity.disabled);
      expect(
        tester.getSemantics(find.byType(PrimaryButton)),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );
    });

    testWidgets('shows a spinner instead of the label while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            label: 'Simpan',
            onPressed: () => taps++,
            loading: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Simpan'), findsNothing);
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 0);
    });
  });

  testWidgets('SegmentedToggle reports the tapped option', (tester) async {
    String? changed;
    await tester.pumpWidget(
      _wrap(
        SegmentedToggle<String>(
          options: const [
            SegmentedToggleOption(value: 'expense', label: 'Pengeluaran'),
            SegmentedToggleOption(value: 'income', label: 'Pemasukan'),
          ],
          selected: 'expense',
          onChanged: (value) => changed = value,
        ),
      ),
    );

    await tester.tap(find.text('Pemasukan'));
    expect(changed, 'income');

    changed = null;
    await tester.tap(find.text('Pengeluaran'));
    expect(changed, isNull, reason: 'selected option is a no-op');
  });

  testWidgets('showUndoSnackbar runs onUndo and closes', (tester) async {
    var undone = 0;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) => PrimaryButton(
            label: 'Hapus',
            onPressed: () => showUndoSnackbar(
              context,
              message: 'Transaksi dihapus',
              undoLabel: 'Urungkan',
              onUndo: () => undone++,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Transaksi dihapus'), findsOneWidget);

    await tester.tap(find.text('Urungkan'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.text('Transaksi dihapus'), findsNothing);
  });

  testWidgets('EmptyState hides the action when none is given', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const EmptyState(
          icon: Icons.circle,
          title: 'Mulai dari satu kebiasaan',
          message: 'Penjelasan singkat.',
        ),
      ),
    );

    expect(find.text('Mulai dari satu kebiasaan'), findsOneWidget);
    expect(find.byType(PrimaryButton), findsNothing);
  });
}
