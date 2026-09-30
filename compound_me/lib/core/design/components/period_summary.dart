import 'package:compound_me/core/design/components/app_card.dart';
import 'package:compound_me/core/design/components/async_states.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:flutter/material.dart';

/// Column titles of [PeriodSummaryCard]: Masuk, Keluar, Selisih.
typedef PeriodSummaryLabels = ({String income, String expense, String net});

/// Masuk · Keluar · Selisih of a period in three columns on one card, the
/// same on Home (S-10) and history (S-13). The row never wraps: amounts
/// shrink to fit instead of being cut (§4, 360 dp at text scale 1.3).
class PeriodSummaryCard extends StatelessWidget {
  const PeriodSummaryCard({
    required this.income,
    required this.expense,
    required this.labels,
    this.title,
    this.trailing,
    super.key,
  });

  /// Null while loading; a skeleton shows after 300 ms (§7.6).
  final Money? income;
  final Money? expense;
  final PeriodSummaryLabels labels;

  /// Header text on the left, e.g. "Ringkasan" or "Oktober 2026".
  final String? title;

  /// Header widget on the right, e.g. the month picker pill.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final inAmount = income;
    final outAmount = expense;
    final net = inAmount == null || outAmount == null
        ? null
        : inAmount - outAmount;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space1,
        AppSpacing.space4,
        AppSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    container: true,
                    header: true,
                    child: Text(
                      title ?? '',
                      style: AppTextStyles.label.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cell(
                icon: AppIcons.arrowDownLeft,
                label: labels.income,
                amount: inAmount == null ? null : formatRupiah(inAmount),
                color: colors.income,
              ),
              const SizedBox(width: AppSpacing.space3),
              _Cell(
                icon: AppIcons.arrowUpRight,
                label: labels.expense,
                amount: outAmount == null ? null : formatRupiah(outAmount),
                color: colors.textPrimary,
              ),
              const SizedBox(width: AppSpacing.space3),
              _Cell(
                icon: AppIcons.plusMinus,
                label: labels.net,
                amount: net == null ? null : formatRupiah(net, signed: true),
                color: colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String? amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final value = amount;
    final style = AppTextStyles.bodyStrong.tabular.copyWith(color: color);
    return Expanded(
      child: Semantics(
        // One node per figure, read as "Keluar, Rp 52.000".
        container: true,
        label: value == null ? label : '$label, $value',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: AppSizes.iconXs,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.space1),
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            if (value == null)
              DelayedReveal(
                child: Skeleton(
                  height: MediaQuery.textScalerOf(context)
                      .scale(style.fontSize!),
                ),
              )
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, style: style, maxLines: 1),
              ),
          ],
        ),
      ),
    );
  }
}
