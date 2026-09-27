import 'package:compound_me/core/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: mode,
  home: Scaffold(
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: child,
    ),
  ),
);

/// Hosts a button that opens a sheet and records what it returns.
class _SheetHost<T> extends StatefulWidget {
  const _SheetHost(this.open);

  final Future<T?> Function(BuildContext context) open;

  @override
  State<_SheetHost<T>> createState() => _SheetHostState<T>();
}

class _SheetHostState<T> extends State<_SheetHost<T>> {
  T? result;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      final value = await widget.open(context);
      setState(() => result = value);
    },
    child: Text('open $result'),
  );
}

void main() {
  group('AmountKeypad', () {
    Future<List<int>> type(WidgetTester tester, List<String> keys) async {
      var amount = 0;
      final changes = <int>[];
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => AmountKeypad(
              amount: amount,
              backspaceLabel: 'Hapus',
              onChanged: (value) => setState(() {
                amount = value;
                changes.add(value);
              }),
            ),
          ),
        ),
      );
      for (final key in keys) {
        final finder = find.bySemanticsLabel(key);
        if (key == 'hold') {
          await tester.longPress(find.bySemanticsLabel('Hapus'));
        } else {
          await tester.tap(finder);
        }
        await tester.pump();
      }
      return changes;
    }

    testWidgets('builds the amount from digits and 000', (tester) async {
      expect(await type(tester, ['2', '5', '000']), [2, 25, 25000]);
    });

    testWidgets('backspace drops a digit, long press clears', (tester) async {
      expect(await type(tester, ['1', '2', '3', 'Hapus', 'hold']), [
        1,
        12,
        123,
        12,
        0,
      ]);
    });

    testWidgets('a zero on an empty amount changes nothing', (tester) async {
      expect(await type(tester, ['0', '000']), isEmpty);
    });
  });

  testWidgets('AmountDisplay speaks the full amount', (tester) async {
    await tester.pumpWidget(_wrap(const AmountDisplay(amount: 25000)));

    expect(find.text('25.000'), findsOneWidget);
    expect(find.text('Rp'), findsOneWidget);
    expect(find.bySemanticsLabel('Rp 25.000'), findsOneWidget);
  });

  testWidgets('AppTextField shows the label and an error', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(
        AppTextField(
          label: 'Nama',
          controller: controller,
          errorText: 'Nama wajib diisi',
          maxLength: 3,
        ),
      ),
    );

    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Nama wajib diisi'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Rakaa');
    expect(controller.text, 'Rak', reason: 'maxLength stops typing');
  });

  testWidgets('a group title is read apart from its only row', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppListGroup(
          title: 'Tentang',
          children: [
            AppListTile(
              title: 'Tentang CompoundMe',
              value: '1.0.0',
              onTap: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel('Tentang'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('^Tentang CompoundMe')),
      findsOneWidget,
    );
  });

  testWidgets('RowPicker reads label and value and opens on tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(RowPicker(label: 'Tipe', value: 'Bank', onTap: () => taps++)),
    );

    await tester.tap(find.bySemanticsLabel('Tipe, Bank'));
    expect(taps, 1);
  });

  testWidgets('ColorPicker offers the eight presets', (tester) async {
    String? picked;
    await tester.pumpWidget(
      _wrap(
        ColorPicker(
          selectedKey: 'teal',
          onChanged: (key) => picked = key,
          semanticLabel: (color) => color.key,
        ),
      ),
    );

    for (final preset in AppPresetColor.values) {
      expect(find.bySemanticsLabel(preset.key), findsOneWidget);
    }
    await tester.tap(find.bySemanticsLabel('teal'));
    expect(picked, isNull, reason: 'already selected');
    await tester.tap(find.bySemanticsLabel('gold'));
    expect(picked, 'gold');
  });

  testWidgets('SelectableCard is disabled without onTap unless selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Column(
          children: [
            SelectableCard(title: 'Kopi', selected: false, onTap: null),
            SelectableCard(title: 'Teh', selected: true, onTap: null),
          ],
        ),
      ),
    );

    final opacities = tester
        .widgetList<Opacity>(
          find.ancestor(
            of: find.byType(Material),
            matching: find.byType(Opacity),
          ),
        )
        .map((o) => o.opacity)
        .toList();
    expect(opacities, [AppOpacity.disabled, 1]);
  });

  testWidgets('PageIndicator and CoachMark', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            const PageIndicator(
              count: 3,
              index: 1,
              semanticLabel: 'Halaman 2 dari 3',
            ),
            CoachMark(
              message: 'Catat di sini',
              dismissLabel: 'Mengerti',
              onDismiss: () => dismissed = true,
            ),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel('Halaman 2 dari 3'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    expect(dismissed, isTrue);
  });

  testWidgets('DestructiveButton and IconButtonTonal act on tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            DestructiveButton(label: 'Hapus', onPressed: () => taps++),
            IconButtonTonal(
              icon: AppIcons.plus,
              label: 'Tambah',
              onPressed: () => taps++,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Hapus'));
    await tester.tap(find.bySemanticsLabel('Tambah'));
    expect(taps, 2);
  });

  group('sheets', () {
    testWidgets('amount sheet returns the typed amount', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _SheetHost<int>(
            (context) => showAmountSheet(
              context,
              title: 'Saldo awal',
              initial: 0,
              saveLabel: 'Simpan',
              backspaceLabel: 'Hapus',
            ),
          ),
        ),
      );
      await tester.tap(find.text('open null'));
      await tester.pumpAndSettle();
      for (final key in ['5', '000']) {
        await tester.tap(find.bySemanticsLabel(key));
        await tester.pump();
      }
      expect(find.text('5.000'), findsOneWidget);
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('open 5000'), findsOneWidget);
    });

    testWidgets('option sheet returns the chosen value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _SheetHost<String>(
            (context) => showOptionSheet(
              context,
              title: 'Tipe',
              selected: 'cash',
              options: const [
                SheetOption(value: 'cash', label: 'Tunai'),
                SheetOption(value: 'bank', label: 'Bank'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('open null'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();

      expect(find.text('open bank'), findsOneWidget);
    });

    testWidgets('icon picker lists every curated icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _SheetHost<String>(
            (context) => showIconPickerSheet(
              context,
              title: 'Ikon',
              selectedKey: 'wallet',
              colorKey: 'teal',
              semanticLabel: (position, total) => 'Ikon $position/$total',
            ),
          ),
        ),
      );
      await tester.tap(find.text('open null'));
      await tester.pumpAndSettle();
      final total = AppIcons.byKey.length;
      expect(total, 48);
      await tester.tap(find.bySemanticsLabel('Ikon 2/$total'));
      await tester.pumpAndSettle();

      expect(find.text('open ${AppIcons.byKey.keys.elementAt(1)}'), findsOne);
    });
  });

  group('AsyncBody', () {
    const labels = (title: 'Gagal', message: 'Coba lagi nanti', retry: 'Ulang');

    testWidgets('waits before showing a skeleton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AsyncBody<int>(
            value: const AsyncLoading(),
            data: (value) => Text('$value'),
            errorLabels: labels,
            onRetry: () {},
          ),
        ),
      );

      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(AppDurations.skeletonDelay);
      expect(find.byType(SkeletonList), findsOneWidget);
    });

    testWidgets('shows data and errors with a retry', (tester) async {
      var retries = 0;
      Widget body(AsyncValue<int> value) => _wrap(
        AsyncBody<int>(
          value: value,
          data: (value) => Text('data $value'),
          errorLabels: labels,
          onRetry: () => retries++,
        ),
      );

      await tester.pumpWidget(body(const AsyncData(3)));
      expect(find.text('data 3'), findsOneWidget);

      await tester.pumpWidget(
        body(AsyncError(StateError('x'), StackTrace.empty)),
      );
      expect(find.text('Gagal'), findsOneWidget);
      await tester.tap(find.text('Ulang'));
      expect(retries, 1);
    });
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('onboarding art and badges paint in ${mode.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              for (final kind in OnboardingArtKind.values)
                OnboardingArt(kind: kind),
              const IconBadge(iconKey: 'coffee', colorKey: 'gold'),
              const InitialAvatar(name: 'raka'),
            ],
          ),
          mode: mode,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('R'), findsOneWidget);
    });
  }
}
