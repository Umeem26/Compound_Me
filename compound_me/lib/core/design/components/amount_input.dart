import 'dart:async';

import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/core/utils/spoken_money.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Rp" plus the amount in the hero style, centered (§7.5). Zero shows a
/// muted "0" placeholder.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({required this.amount, super.key});

  final Money amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      liveRegion: true,
      label: context.spokenMoney(amount),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Rp',
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            Text(
              formatAmountDigits(amount),
              style: AppTextStyles.amountHero.copyWith(
                color: amount == 0 ? colors.textTertiary : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3×4 number pad: 1–9, `000`, 0 and backspace (§7.5). Long-pressing
/// backspace clears the amount. Works on whole Rupiah through
/// [keypadAppend] and [keypadBackspace].
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.amount,
    required this.onChanged,
    required this.backspaceLabel,
    super.key,
  });

  final Money amount;
  final ValueChanged<Money> onChanged;

  /// Screen reader label of the backspace key, e.g. "Hapus".
  final String backspaceLabel;

  /// Null is the backspace key.
  static const List<List<String?>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['000', '0', null],
  ];

  void _change(Money next) {
    unawaited(HapticFeedback.selectionClick());
    if (next != amount) onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (rowIndex, row) in _rows.indexed) ...[
          if (rowIndex > 0) const SizedBox(height: AppSpacing.space2),
          Row(
            children: [
              for (final (index, key) in row.indexed) ...[
                if (index > 0) const SizedBox(width: AppSpacing.space2),
                Expanded(
                  child: key == null
                      ? _KeypadKey(
                          semanticLabel: backspaceLabel,
                          onTap: () => _change(keypadBackspace(amount)),
                          onLongPress: () => _change(0),
                          child: const Icon(
                            AppIcons.backspace,
                            size: AppSizes.iconMd,
                          ),
                        )
                      : _KeypadKey(
                          semanticLabel: key,
                          onTap: () => _change(keypadAppend(amount, key)),
                          child: Text(key),
                        ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
    this.onLongPress,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: colors.surfaceMuted,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: SizedBox(
            height: AppSizes.keypadKey,
            child: Center(
              child: DefaultTextStyle(
                style: AppTextStyles.titleMedium.tabular.copyWith(
                  color: colors.textPrimary,
                ),
                child: IconTheme(
                  data: IconThemeData(color: colors.textPrimary),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
