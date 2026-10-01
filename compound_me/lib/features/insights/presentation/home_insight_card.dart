import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/streak_calculator.dart';
import 'package:compound_me/features/insights/domain/home_insight.dart';
import 'package:compound_me/features/insights/presentation/insights_providers.dart';
import 'package:compound_me/features/insights/presentation/simulator_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The one insight card between the habit strip and the latest
/// transactions on Home (S-10). Takes no space while nothing applies.
class HomeInsightCard extends ConsumerWidget {
  const HomeInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(homeInsightProvider).value;
    if (insight == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final (message, action, onTap) = switch (insight) {
      ReduceCostInsight(:final habit, :final spent) => (
        l10n.homeInsightReduce(habit.name, formatRupiah(spent)),
        l10n.homeInsightReduceAction,
        () => unawaited(showSimulatorSheet(context, habit.id)),
      ),
      StreakInsight(:final habit, :final length, :final unit) => (
        unit == StreakUnit.days
            ? l10n.homeInsightStreakDays(habit.name, length)
            : l10n.homeInsightStreakWeeks(habit.name, length),
        l10n.homeInsightStreakAction,
        () => context.go(AppRoutes.habit(habit.id)),
      ),
      SpendingUpInsight(:final percent) => (
        l10n.homeInsightSpending(percent),
        l10n.homeInsightSpendingAction,
        () => context.go(AppRoutes.insights),
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.space6,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: InsightCard(message: message, actionLabel: action, onTap: onTap),
    );
  }
}
