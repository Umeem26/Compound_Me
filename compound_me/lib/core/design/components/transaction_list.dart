import 'package:compound_me/core/design/components/pickers.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/core/utils/spoken_money.dart';
import 'package:flutter/material.dart';

/// One transaction row (§7.3): category badge, category name over the
/// note or wallet, and the signed amount over the time. Income is `+` in
/// the income color, expense `−` in the primary text color.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.iconKey,
    required this.colorKey,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    this.onTap,
    super.key,
  });

  final String iconKey;
  final String colorKey;
  final String title;
  final String subtitle;

  /// Signed: positive for income, negative for expense.
  final Money amount;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final money = formatRupiah(amount, signed: true);
    return Semantics(
      button: onTap != null,
      label:
          '$title, ${context.spokenMoney(amount, signed: true)}, '
          '$subtitle, $time',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.transactionTile,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              children: [
                IconBadge(iconKey: iconKey, colorKey: colorKey),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                // At most half the row: a very large amount shrinks rather
                // than pushing the row past the screen (text scale 1.3).
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width / 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          money,
                          style: AppTextStyles.bodyStrong.tabular.copyWith(
                            color: amount > 0
                                ? colors.income
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.caption.tabular.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Hari ini" / "Kemarin" / "Senin, 21 Sep" with the day's subtotal on the
/// right (§7.3).
class DayHeader extends StatelessWidget {
  const DayHeader({required this.label, required this.subtotal, super.key});

  final String label;
  final Money subtotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final style = AppTextStyles.label.copyWith(color: colors.textSecondary);
    final money = formatRupiah(subtotal, signed: true);
    return Semantics(
      header: true,
      label: '$label, ${context.spokenMoney(subtotal, signed: true)}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.space1,
          end: AppSpacing.space1,
          bottom: AppSpacing.space2,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            const SizedBox(width: AppSpacing.space2),
            Text(money, style: style.tabular),
          ],
        ),
      ),
    );
  }
}

/// Section title with an optional text action on the right, e.g.
/// "Transaksi terbaru · Lihat semua" (§7.3).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Flat card holding rows with inset dividers, like one day of
/// transactions.
class TileGroup extends StatelessWidget {
  const TileGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0)
              const Divider(
                indent:
                    AppSpacing.space4 + AppSizes.iconBadge + AppSpacing.space3,
                height: 0,
              ),
            child,
          ],
        ],
      ),
    );
  }
}
