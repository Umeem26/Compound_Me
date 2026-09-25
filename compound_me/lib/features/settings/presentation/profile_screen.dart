import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Profile (S-40). Lives under settings because 05 §2 has no profile
/// feature folder. Name and wallets are filled in by onboarding (phase 2).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        AppLargeTitle(title: l10n.navProfile),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: EmptyState(
              icon: PhosphorIconsRegular.userCircle,
              title: l10n.profileEmptyTitle,
              message: l10n.profileEmptyBody,
            ),
          ),
        ),
      ],
    );
  }
}
