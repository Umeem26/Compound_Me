import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:meta/meta.dart';

/// `transfer` arrives in v2.1 (F-23).
enum TransactionKind { expense, income }

/// Named "entry" because Drift and `db.transaction` already own the word
/// transaction.
@immutable
class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.kind,
    required this.amount,
    required this.walletId,
    required this.categoryId,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.habitLogId,
    this.deletedAt,
  });

  final String id;
  final TransactionKind kind;

  /// Always positive; the direction comes from [kind].
  final Money amount;
  final String walletId;
  final String categoryId;
  final String? note;

  /// UTC instant.
  final DateTime occurredAt;

  /// Set when the transaction was created by a reduce-habit check-in.
  final String? habitLogId;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Money get signedAmount => kind == TransactionKind.income ? amount : -amount;
  bool get isFromHabit => habitLogId != null;
  bool get isDeleted => deletedAt != null;
}

/// Editable fields of a manual transaction.
@immutable
class TransactionDraft {
  const TransactionDraft({
    required this.kind,
    required this.amount,
    required this.walletId,
    required this.categoryId,
    required this.occurredAt,
    this.note,
  });

  final TransactionKind kind;
  final Money amount;
  final String walletId;
  final String categoryId;
  final DateTime occurredAt;
  final String? note;
}

/// History filters (S-13). [month] is a local calendar month, or every
/// month when [year] and [month] are null; [query] searches notes and
/// custom category names. Default categories have
/// translated names that are not stored, so the UI resolves matching ones
/// and passes them as [extraCategoryIds].
@immutable
class TransactionFilter {
  const TransactionFilter({
    this.year,
    this.month,
    this.categoryId,
    this.walletId,
    this.query,
    this.extraCategoryIds = const {},
  }) : assert(
         (year == null) == (month == null),
         'year and month are set together',
       );

  final int? year;
  final int? month;

  final String? categoryId;
  final String? walletId;
  final String? query;
  final Set<String> extraCategoryIds;

  TransactionFilter copyWith({
    String? Function()? categoryId,
    String? Function()? walletId,
    String? query,
    Set<String>? extraCategoryIds,
  }) => TransactionFilter(
    year: year,
    month: month,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    walletId: walletId == null ? this.walletId : walletId(),
    query: query ?? this.query,
    extraCategoryIds: extraCategoryIds ?? this.extraCategoryIds,
  );

  // Value equality, so a provider family keyed by a filter keeps one
  // stream per distinct filter across rebuilds.
  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.year == year &&
      other.month == month &&
      other.categoryId == categoryId &&
      other.walletId == walletId &&
      other.query == query &&
      other.extraCategoryIds.length == extraCategoryIds.length &&
      other.extraCategoryIds.containsAll(extraCategoryIds);

  @override
  int get hashCode => Object.hash(
    year,
    month,
    categoryId,
    walletId,
    query,
    Object.hashAllUnordered(extraCategoryIds),
  );
}

/// A transaction with what a list row shows next to it (S-10, S-13): its
/// category, wallet name and, for a check-in, the habit's name.
@immutable
class TransactionListItem {
  const TransactionListItem({
    required this.entry,
    required this.category,
    required this.walletName,
    this.habitId,
    this.habitName,
  });

  final TransactionEntry entry;
  final Category category;
  final String walletName;

  /// The habit of a check-in expense, while its log still exists.
  final String? habitId;
  final String? habitName;
}

/// Money in and out of one period; [net] is what is left.
@immutable
class PeriodTotals {
  const PeriodTotals({required this.income, required this.expense});

  static const zero = PeriodTotals(income: 0, expense: 0);

  final Money income;
  final Money expense;

  Money get net => income - expense;
}
