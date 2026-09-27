import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';

String walletTypeLabel(AppLocalizations l10n, WalletType type) =>
    switch (type) {
      WalletType.cash => l10n.walletTypeCash,
      WalletType.bank => l10n.walletTypeBank,
      WalletType.ewallet => l10n.walletTypeEwallet,
      WalletType.other => l10n.walletTypeOther,
    };
