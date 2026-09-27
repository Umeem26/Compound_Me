import 'package:compound_me/core/utils/money.dart';
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

/// History filters (S-13). [month] is a local calendar month; [query]
/// searches notes and custom category names. Default categories have
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
}
