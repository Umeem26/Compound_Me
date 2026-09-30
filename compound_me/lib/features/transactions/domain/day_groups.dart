import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:meta/meta.dart';

/// Transactions of one local day with the day's subtotal (DayHeader, §7.3).
@immutable
class DayGroup {
  const DayGroup({required this.day, required this.items});

  final LocalDate day;
  final List<TransactionListItem> items;

  /// Income minus expense of the day.
  Money get net => items.fold(0, (sum, item) => sum + item.entry.signedAmount);
}

/// Splits [items], already newest first, into consecutive local days.
List<DayGroup> groupByDay(Iterable<TransactionListItem> items) {
  final groups = <DayGroup>[];
  for (final item in items) {
    final day = LocalDate.fromDateTime(item.entry.occurredAt);
    if (groups.isEmpty || groups.last.day != day) {
      groups.add(DayGroup(day: day, items: [item]));
    } else {
      groups.last.items.add(item);
    }
  }
  return groups;
}

/// Income and expense of [items] that fall in one local month; history
/// sums what its filters show (S-13).
PeriodTotals totalsOfMonth(
  Iterable<TransactionListItem> items,
  int year,
  int month,
) {
  var income = 0;
  var expense = 0;
  for (final item in items) {
    final local = item.entry.occurredAt.toLocal();
    if (local.year != year || local.month != month) continue;
    if (item.entry.kind == TransactionKind.income) {
      income += item.entry.amount;
    } else {
      expense += item.entry.amount;
    }
  }
  return PeriodTotals(income: income, expense: expense);
}
