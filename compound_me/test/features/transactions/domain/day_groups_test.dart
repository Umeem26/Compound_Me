import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/transactions/domain/day_groups.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:flutter_test/flutter_test.dart';

final _food = Category(
  id: 'food',
  kind: CategoryKind.expense,
  nameKey: 'catFood',
  iconKey: 'forkKnife',
  colorKey: 'coral',
  sortOrder: 0,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

TransactionListItem _item(
  String id,
  DateTime localAt,
  int amount, {
  TransactionKind kind = TransactionKind.expense,
}) => TransactionListItem(
  entry: TransactionEntry(
    id: id,
    kind: kind,
    amount: amount,
    walletId: 'cash',
    categoryId: 'food',
    occurredAt: localAt.toUtc(),
    createdAt: localAt.toUtc(),
    updatedAt: localAt.toUtc(),
  ),
  category: _food,
  walletName: 'Tunai',
);

void main() {
  test('groups consecutive local days with their net subtotal', () {
    final groups = groupByDay([
      _item('a', DateTime(2026, 9, 25, 20), 22000),
      _item(
        'b',
        DateTime(2026, 9, 25, 0, 5),
        500000,
        kind: TransactionKind.income,
      ),
      _item('c', DateTime(2026, 9, 24, 23, 59), 25000),
    ]);

    expect(
      [for (final g in groups) g.day],
      [LocalDate(2026, 9, 25), LocalDate(2026, 9, 24)],
    );
    expect([for (final i in groups.first.items) i.entry.id], ['a', 'b']);
    expect(groups.first.net, 478000);
    expect(groups.last.net, -25000);
    expect(groupByDay(const []), isEmpty);
  });

  test('month totals only count the chosen local month', () {
    final totals = totalsOfMonth(
      [
        _item('a', DateTime(2026, 9, 30, 23), 22000),
        _item(
          'b',
          DateTime(2026, 9, 1, 9),
          100000,
          kind: TransactionKind.income,
        ),
        _item('c', DateTime(2026, 8, 31, 23), 9000),
      ],
      2026,
      9,
    );

    expect(totals.income, 100000);
    expect(totals.expense, 22000);
    expect(totals.net, 78000);
  });
}
