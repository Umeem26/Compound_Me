import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/transactions/presentation/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Home (S-10). Phase 0 shows the empty state only.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        AppLargeTitle(title: l10n.navHome),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: EmptyState(
              icon: PhosphorIconsRegular.receipt,
              title: l10n.homeEmptyTitle,
              message: l10n.homeEmptyBody,
              actionLabel: l10n.homeEmptyAction,
              onAction: () => showAddTransactionSheet(context),
            ),
          ),
        ),
      ],
    );
  }
}
