import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/onboarding/data/drift_onboarding_setup.dart';
import 'package:compound_me/features/onboarding/domain/habit_templates.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_setup.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late DriftOnboardingSetup setup;

  const cash = WalletDraft(
    name: 'Tunai',
    type: WalletType.cash,
    iconKey: 'money',
    colorKey: 'teal',
    initialBalance: 50000,
  );

  setUp(() {
    db = openTestDatabase();
    setup = DriftOnboardingSetup(
      db,
      clock: FakeClock(DateTime(2026, 9, 27, 9)).call,
    );
  });

  test('creates the wallet and starter habits linked to it', () async {
    final walletId = await setup.complete(
      wallet: cash,
      habits: const [
        StarterHabit(template: HabitTemplate.read, name: 'Baca 10 halaman'),
        StarterHabit(
          template: HabitTemplate.shortRides,
          name: 'Ojol jarak dekat',
          cost: 18000,
        ),
      ],
    );

    final wallet = await db.select(db.wallets).getSingle();
    expect(wallet.id, walletId);
    expect(wallet.initialBalance, 50000);

    final habits = await db.select(db.habits).get();
    expect(habits.map((h) => h.name), ['Baca 10 halaman', 'Ojol jarak dekat']);
    final ride = habits.last;
    expect(ride.kind, HabitKind.reduce);
    expect(ride.costPerOccurrence, 18000);
    expect(ride.walletId, walletId);
    expect(ride.categoryId, await defaultCategoryId(db, 'catTransport'));
    expect(habits.first.walletId, isNull);
  });

  test('saves nothing when one habit is invalid', () async {
    await expectLater(
      setup.complete(
        wallet: cash,
        habits: const [
          StarterHabit(template: HabitTemplate.read, name: 'Baca'),
          StarterHabit(template: HabitTemplate.cafeCoffee, name: ' '),
        ],
      ),
      throwsA(isA<ValidationException>()),
    );

    expect(await db.select(db.wallets).get(), isEmpty);
    expect(await db.select(db.habits).get(), isEmpty);
  });

  test('works without habits', () async {
    await setup.complete(wallet: cash, habits: const []);

    expect(await db.select(db.wallets).get(), hasLength(1));
    expect(await db.select(db.habits).get(), isEmpty);
  });
}
