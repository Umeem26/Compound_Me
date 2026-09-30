import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/habits/domain/habit_templates.dart';
import 'package:compound_me/features/habits/presentation/habit_actions.dart';
import 'package:compound_me/features/habits/presentation/habit_editor_screen.dart';
import 'package:compound_me/features/habits/presentation/habit_labels.dart';
import 'package:compound_me/features/habits/presentation/habit_providers.dart';
import 'package:compound_me/features/habits/presentation/habit_template_card.dart';
import 'package:compound_me/features/habits/presentation/template_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Habits (S-20): today's or all habits, build and reduce apart, one-tap
/// check-in on each row, long-press for a reduce habit's count, and a
/// reorder mode from the ⋯ menu.
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

enum _Filter { today, all }

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  _Filter _filter = _Filter.today;
  bool _reordering = false;
  bool _showArchived = false;

  /// Order after a drag, shown until the stream catches up.
  List<String>? _pendingOrder;

  void _reorder(List<Habit> habits, int from, int to) {
    final ids = [for (final h in habits) h.id];
    ids.insert(to, ids.removeAt(from));
    setState(() => _pendingOrder = ids);
    unawaited(ref.read(habitRepositoryProvider).reorder(ids));
  }

  List<Habit> _ordered(List<Habit> habits) {
    final pending = _pendingOrder;
    if (pending == null) return habits;
    final ids = [for (final h in habits) h.id];
    if (ids.join() == pending.join() || ids.length != pending.length) {
      _pendingOrder = null;
      return habits;
    }
    final byId = {for (final h in habits) h.id: h};
    return [for (final id in pending) ?byId[id]];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = ref.watch(habitProgressProvider);
    return CustomScrollView(
      slivers: [
        AppLargeTitle(
          title: l10n.navHabits,
          actions: _reordering
              ? [
                  TextButton(
                    onPressed: () => setState(() => _reordering = false),
                    child: Text(l10n.habitsReorderDone),
                  ),
                ]
              : [
                  IconButton(
                    onPressed: () => unawaited(openHabitEditor(context)),
                    tooltip: l10n.habitCreate,
                    icon: const Icon(AppIcons.plus),
                  ),
                  PopupMenuButton<void>(
                    tooltip: l10n.habitsMore,
                    icon: const Icon(AppIcons.dotsThree),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => setState(() => _reordering = true),
                        child: Text(l10n.habitsReorder),
                      ),
                    ],
                  ),
                ],
        ),
        ...switch (progress) {
          AsyncData(:final value) => _content(value),
          _ => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AsyncBody<void>(
                value: progress,
                data: (_) => const SizedBox.shrink(),
                errorLabels: l10n.loadErrorLabels,
                onRetry: () => ref.invalidate(habitProgressProvider),
              ),
            ),
          ],
        },
      ],
    );
  }

  List<Widget> _content(List<HabitProgress> all) {
    final l10n = context.l10n;
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    final active = [
      for (final p in all)
        if (!p.habit.isArchived) p,
    ];
    final archived = [
      for (final p in all)
        if (p.habit.isArchived) p,
    ];

    if (active.isEmpty && archived.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmptyState(
                  icon: AppIcons.checkCircle,
                  title: l10n.habitsEmptyTitle,
                  message: l10n.habitsEmptyBody,
                  actionLabel: l10n.habitCreate,
                  onAction: () => unawaited(openHabitEditor(context)),
                ),
                GhostButton(
                  label: l10n.habitFromTemplate,
                  onPressed: () => unawaited(_pickTemplate()),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (_reordering) {
      final habits = _ordered([for (final p in active) p.habit]);
      return [
        SliverPadding(
          padding: pad,
          sliver: SliverReorderableList(
            itemCount: habits.length,
            onReorderItem: (from, to) => _reorder(habits, from, to),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Padding(
                key: ValueKey(habit.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: HabitTile(
                  iconKey: habit.iconKey,
                  colorKey: habit.colorKey,
                  title: habit.name,
                  subtitle: habitKindLabel(l10n, habit.kind),
                  onTap: () {},
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: Semantics(
                      label: l10n.walletsReorder(habit.name),
                      child: SizedBox.square(
                        dimension: AppSizes.minTouchTarget,
                        child: Icon(
                          AppIcons.dotsSixVertical,
                          size: AppSizes.iconSm,
                          color: context.tokens.colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ];
    }

    final shown = _filter == _Filter.today
        ? [
            for (final p in active)
              if (p.scheduledToday) p,
          ]
        : active;
    Widget group(String title, HabitKind kind) {
      final items = [
        for (final p in shown)
          if (p.habit.kind == kind) p,
      ];
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GroupTitle(title),
            for (final p in items) ...[
              const SizedBox(height: AppSpacing.space2),
              HabitProgressTile(progress: p),
            ],
          ],
        ),
      );
    }

    return [
      SliverPadding(
        padding: pad,
        sliver: SliverToBoxAdapter(
          child: SegmentedToggle<_Filter>(
            options: [
              SegmentedToggleOption(
                value: _Filter.today,
                label: l10n.habitsFilterToday,
              ),
              SegmentedToggleOption(
                value: _Filter.all,
                label: l10n.habitsFilterAll,
              ),
            ],
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
      SliverPadding(
        padding: pad,
        sliver: SliverToBoxAdapter(
          child: shown.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space8,
                  ),
                  child: Text(
                    l10n.habitsNoneToday,
                    style: AppTextStyles.body.copyWith(
                      color: context.tokens.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    group(l10n.habitKindBuild, HabitKind.build),
                    group(l10n.habitKindReduce, HabitKind.reduce),
                  ],
                ),
        ),
      ),
      if (_filter == _Filter.all && archived.isNotEmpty)
        SliverPadding(
          padding: pad,
          sliver: SliverToBoxAdapter(
            child: AppListGroup(
              children: [
                AppListTile(
                  title: l10n.walletsArchived(archived.length),
                  showChevron: false,
                  trailing: Icon(
                    _showArchived ? AppIcons.caretUp : AppIcons.caretDown,
                    size: AppSizes.iconSm,
                    color: context.tokens.colors.textTertiary,
                  ),
                  onTap: () => setState(() => _showArchived = !_showArchived),
                ),
                if (_showArchived)
                  for (final p in archived)
                    AppListTile(
                      leading: IconBadge(
                        iconKey: p.habit.iconKey,
                        colorKey: p.habit.colorKey,
                      ),
                      title: p.habit.name,
                      subtitle: habitKindLabel(l10n, p.habit.kind),
                      onTap: () =>
                          unawaited(context.push(AppRoutes.habit(p.habit.id))),
                    ),
              ],
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
    ];
  }

  Future<void> _pickTemplate() async {
    final template = await showHabitTemplateSheet(context);
    if (template == null || !mounted) return;
    await openHabitEditor(
      context,
      seed: HabitEditorSeed.fromTemplate(
        template,
        name: templateName(context.l10n, template),
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      title.toUpperCase(),
      style: AppTextStyles.overline.copyWith(
        color: context.tokens.colors.textSecondary,
      ),
    ),
  );
}

/// A habit row with its check button (S-20): build habits show their
/// streak with the flame, reduce habits their cost and week count against
/// the limit, or an invitation to set a limit (no limit, no streak).
class HabitProgressTile extends StatelessWidget {
  const HabitProgressTile({required this.progress, super.key});

  final HabitProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final habit = progress.habit;
    final reduce = habit.kind == HabitKind.reduce;
    final streak = progress.streak;
    final Widget? detail;
    if (reduce && habit.weeklyLimit == null) {
      detail = _SetLimitLink(habitId: habit.id);
    } else if (reduce) {
      detail = IconLine(
        text: weekCountLabel(l10n, progress),
        color: progress.overWeeklyLimit
            ? colors.danger
            : progress.atWeeklyLimit
            ? colors.warning
            : null,
      );
    } else if (streak != null && streak.current > 0) {
      detail = IconLine(
        icon: AppIcons.flameFill,
        iconColor: colors.accentText,
        text: streakLabel(l10n, streak.current, streak.unit),
      );
    } else {
      detail = null;
    }
    return HabitTile(
      iconKey: habit.iconKey,
      colorKey: habit.colorKey,
      title: habit.name,
      subtitle: reduce
          ? '${costLabel(l10n, habit)} · ${scheduleLabel(l10n, habit)}'
          : scheduleLabel(l10n, habit),
      detail: detail,
      onTap: () => unawaited(context.push(AppRoutes.habit(habit.id))),
      trailing: CheckButton(
        done: progress.doneToday,
        count: reduce ? progress.todayCount : null,
        semanticLabel: checkInSemantics(l10n, progress),
        onTap: () => unawaited(toggleCheckIn(context, progress)),
        onLongPress: reduce
            ? () => unawaited(openCountStepper(context, progress))
            : null,
      ),
    );
  }
}

/// "Atur batas mingguan untuk mulai streak": a reduce habit without a
/// weekly limit has no streak, so this opens its form (S-21).
class _SetLimitLink extends StatelessWidget {
  const _SetLimitLink({required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => unawaited(openHabitEditor(context, habitId: habitId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
          child: IconLine(
            icon: AppIcons.flame,
            text: context.l10n.habitSetLimitCta,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

/// The eight onboarding templates (S-20 "Pilih dari template"), with the
/// same cards; returns the one tapped.
Future<HabitTemplate?> showHabitTemplateSheet(BuildContext context) =>
    showAppSheet<HabitTemplate>(
      context,
      builder: (context) {
        final l10n = context.l10n;
        final colors = context.tokens.colors;
        Widget group(String title, HabitKind kind) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            for (final template in HabitTemplate.values)
              if (template.kind == kind) ...[
                const SizedBox(height: AppSpacing.space2),
                HabitTemplateCard(
                  template: template,
                  onTap: () => Navigator.of(context).pop(template),
                ),
              ],
          ],
        );
        return SheetBody(
          title: l10n.habitTemplatesTitle,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                group(l10n.habitGroupBuild, HabitKind.build),
                const SizedBox(height: AppSpacing.space6),
                group(l10n.habitGroupReduce, HabitKind.reduce),
              ],
            ),
          ),
        );
      },
    );
