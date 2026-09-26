import 'package:compound_me/core/utils/money.dart';
import 'package:meta/meta.dart';

enum WalletType { cash, bank, ewallet, other }

@immutable
class Wallet {
  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorKey,
    required this.initialBalance,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  final String id;
  final String name;
  final WalletType type;
  final String iconKey;
  final String colorKey;
  final Money initialBalance;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;
}

/// A wallet with its balance computed from transactions, never stored
/// (05 §1: saldo dihitung, tidak disimpan).
@immutable
class WalletBalance {
  const WalletBalance({required this.wallet, required this.balance});

  final Wallet wallet;
  final Money balance;
}

/// Editable fields of a wallet, used for both create and update.
@immutable
class WalletDraft {
  const WalletDraft({
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorKey,
    required this.initialBalance,
  });

  final String name;
  final WalletType type;
  final String iconKey;
  final String colorKey;
  final Money initialBalance;
}
