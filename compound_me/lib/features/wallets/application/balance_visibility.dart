import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_visibility.g.dart';

/// Whether balances are hidden right now, on Home (S-10) and Wallets
/// (S-41) alike. Each app launch starts from the "Sembunyikan saldo"
/// setting (S-43); the eye only changes it for this session, never the
/// setting itself.
@Riverpod(keepAlive: true)
class BalanceHidden extends _$BalanceHidden {
  @override
  // Read once: turning the setting on mid-session applies from the next
  // launch, like the setting says.
  bool build() => ref.read(appPreferencesProvider).hideBalanceOnLaunch;

  void toggle() => state = !state;
}
