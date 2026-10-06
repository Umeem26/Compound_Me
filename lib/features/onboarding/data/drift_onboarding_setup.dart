import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/clock.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_setup.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drift_onboarding_setup.g.dart';

/// Writes the wallet and starter habits in one transaction through the
/// regular repositories, so their validation applies unchanged.
class DriftOnboardingSetup implements OnboardingSetup {
  DriftOnboardingSetup(this._db, {this._clock = systemClock});

  final AppDatabase _db;
  final Clock _clock;

  @override
  Future<String> complete({
    required WalletDraft wallet,
    required List<StarterHabit> habits,
  }) => _db.transaction(() async {
    final walletId = await DriftWalletRepository(
      _db,
      clock: _clock,
    ).create(wallet);
    final habitRepository = DriftHabitRepository(_db, clock: _clock);
    for (final habit in habits) {
      final nameKey = habit.template.categoryNameKey;
      await habitRepository.create(
        habit.template.toDraft(
          name: habit.name,
          cost: habit.cost,
          walletId: walletId,
          categoryId: nameKey == null ? null : await _defaultCategory(nameKey),
        ),
      );
    }
    return walletId;
  });

  Future<String> _defaultCategory(String nameKey) async {
    final row = await (_db.select(
      _db.categories,
    )..where((c) => c.nameKey.equals(nameKey))).getSingleOrNull();
    return row?.id ?? (throw NotFoundException('category', nameKey));
  }
}

@Riverpod(keepAlive: true)
OnboardingSetup onboardingSetup(Ref ref) =>
    DriftOnboardingSetup(ref.watch(appDatabaseProvider));
