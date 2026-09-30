import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/habits/presentation/habit_actions.dart';
import 'package:compound_me/features/habits/presentation/habit_editor_screen.dart';
import 'package:compound_me/features/habits/presentation/habit_labels.dart';
import 'package:compound_me/features/habits/presentation/habit_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Kebiasaan hari ini" on Home (S-10): today's scheduled habits as
/// HabitChips, open ones first. Tap checks in, long-press sets a reduce
/// habit's count. Without any habit, a small card invites the first one.
class HomeHabitStrip extends ConsumerWidget {
  const HomeHabitStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final all = ref.watch(habitProgressProvider).value;
    if (all == null) return const SizedBox.shrink();
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    final active = [
      for (final p in all)
        if (!p.habit.isArchived) p,
    ];
    if (active.isEmpty) {
      return Padding(
        padding: pad,
        child: AppCard(
          onTap: () => unawaited(openHabitEditor(context)),
          child: Row(
            children: [
              Icon(AppIcons.plus, color: colors.primary),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  l10n.homeHabitsFirst,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Icon(
                AppIcons.caretRight,
                size: AppSizes.iconSm,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      );
    }
    final strip = todayStrip(active);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: pad,
          child: SectionHeader(
            title: l10n.homeHabitsTitle,
            actionLabel: l10n.homeHabitsAll,
            onAction: () => context.go(AppRoutes.habits),
          ),
        ),
        if (strip.isEmpty)
          Padding(
            padding: pad,
            child: Text(
              l10n.habitsNoneToday,
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: pad,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final p in strip) _Chip(progress: p)],
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.progress});

  final HabitProgress progress;

  @override
  Widget build(BuildContext context) {
    final habit = progress.habit;
    final reduce = habit.kind == HabitKind.reduce;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.space2),
      child: HabitChip(
        iconKey: habit.iconKey,
        colorKey: habit.colorKey,
        label: habit.name,
        semanticLabel: checkInSemantics(context.l10n, progress),
        progress: progress.ringProgress,
        done: !reduce && progress.doneToday,
        badge: reduce ? progress.todayCount : null,
        onTap: () => unawaited(toggleCheckIn(context, progress)),
        onLongPress: reduce
            ? () => unawaited(openCountStepper(context, progress))
            : null,
      ),
    );
  }
}
