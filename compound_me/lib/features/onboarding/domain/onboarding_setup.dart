import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit_templates.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:meta/meta.dart';

/// A starter habit as it will be saved: its template, the translated name
/// and, for reduce habits, the cost the user settled on.
@immutable
class StarterHabit {
  const StarterHabit({required this.template, required this.name, this.cost});

  final HabitTemplate template;
  final String name;
  final Money? cost;
}

/// Saves what onboarding collected. Everything is written together or not
/// at all, so a failed save can simply be retried.
abstract interface class OnboardingSetup {
  /// Creates the first wallet and the starter habits; reduce habits log
  /// their expenses to that wallet. Returns the wallet id.
  Future<String> complete({
    required WalletDraft wallet,
    required List<StarterHabit> habits,
  });
}
