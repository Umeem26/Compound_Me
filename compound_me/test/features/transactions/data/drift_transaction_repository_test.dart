import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

Matcher _rejects(ValidationError error) =>
    throwsA(isA<ValidationException>().having((e) => e.error, 'error', error));

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late DriftTransactionRepository transactions;
  late String cash;
  late String bank;
  late String food;
  late String transport;
  late String salary;

  setUp(() async {
    db = openTestDatabase();
    clock = FakeClock(DateTime(2026, 9, 27, 9));
    transactions = DriftTransactionRepository(db, clock: clock.call);
    cash = await seedWallet(db);
    bank = await seedWallet(db, name: 'Bank');
    food = await defaultCategoryId(db, 'catFood');
    transport = await defaultCategoryId(db, 'catTransport');
    salary = await defaultCategoryId(db, 'catAllowance');
  });

  TransactionDraft draft({
    int amount = 22000,
    TransactionKind kind = TransactionKind.expense,
    String? walletId,
    String? categoryId,
    String? note,
    DateTime? at,
  }) => TransactionDraft(
    kind: kind,
    amount: amount,
    walletId: walletId ?? cash,
    categoryId: categoryId ?? food,
    note: note,
    occurredAt: at ?? DateTime(2026, 9, 27, 8),
  );

  Future<List<String>> ids(TransactionFilter filter) async => [
    for (final t in await transactions.watch(filter).first) t.id,
  ];

  group('validation', () {
    test(
      'rejects a zero amount, a long note and a mismatched category',
      () async {
        await expectLater(
          transactions.add(draft(amount: 0)),
          _rejects(ValidationError.amountNotPositive),
        );
        await expectLater(
          transactions.add(draft(note: 'x' * 121)),
          _rejects(ValidationError.noteTooLong),
        );
        await expectLater(
          transactions.add(draft(categoryId: salary)),
          _rejects(ValidationError.categoryKindMismatch),
        );
        await expectLater(
          transactions.add(draft(walletId: 'missing')),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test('trims the note and stores an empty one as null', () async {
      final a = await transactions.add(draft(note: '  kopi susu  '));
      final b = await transactions.add(draft(note: '   '));

      expect((await transactions.findById(a))!.note, 'kopi susu');
      expect((await transactions.findById(b))!.note, isNull);
    });

    test('archived wallets and categories cannot be picked again', () async {
      final kept = await transactions.add(draft(walletId: bank));
      await DriftWalletRepository(db).archive(bank);
      await DriftCategoryRepository(db).archive(transport);

      await expectLater(
        transactions.add(draft(walletId: bank)),
        _rejects(ValidationError.archivedReference),
      );
      await expectLater(
        transactions.add(draft(categoryId: transport)),
        _rejects(ValidationError.archivedReference),
      );
      // An existing link to an archived wallet may stay when editing.
      await transactions.update(kept, draft(walletId: bank, amount: 1000));
      expect((await transactions.findById(kept))!.amount, 1000);
    });

    test('stores the occurrence time as UTC', () async {
      final id = await transactions.add(
        draft(at: DateTime(2026, 9, 27, 8, 15, 0, 0, 999)),
      );
      final stored = (await transactions.findById(id))!.occurredAt;

      expect(stored.isUtc, isTrue);
      expect(stored, DateTime(2026, 9, 27, 8, 15).toUtc());
    });
  });

  group('filters', () {
    test('month uses local calendar boundaries', () async {
      final september = await transactions.add(
        draft(at: DateTime(2026, 9, 30, 23, 30)),
      );
      final october = await transactions.add(
        draft(at: DateTime(2026, 10, 1, 0, 30)),
      );

      expect(await ids(const TransactionFilter(year: 2026, month: 9)), [
        september,
      ]);
      expect(await ids(const TransactionFilter(year: 2026, month: 10)), [
        october,
      ]);
    });

    test('category and wallet filters combine', () async {
      final foodCash = await transactions.add(draft());
      await transactions.add(draft(categoryId: transport));
      final foodBank = await transactions.add(draft(walletId: bank));

      expect(
        await ids(TransactionFilter(categoryId: food)),
        unorderedEquals([foodCash, foodBank]),
      );
      expect(await ids(TransactionFilter(categoryId: food, walletId: bank)), [
        foodBank,
      ]);
    });

    test('text searches notes, custom names and translated defaults', () async {
      final categories = DriftCategoryRepository(db);
      final kopi = await categories.create(
        const CategoryDraft(
          kind: CategoryKind.expense,
          name: 'Kopi',
          iconKey: 'gift',
          colorKey: 'rose',
        ),
      );
      final byNote = await transactions.add(draft(note: 'Makan siang KOPI'));
      final byCustom = await transactions.add(draft(categoryId: kopi));
      final byDefault = await transactions.add(draft(categoryId: transport));
      await transactions.add(draft(note: 'bensin'));

      expect(
        await ids(const TransactionFilter(query: 'kopi')),
        unorderedEquals([byNote, byCustom]),
        reason: 'case-insensitive, note or custom category name',
      );
      expect(
        await ids(
          TransactionFilter(query: 'transpor', extraCategoryIds: {transport}),
        ),
        [byDefault],
        reason: 'the UI passes default categories whose name matches',
      );
    });

    test('wildcards in the query are matched literally', () async {
      final percent = await transactions.add(draft(note: 'diskon 50%'));
      await transactions.add(draft(note: 'diskon 500'));

      expect(await ids(const TransactionFilter(query: '50%')), [percent]);
    });

    test('lists newest first and hides deleted ones', () async {
      final older = await transactions.add(draft(at: DateTime(2026, 9, 2)));
      final newer = await transactions.add(draft(at: DateTime(2026, 9, 20)));
      final gone = await transactions.add(draft(at: DateTime(2026, 9, 25)));
      await transactions.softDelete(gone);

      expect(await ids(const TransactionFilter()), [newer, older]);
      final recent = await transactions.watchRecent(limit: 1).first;
      expect(recent.single.id, newer);
    });
  });

  group('delete and undo', () {
    test('soft delete keeps the row until it is restored', () async {
      final id = await transactions.add(draft());

      await transactions.softDelete(id);
      expect((await transactions.findById(id))!.isDeleted, isTrue);
      expect(await ids(const TransactionFilter()), isEmpty);

      await transactions.restore(id);
      expect((await transactions.findById(id))!.isDeleted, isFalse);
      expect(await ids(const TransactionFilter()), [id]);
    });

    test('purge removes only transactions deleted over 30 days ago', () async {
      final old = await transactions.add(draft());
      final recent = await transactions.add(draft());
      final active = await transactions.add(draft());

      clock.now = DateTime(2026, 8, 1, 9);
      await transactions.softDelete(old);
      clock.now = DateTime(2026, 9, 20, 9);
      await transactions.softDelete(recent);
      clock.now = DateTime(2026, 9, 27, 9);

      expect(await transactions.purgeDeleted(), 1);
      expect(await transactions.findById(old), isNull);
      expect(await transactions.findById(recent), isNotNull);
      expect(await transactions.findById(active), isNotNull);
    });

    test('editing a deleted or missing transaction fails', () async {
      final id = await transactions.add(draft());
      await transactions.softDelete(id);

      await expectLater(
        transactions.update(id, draft()),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        transactions.softDelete('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
