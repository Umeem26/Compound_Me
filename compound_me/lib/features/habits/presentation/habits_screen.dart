import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Habits (S-20). The "create habit" action is added with S-21 in phase 4.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        AppLargeTitle(title: l10n.navHabits),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: EmptyState(
              icon: PhosphorIconsRegular.checkCircle,
              title: l10n.habitsEmptyTitle,
              message: l10n.habitsEmptyBody,
            ),
          ),
        ),
      ],
    );
  }
}
