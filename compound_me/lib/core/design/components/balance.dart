import 'package:compound_me/core/design/components/async_states.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:flutter/material.dart';

/// What a hidden balance shows instead of the number (PRD US-03.1).
const maskedRupiah = 'Rp ••••••';

/// Text of the balance eye: tooltips for both states and what screen
/// readers hear in place of a hidden amount.
typedef BalanceVisibilityLabels = ({String show, String hide, String hidden});

/// A balance amount that can be hidden. Hidden, it draws [maskedRupiah]
/// and screen readers hear [hiddenLabel], never the number.
class BalanceText extends StatelessWidget {
  const BalanceText({
    required this.amount,
    required this.hidden,
    required this.hiddenLabel,
    required this.style,
    super.key,
  });

  final Money amount;
  final bool hidden;
  final String hiddenLabel;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Semantics(
    label: hidden ? hiddenLabel : formatRupiah(amount),
    excludeSemantics: true,
    child: Text(hidden ? maskedRupiah : formatRupiah(amount), style: style),
  );
}

/// Round tonal eye button that shows or hides balances (§7.2
/// IconButtonTonal: 40 dp circle, 48 dp target).
class BalanceEyeButton extends StatelessWidget {
  const BalanceEyeButton({
    required this.hidden,
    required this.onPressed,
    required this.labels,
    super.key,
  });

  final bool hidden;
  final VoidCallback onPressed;
  final BalanceVisibilityLabels labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: hidden ? labels.show : labels.hide,
      style: IconButton.styleFrom(
        backgroundColor: colors.surfaceMuted,
        foregroundColor: colors.textSecondary,
        fixedSize: const Size.square(AppSizes.iconButtonTonal),
        minimumSize: const Size.square(AppSizes.iconButtonTonal),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      iconSize: AppSizes.iconSm,
      icon: Icon(hidden ? AppIcons.eyeSlash : AppIcons.eye),
    );
  }
}

/// Home balance (§7.3): overline title and the total in the hero style
/// with the eye next to it.
class BalanceHeader extends StatelessWidget {
  const BalanceHeader({
    required this.title,
    required this.balance,
    required this.hidden,
    required this.onToggleHidden,
    required this.labels,
    super.key,
  });

  final String title;

  /// Null while loading: a skeleton shows after 300 ms (§7.6).
  final Money? balance;
  final bool hidden;
  final VoidCallback onToggleHidden;
  final BalanceVisibilityLabels labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final amount = balance;
    final heroStyle = AppTextStyles.amountHero.tabular.copyWith(
      color: colors.textPrimary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.overline.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space1),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                // Scales down rather than cutting off a long total (§4).
                child: amount == null
                    ? DelayedReveal(
                        child: Skeleton(
                          height: MediaQuery.textScalerOf(context)
                              .scale(heroStyle.fontSize!),
                          width: AppSizes.skeletonAmount,
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: BalanceText(
                          amount: amount,
                          hidden: hidden,
                          hiddenLabel: labels.hidden,
                          style: heroStyle,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.space2),
            BalanceEyeButton(
              hidden: hidden,
              onPressed: onToggleHidden,
              labels: labels,
            ),
          ],
        ),
      ],
    );
  }
}

/// Small pill on `surfaceMuted` with a caret that opens a picker, e.g. the
/// month in the summary card header (S-10). The visual pill is smaller
/// than the 48 dp target around it.
class PickerPill extends StatelessWidget {
  const PickerPill({
    required this.label,
    required this.onTap,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.full));
    return Semantics(
      // Its own node, or it merges into a header next to it.
      container: true,
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          child: Center(
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: radius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.space1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space1),
                    Icon(
                      AppIcons.caretDown,
                      size: AppSizes.iconXs,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
