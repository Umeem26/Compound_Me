import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/domain/category_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/domain/transaction_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:compound_me/features/wallets/domain/wallet_repository.dart';
import 'package:meta/meta.dart';

/// Categories offered as chips in the form (PRD US-04.1).
const categoryChipCount = 6;

CategoryKind categoryKindOf(TransactionKind kind) => switch (kind) {
  TransactionKind.expense => CategoryKind.expense,
  TransactionKind.income => CategoryKind.income,
};

/// What the transaction form (S-11) edits. [occurredAt] is local time.
@immutable
class TransactionForm {
  const TransactionForm({
    required this.kind,
    required this.amount,
    required this.occurredAt,
    this.categoryId,
    this.walletId,
    this.note = '',
  });

  factory TransactionForm.fromEntry(TransactionEntry entry) => TransactionForm(
    kind: entry.kind,
    amount: entry.amount,
    categoryId: entry.categoryId,
    walletId: entry.walletId,
    occurredAt: entry.occurredAt.toLocal(),
    note: entry.note ?? '',
  );

  final TransactionKind kind;
  final Money amount;
  final String? categoryId;
  final String? walletId;
  final DateTime occurredAt;
  final String note;

  /// Save stays disabled without an amount or a category (03 S-11).
  bool get canSave => amount > 0 && categoryId != null && walletId != null;

  TransactionDraft toDraft() {
    final trimmed = note.trim();
    return TransactionDraft(
      kind: kind,
      amount: amount,
      walletId: walletId!,
      categoryId: categoryId!,
      occurredAt: occurredAt,
      note: trimmed.isEmpty ? null : trimmed,
    );
  }

  TransactionForm copyWith({
    TransactionKind? kind,
    Money? amount,
    String? Function()? categoryId,
    String? walletId,
    DateTime? occurredAt,
    String? note,
  }) => TransactionForm(
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    walletId: walletId ?? this.walletId,
    occurredAt: occurredAt ?? this.occurredAt,
    note: note ?? this.note,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionForm &&
      other.kind == kind &&
      other.amount == amount &&
      other.categoryId == categoryId &&
      other.walletId == walletId &&
      other.occurredAt == occurredAt &&
      other.note.trim() == note.trim();

  @override
  int get hashCode =>
      Object.hash(kind, amount, categoryId, walletId, occurredAt, note.trim());
}

/// Everything the form shows, loaded before it opens so the defaults are
/// there on the first frame.
@immutable
class TransactionFormSource {
  const TransactionFormSource({
    required this.initial,
    required this.categories,
    required this.recentCategoryIds,
    required this.wallets,
  });

  final TransactionForm initial;

  /// Categories to choose from per kind, in display order. When editing,
  /// an archived category or wallet the transaction already uses is
  /// included so it can be kept.
  final Map<TransactionKind, List<Category>> categories;

  /// Most recently used first.
  final Map<TransactionKind, List<String>> recentCategoryIds;
  final List<Wallet> wallets;

  /// The category a new transaction of [kind] starts with: the last one
  /// used for that kind, or none yet.
  String? defaultCategoryId(TransactionKind kind) =>
      recentCategoryIds[kind]!.firstOrNull;

  /// Chips for [kind]: recently used categories first, filled up in display
  /// order. [selectedId] always has a chip, taking the first place when it
  /// was picked from the full list.
  List<Category> chipsFor(TransactionKind kind, String? selectedId) {
    final all = categories[kind]!;
    final byId = {for (final c in all) c.id: c};
    final chips = <Category>[
      for (final id in recentCategoryIds[kind]!) ?byId[id],
    ];
    for (final category in all) {
      if (chips.length >= categoryChipCount) break;
      if (!chips.contains(category) && !category.isArchived) {
        chips.add(category);
      }
    }
    final visible = chips.take(categoryChipCount).toList();
    final selected = byId[selectedId];
    if (selected == null || visible.contains(selected)) return visible;
    return [selected, ...visible.take(categoryChipCount - 1)];
  }
}

/// Loads the form for a new transaction at [now], or for [editing].
Future<TransactionFormSource> loadTransactionFormSource({
  required TransactionRepository transactions,
  required CategoryRepository categories,
  required WalletRepository wallets,
  required DateTime now,
  TransactionListItem? editing,
}) async {
  final entry = editing?.entry;
  final recent = {
    for (final kind in TransactionKind.values)
      kind: await transactions.recentCategoryIds(kind),
  };
  final byKind = <TransactionKind, List<Category>>{
    for (final kind in TransactionKind.values)
      kind: await categories.listActive(categoryKindOf(kind)),
  };
  final kept = editing?.category;
  if (entry != null && kept != null && kept.isArchived) {
    byKind[entry.kind] = [...byKind[entry.kind]!, kept];
  }
  final active = await wallets.listActive();
  if (entry != null && !active.any((w) => w.id == entry.walletId)) {
    final archived = await wallets.findById(entry.walletId);
    if (archived != null) active.add(archived);
  }

  final TransactionForm initial;
  if (entry != null) {
    initial = TransactionForm.fromEntry(entry);
  } else {
    final lastWallet = await transactions.lastUsedWalletId();
    initial = TransactionForm(
      kind: TransactionKind.expense,
      amount: 0,
      categoryId: recent[TransactionKind.expense]!.firstOrNull,
      walletId: lastWallet ?? active.firstOrNull?.id,
      occurredAt: now,
    );
  }
  return TransactionFormSource(
    initial: initial,
    categories: byKind,
    recentCategoryIds: recent,
    wallets: active,
  );
}
