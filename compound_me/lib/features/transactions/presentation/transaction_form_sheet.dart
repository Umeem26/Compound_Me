import 'dart:async';
import 'dart:developer' as developer;

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/transactions/application/transaction_form.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/domain/transaction_repository.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Note length the repository accepts.
const _noteMaxLength = 120;

/// A save the snackbar can undo: an added transaction is deleted again,
/// an edited one gets its previous values back.
typedef _Saved = ({String id, TransactionDraft? previous});

/// Opens the transaction form (S-11) for a new transaction, or for
/// [editing]. After a save, "Tersimpan · Urungkan" shows on [context]'s
/// scaffold, so pass a context that outlives the sheet.
Future<void> openTransactionForm(
  BuildContext context, {
  TransactionListItem? editing,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final transactions = container.read(transactionRepositoryProvider);
  final source = await loadTransactionFormSource(
    transactions: transactions,
    categories: container.read(categoryRepositoryProvider),
    wallets: container.read(walletRepositoryProvider),
    // A fresh read, so the time is now and "today" moves on if needed.
    now: container.read(nowProvider.notifier).refresh(),
    editing: editing,
  );
  if (!context.mounted) return;
  final saved = await showAppSheet<_Saved>(
    context,
    // The form guards unsaved input; a drag would close it unasked.
    enableDrag: false,
    builder: (context) =>
        TransactionFormSheet(source: source, editing: editing),
  );
  if (saved == null || !context.mounted) return;
  final l10n = context.l10n;
  showUndoSnackbar(
    context,
    message: l10n.txSaved,
    undoLabel: l10n.undoAction,
    onUndo: () => unawaited(_undo(transactions, saved)),
  );
}

Future<void> _undo(TransactionRepository transactions, _Saved saved) {
  final previous = saved.previous;
  return previous == null
      ? transactions.softDelete(saved.id)
      : transactions.update(saved.id, previous);
}

/// S-11: type, amount on the custom keypad, category chips, wallet, date
/// and note. A check-in expense keeps its type and day so the habit log
/// stays linked (03 S-11).
class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({required this.source, this.editing, super.key});

  final TransactionFormSource source;
  final TransactionListItem? editing;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  late TransactionForm _form = widget.source.initial;

  /// Category chosen per type, so switching back and forth keeps it.
  late final Map<TransactionKind, String?> _categoryByKind = {
    for (final kind in TransactionKind.values)
      kind: kind == _form.kind
          ? _form.categoryId
          : widget.source.defaultCategoryId(kind),
  };
  late final TextEditingController _note = TextEditingController(
    text: _form.note,
  );
  bool _editingNote = false;
  bool _keyboardSeen = false;
  bool _saving = false;
  bool _failed = false;

  bool get _isEdit => widget.editing != null;
  bool get _fromHabit => widget.editing?.entry.isFromHabit ?? false;
  bool get _hasChanges => _form != widget.source.initial;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _update(TransactionForm next) => setState(() {
    _form = next;
    _failed = false;
  });

  void _setKind(TransactionKind kind) {
    if (kind == _form.kind) return;
    _categoryByKind[_form.kind] = _form.categoryId;
    _update(
      _form.copyWith(kind: kind, categoryId: () => _categoryByKind[kind]),
    );
  }

  void _setCategory(String id) {
    _categoryByKind[_form.kind] = id;
    _update(_form.copyWith(categoryId: () => id));
  }

  Future<void> _pickCategory() async {
    final l10n = context.l10n;
    final picked = await showOptionSheet<String?>(
      context,
      title: l10n.txCategoryPickerTitle,
      selected: _form.categoryId,
      options: [
        for (final category in widget.source.categories[_form.kind]!)
          SheetOption(
            value: category.id,
            label: categoryName(l10n, category),
            leading: IconBadge(
              iconKey: category.iconKey,
              colorKey: category.colorKey,
            ),
          ),
      ],
    );
    if (picked != null) _setCategory(picked);
  }

  Future<void> _pickWallet() async {
    final picked = await showOptionSheet<String?>(
      context,
      title: context.l10n.txWalletPickerTitle,
      selected: _form.walletId,
      options: [
        for (final wallet in widget.source.wallets)
          SheetOption(
            value: wallet.id,
            label: wallet.name,
            leading: IconBadge(
              iconKey: wallet.iconKey,
              colorKey: wallet.colorKey,
            ),
          ),
      ],
    );
    if (picked != null) _update(_form.copyWith(walletId: picked));
  }

  Future<void> _pickDate() async {
    final now = ref.read(nowProvider);
    final current = _form.occurredAt;
    final day = await showDateSheet(
      context,
      title: context.l10n.txDatePickerTitle,
      initial: current.isAfter(now) ? now : current,
      first: DateTime(2000),
      last: now,
    );
    if (day == null) return;
    // Keeps the time of day; only the day changes.
    _update(
      _form.copyWith(
        occurredAt: DateTime(
          day.year,
          day.month,
          day.day,
          current.hour,
          current.minute,
          current.second,
        ),
      ),
    );
  }

  void _closeNote() {
    if (!_editingNote) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _editingNote = false;
      _keyboardSeen = false;
    });
  }

  Future<void> _save() async {
    final editing = widget.editing;
    final transactions = ref.read(transactionRepositoryProvider);
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final draft = _form.toDraft();
      final _Saved saved;
      if (editing == null) {
        saved = (id: await transactions.add(draft), previous: null);
      } else {
        await transactions.update(editing.entry.id, draft);
        saved = (
          id: editing.entry.id,
          previous: TransactionForm.fromEntry(editing.entry).toDraft(),
        );
      }
      if (mounted) Navigator.of(context).pop(saved);
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to save a transaction',
        name: 'compound_me',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
    }
  }

  /// Back from the system keyboard leaves note editing too, so the keypad
  /// returns instead of an empty gap.
  void _watchKeyboard(BuildContext context) {
    if (!_editingNote) return;
    final open = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (open) {
      _keyboardSeen = true;
    } else if (_keyboardSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _closeNote();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    _watchKeyboard(context);
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    return UnsavedChangesGuard(
      hasChanges: _hasChanges && !_saving,
      labels: l10n.discardLabels,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: _isEdit ? l10n.txEditTitle : l10n.txAddTitle,
            closeLabel: l10n.actionClose,
            // While the note takes the keyboard, the amount moves up here
            // whole instead of scrolling half out of view.
            subtitle: _editingNote
                ? GestureDetector(
                    onTap: _closeNote,
                    child: Text(
                      formatRupiah(_form.amount),
                      style: AppTextStyles.titleSmall.tabular.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  )
                : null,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: pad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_fromHabit && !_editingNote)
                    SegmentedToggle<TransactionKind>(
                      options: [
                        SegmentedToggleOption(
                          value: TransactionKind.expense,
                          label: l10n.txKindExpense,
                        ),
                        SegmentedToggleOption(
                          value: TransactionKind.income,
                          label: l10n.txKindIncome,
                        ),
                      ],
                      selected: _form.kind,
                      onChanged: _setKind,
                    ),
                  if (!_editingNote) ...[
                    const SizedBox(height: AppSpacing.space2),
                    AmountDisplay(amount: _form.amount),
                  ],
                  const SizedBox(height: AppSpacing.space2),
                  _CategoryChips(
                    chips: widget.source.chipsFor(_form.kind, _form.categoryId),
                    selectedId: _form.categoryId,
                    onSelected: _setCategory,
                    onMore: _pickCategory,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  const Divider(height: 0),
                  RowPicker(
                    flat: true,
                    leading: const _RowIcon(AppIcons.wallet),
                    label: l10n.txWallet,
                    value: _walletName(),
                    onTap: _pickWallet,
                  ),
                  const Divider(height: 0),
                  RowPicker(
                    flat: true,
                    leading: const _RowIcon(AppIcons.calendarBlank),
                    label: l10n.txDate,
                    value: l10n.dayAndTime(
                      _form.occurredAt,
                      LocalDate.fromDateTime(ref.watch(nowProvider)),
                    ),
                    onTap: _fromHabit ? null : _pickDate,
                  ),
                  const Divider(height: 0),
                  if (_editingNote)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.space3),
                      child: AppTextField(
                        label: l10n.txNote,
                        controller: _note,
                        autofocus: true,
                        maxLength: _noteMaxLength,
                        hintText: l10n.txNoteHint,
                        onChanged: (text) =>
                            _update(_form.copyWith(note: text)),
                        onSubmitted: (_) => _closeNote(),
                      ),
                    )
                  else
                    RowPicker(
                      flat: true,
                      leading: const _RowIcon(AppIcons.notePencil),
                      label: l10n.txNote,
                      value: _form.note.trim().isEmpty
                          ? l10n.txNoteAdd
                          : _form.note.trim(),
                      valueMuted: _form.note.trim().isEmpty,
                      onTap: () => setState(() => _editingNote = true),
                    ),
                  const SizedBox(height: AppSpacing.space2),
                ],
              ),
            ),
          ),
          Padding(
            padding: pad.copyWith(bottom: AppSpacing.space4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_editingNote) ...[
                  const SizedBox(height: AppSpacing.space2),
                  AmountKeypad(
                    amount: _form.amount,
                    onChanged: (amount) =>
                        _update(_form.copyWith(amount: amount)),
                    backspaceLabel: l10n.keypadBackspace,
                  ),
                ],
                if (_failed) ...[
                  const SizedBox(height: AppSpacing.space2),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.errorSaveFailed,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.space3),
                PrimaryButton(
                  label: _isEdit ? l10n.txSaveChanges : l10n.actionSave,
                  loading: _saving,
                  onPressed: _form.canSave && !_saving ? _save : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _walletName() {
    for (final wallet in widget.source.wallets) {
      if (wallet.id == _form.walletId) return wallet.name;
    }
    return '';
  }
}

class _RowIcon extends StatelessWidget {
  const _RowIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: AppSizes.iconSm,
    color: context.tokens.colors.textSecondary,
  );
}

/// Up to six category chips plus "Semua ›" for the full list (§7.5).
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.chips,
    required this.selectedId,
    required this.onSelected,
    required this.onMore,
  });

  final List<Category> chips;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.space2,
      children: [
        for (final category in chips)
          AppChip(
            label: categoryName(l10n, category),
            selected: category.id == selectedId,
            leading: PresetIcon(
              iconKey: category.iconKey,
              colorKey: category.colorKey,
            ),
            onTap: () => onSelected(category.id),
          ),
        AppChip(
          label: l10n.txCategoryAll,
          muted: true,
          trailingIcon: AppIcons.caretRight,
          onTap: onMore,
        ),
      ],
    );
  }
}
