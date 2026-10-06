import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/transactions/domain/day_groups.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter/material.dart';

/// One day of transactions (S-10, S-13): its header with the subtotal,
/// then the rows on one card. [onDelete] turns on swipe-left to delete.
class TransactionDaySection extends StatelessWidget {
  const TransactionDaySection({
    required this.group,
    required this.today,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final DayGroup group;
  final LocalDate today;
  final ValueChanged<TransactionListItem> onTap;

  /// Returns whether the row was deleted; false puts it back.
  final Future<bool> Function(TransactionListItem item)? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DayHeader(
            label: l10n.dayLabel(group.day, today),
            subtotal: group.net,
          ),
          TileGroup(
            children: [for (final item in group.items) _row(context, item)],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, TransactionListItem item) {
    final tile = TransactionItemTile(item: item, onTap: () => onTap(item));
    final delete = onDelete;
    if (delete == null) return tile;
    final colors = context.tokens.colors;
    return Dismissible(
      key: ValueKey(item.entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => delete(item),
      background: ColoredBox(
        color: colors.danger,
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.space6),
            child: Icon(AppIcons.trash, color: colors.onDanger),
          ),
        ),
      ),
      child: tile,
    );
  }
}

/// [TransactionTile] for a list item: category, note · wallet · habit tag,
/// signed amount and time.
class TransactionItemTile extends StatelessWidget {
  const TransactionItemTile({required this.item, this.onTap, super.key});

  final TransactionListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entry = item.entry;
    return TransactionTile(
      iconKey: item.category.iconKey,
      colorKey: item.category.colorKey,
      title: categoryName(l10n, item.category),
      subtitle: [
        ?entry.note,
        item.walletName,
        if (entry.isFromHabit) l10n.txHabitTag,
      ].join(' · '),
      amount: entry.signedAmount,
      time: l10n.timeOfDay(entry.occurredAt),
      onTap: onTap,
    );
  }
}
