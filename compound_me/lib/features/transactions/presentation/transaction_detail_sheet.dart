import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _DetailAction { edit, delete }

/// Opens the transaction detail (S-12). Edit and delete continue from
/// [context] once the sheet has closed, so it must outlive the sheet.
Future<void> openTransactionDetail(
  BuildContext context,
  TransactionListItem item,
) async {
  final action = await showAppSheet<_DetailAction>(
    context,
    builder: (context) => TransactionDetailSheet(item: item),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _DetailAction.edit:
      await openTransactionForm(context, editing: item);
    case _DetailAction.delete:
      await deleteTransaction(context, item);
  }
}

/// Deletes [item] with an undo snackbar instead of a confirmation (03 §4).
/// A check-in expense asks first, because deleting it also undoes that
/// day's check-in (PRD US-05.2). Returns whether it was deleted.
Future<bool> deleteTransaction(
  BuildContext context,
  TransactionListItem item,
) async {
  if (item.entry.isFromHabit) {
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (context) => _HabitDeleteConfirmation(habitName: item.habitName),
    );
    if (confirmed != true || !context.mounted) return false;
  }
  final l10n = context.l10n;
  final transactions = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(transactionRepositoryProvider);
  unawaited(HapticFeedback.mediumImpact());
  await transactions.softDelete(item.entry.id);
  if (context.mounted) {
    showUndoSnackbar(
      context,
      message: l10n.txDeleted,
      undoLabel: l10n.undoAction,
      onUndo: () => unawaited(transactions.restore(item.entry.id)),
    );
  }
  return true;
}

/// S-12: large category icon, the amount, and wallet, date, note and the
/// habit it came from, with Edit and Delete.
class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({required this.item, super.key});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final entry = item.entry;
    final note = entry.note;
    final amount = formatRupiah(entry.signedAmount, signed: true);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.screenHorizontal,
        end: AppSpacing.screenHorizontal,
        bottom: AppSpacing.space6,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: IconBadge(
                iconKey: item.category.iconKey,
                colorKey: item.category.colorKey,
                size: AppSizes.iconBadgeLarge,
                iconSize: AppSizes.iconLg,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            Semantics(
              header: true,
              child: Text(
                amount,
                style: AppTextStyles.titleLarge.tabular.copyWith(
                  color: entry.kind == TransactionKind.income
                      ? colors.income
                      : colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              categoryName(l10n, item.category),
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space6),
            AppListGroup(
              children: [
                AppListTile(title: l10n.txWallet, value: item.walletName),
                AppListTile(
                  title: l10n.txDate,
                  subtitle: l10n.fullDateTime(entry.occurredAt),
                ),
                if (note != null)
                  AppListTile(title: l10n.txNote, subtitle: note),
                if (entry.isFromHabit)
                  AppListTile(
                    leading: Icon(
                      AppIcons.checkCircle,
                      size: AppSizes.iconSm,
                      color: colors.primary,
                    ),
                    title: item.habitName == null
                        ? l10n.txFromHabitUnknown
                        : l10n.txFromHabit(item.habitName!),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space6),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l10n.actionEdit,
                    onPressed: () =>
                        Navigator.of(context).pop(_DetailAction.edit),
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_DetailAction.delete),
                  tooltip: l10n.actionDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.dangerTint,
                    foregroundColor: colors.danger,
                    fixedSize: const Size.square(AppSizes.buttonHeight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  icon: const Icon(AppIcons.trash),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitDeleteConfirmation extends StatelessWidget {
  const _HabitDeleteConfirmation({required this.habitName});

  final String? habitName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    return SheetBody(
      title: l10n.txDeleteHabitTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            habitName == null
                ? l10n.txDeleteHabitBodyUnknown
                : l10n.txDeleteHabitBody(habitName!),
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space6),
          DestructiveButton(
            label: l10n.actionDelete,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.space2),
          GhostButton(
            label: l10n.actionCancel,
            expand: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
