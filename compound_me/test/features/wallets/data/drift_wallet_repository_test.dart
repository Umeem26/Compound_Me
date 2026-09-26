import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:compound_me/features/wallets/domain/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

WalletDraft _draft({String name = 'Bank', int initialBalance = 50000}) =>
    WalletDraft(
      name: name,
      type: WalletType.bank,
      iconKey: 'wallet',
      colorKey: 'blue',
      initialBalance: initialBalance,
    );

void main() {
  late AppDatabase db;
  late DriftWalletRepository wallets;
  late DriftTransactionRepository transactions;

  setUp(() {
    db = openTestDatabase();
    wallets = DriftWalletRepository(db);
    transactions = DriftTransactionRepository(db);
  });

  Future<Map<String, int>> balances() async => {
    for (final w in await wallets.watchActiveWithBalance().first)
      w.wallet.id: w.balance,
  };

  TransactionDraft expense(String walletId, String categoryId, int amount) =>
      TransactionDraft(
        kind: TransactionKind.expense,
        amount: amount,
        walletId: walletId,
        categoryId: categoryId,
        occurredAt: DateTime(2026, 9, 27, 8),
      );

  test('balance stays correct through add, edit, delete and undo', () async {
    final cash = await seedWallet(db);
    final bank = await wallets.create(_draft());
    final food = await defaultCategoryId(db, 'catFood');
    final salary = await defaultCategoryId(db, 'catAllowance');

    final id = await transactions.add(expense(cash, food, 22000));
    expect(await balances(), {cash: 78000, bank: 50000});

    await transactions.update(id, expense(cash, food, 30000));
    expect(await balances(), {cash: 70000, bank: 50000}, reason: 'edit');

    await transactions.update(id, expense(bank, food, 30000));
    expect(await balances(), {cash: 100000, bank: 20000}, reason: 'move');

    await transactions.update(
      id,
      TransactionDraft(
        kind: TransactionKind.income,
        amount: 30000,
        walletId: bank,
        categoryId: salary,
        occurredAt: DateTime(2026, 9, 27, 8),
      ),
    );
    expect(await balances(), {cash: 100000, bank: 80000}, reason: 'income');

    await transactions.softDelete(id);
    expect(await balances(), {cash: 100000, bank: 50000}, reason: 'delete');

    await transactions.restore(id);
    expect(await balances(), {cash: 100000, bank: 80000}, reason: 'undo');
  });

  test('balance and total update reactively', () async {
    final cash = await seedWallet(db);
    final food = await defaultCategoryId(db, 'catFood');
    final totals = <int>[];
    final subscription = wallets.watchTotalBalance().listen(totals.add);
    addTearDown(subscription.cancel);

    await pumpEventQueue();
    await transactions.add(expense(cash, food, 25000));
    await pumpEventQueue();

    expect(totals.first, 100000);
    expect(totals.last, 75000);
  });

  test('a wallet with transactions can be archived but not deleted', () async {
    final cash = await seedWallet(db);
    final bank = await wallets.create(_draft());
    final food = await defaultCategoryId(db, 'catFood');
    final id = await transactions.add(expense(bank, food, 10000));
    await transactions.softDelete(id);

    expect(await wallets.isInUse(bank), isTrue, reason: 'deleted tx counts');
    await expectLater(
      wallets.delete(bank),
      throwsA(isA<WalletInUseException>()),
    );

    await wallets.archive(bank);
    expect((await balances()).keys, [cash]);
    expect((await wallets.watchArchived().first).single.id, bank);
    expect(await wallets.watchTotalBalance().first, 100000);

    await wallets.unarchive(bank);
    expect((await balances()).keys, containsAll([cash, bank]));
  });

  test('an unused wallet can be deleted', () async {
    await seedWallet(db);
    final bank = await wallets.create(_draft());

    await wallets.delete(bank);
    expect(await wallets.findById(bank), isNull);
  });

  test('the last active wallet cannot be archived or deleted', () async {
    final cash = await seedWallet(db);
    final bank = await wallets.create(_draft());
    await wallets.archive(bank);

    await expectLater(
      wallets.archive(cash),
      throwsA(isA<LastActiveWalletException>()),
    );
    await expectLater(
      wallets.delete(cash),
      throwsA(isA<LastActiveWalletException>()),
    );
    await wallets.delete(bank);
    expect(await wallets.findById(bank), isNull, reason: 'archived one goes');
  });

  test('validates name and initial balance', () async {
    Future<String> create(WalletDraft draft) => wallets.create(draft);
    Matcher rejects(ValidationError error) => throwsA(
      isA<ValidationException>().having((e) => e.error, 'error', error),
    );

    await expectLater(
      create(_draft(name: '  ')),
      rejects(ValidationError.nameEmpty),
    );
    await expectLater(
      create(_draft(name: 'x' * 31)),
      rejects(ValidationError.nameTooLong),
    );
    await expectLater(
      create(_draft(initialBalance: -1)),
      rejects(ValidationError.amountNegative),
    );
    final id = await create(_draft(name: '  BCA  '));
    expect((await wallets.findById(id))!.name, 'BCA');
  });

  test('update changes the wallet and its balance', () async {
    final cash = await seedWallet(db);
    await wallets.update(cash, _draft(name: 'Dompet', initialBalance: 5000));

    final wallet = (await wallets.watchActiveWithBalance().first).single;
    expect(wallet.wallet.name, 'Dompet');
    expect(wallet.wallet.type, WalletType.bank);
    expect(wallet.balance, 5000);
    await expectLater(
      wallets.update('missing', _draft()),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('new wallets go last and reorder is kept', () async {
    final cash = await seedWallet(db);
    final bank = await wallets.create(_draft());
    final gopay = await wallets.create(_draft(name: 'GoPay'));
    Future<List<String>> order() async => [
      for (final w in await wallets.watchActiveWithBalance().first) w.wallet.id,
    ];

    expect(await order(), [cash, bank, gopay]);
    await wallets.reorder([gopay, cash, bank]);
    expect(await order(), [gopay, cash, bank]);
  });
}
