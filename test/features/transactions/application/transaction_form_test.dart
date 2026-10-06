import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/transactions/application/transaction_form.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DriftTransactionRepository transactions;
  late DriftCategoryRepository categories;
  late DriftWalletRepository wallets;
  late String cash;
  late String bank;
  final now = DateTime(2026, 9, 27, 8, 12);

  setUp(() async {
    db = openTestDatabase();
    clock = FakeClock(DateTime(2026, 9, 27, 7));
    transactions = DriftTransactionRepository(db, clock: clock.call);
    categories = DriftCategoryRepository(db);
    wallets = DriftWalletRepository(db);
    cash = await seedWallet(db);
    bank = await seedWallet(db, name: 'Bank');
  });

  Future<TransactionFormSource> load({TransactionListItem? editing}) =>
      loadTransactionFormSource(
        transactions: transactions,
        categories: categories,
        wallets: wallets,
        now: now,
        editing: editing,
      );

  TransactionDraft expense(String categoryId, String walletId) =>
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: 22000,
        walletId: walletId,
        categoryId: categoryId,
        occurredAt: DateTime(2026, 9, 26, 12),
      );

  group('TransactionForm', () {
    final base = TransactionForm(
      kind: TransactionKind.expense,
      amount: 0,
      categoryId: 'food',
      walletId: 'cash',
      occurredAt: now,
    );

    test('saves only with an amount and a category', () {
      expect(base.canSave, isFalse, reason: 'amount 0');
      expect(base.copyWith(amount: 22000).canSave, isTrue);
      expect(
        base.copyWith(amount: 22000, categoryId: () => null).canSave,
        isFalse,
      );
    });

    test('compares by value, ignoring spaces around the note', () {
      expect(base.copyWith(note: '  '), base);
      expect(base.copyWith(amount: 1), isNot(base));
      expect(base.copyWith(note: ' kopi ').toDraft().note, 'kopi');
      expect(base.copyWith(amount: 1).toDraft().note, isNull);
    });
  });

  group('loadTransactionFormSource', () {
    test('a first transaction starts without a category', () async {
      final source = await load();

      expect(source.initial.kind, TransactionKind.expense);
      expect(source.initial.amount, 0);
      expect(source.initial.categoryId, isNull);
      expect(source.initial.walletId, cash, reason: 'first active wallet');
      expect(source.initial.occurredAt, now);
      expect(
        source.chipsFor(TransactionKind.expense, null),
        hasLength(categoryChipCount),
      );
    });

    test('defaults to the last category of the type and last wallet', () async {
      final food = await defaultCategoryId(db, 'catFood');
      final transport = await defaultCategoryId(db, 'catTransport');
      final salary = await defaultCategoryId(db, 'catAllowance');
      await transactions.add(expense(transport, cash));
      clock.now = DateTime(2026, 9, 27, 7, 30);
      await transactions.add(expense(food, bank));
      clock.now = DateTime(2026, 9, 27, 7, 45);
      await transactions.add(
        TransactionDraft(
          kind: TransactionKind.income,
          amount: 500000,
          walletId: bank,
          categoryId: salary,
          occurredAt: DateTime(2026, 9, 26),
        ),
      );

      final source = await load();

      expect(source.initial.categoryId, food, reason: 'last expense one');
      expect(source.initial.walletId, bank);
      expect(source.defaultCategoryId(TransactionKind.income), salary);
      final chips = source.chipsFor(TransactionKind.expense, food);
      expect(chips.take(2).map((c) => c.id), [food, transport]);
      expect(chips, hasLength(categoryChipCount));
    });

    test('a category picked from the full list takes the first chip', () async {
      final source = await load();
      final all = source.categories[TransactionKind.expense]!;
      final chips = source.chipsFor(TransactionKind.expense, null);
      final hidden = all.firstWhere((c) => !chips.contains(c));

      final withPick = source.chipsFor(TransactionKind.expense, hidden.id);
      expect(withPick.first, hidden);
      expect(withPick, hasLength(categoryChipCount));
    });

    test('editing keeps an archived category and wallet', () async {
      final food = await defaultCategoryId(db, 'catFood');
      final id = await transactions.add(expense(food, bank));
      await categories.archive(food);
      await wallets.archive(bank);
      final item =
          (await transactions.watchItems(const TransactionFilter()).first)
              .single;

      final source = await load(editing: item);

      expect(source.initial, TransactionForm.fromEntry(item.entry));
      expect(source.initial.amount, 22000);
      expect(
        source.categories[TransactionKind.expense]!.map((c) => c.id),
        contains(food),
      );
      expect(source.wallets.map((w) => w.id), containsAll([cash, bank]));
      expect(
        source.chipsFor(TransactionKind.expense, food).first.id,
        food,
        reason: 'the archived category still shows as selected',
      );
      expect(id, item.entry.id);
    });
  });
}
