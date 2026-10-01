import 'dart:async';
import 'dart:developer' as developer;

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_progress.dart';
import 'package:compound_me/features/habits/domain/habit_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-tap check-in for today (Flow C): 0 → 1, any count → 0. A light
/// haptic and "Dicatat · Urungkan" follow a check-in; undoing a check-in
/// offers to bring it back. The repository ignores a second tap while the
/// first is still being written, so fast taps never double-charge.
Future<void> toggleCheckIn(BuildContext context, HabitProgress progress) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final repository = container.read(habitRepositoryProvider);
  final today = LocalDate.fromDateTime(
    container.read(nowProvider.notifier).refresh(),
  );
  final before = progress.todayCount;
  final l10n = context.l10n;
  final failed = l10n.errorSaveFailed;
  final messenger = ScaffoldMessenger.of(context);
  final int after;
  try {
    after = await repository.toggleCheckIn(progress.habit.id, today);
  } on Object catch (error, stackTrace) {
    _log(error, stackTrace);
    messenger.showSnackBar(SnackBar(content: Text(failed)));
    return;
  }
  if (after > 0) unawaited(HapticFeedback.lightImpact());
  if (!context.mounted) return;
  showUndoSnackbar(
    context,
    message: after > 0 ? l10n.habitLogged : l10n.habitUnlogged,
    undoLabel: l10n.undoAction,
    onUndo: () => unawaited(
      _setCount(
        repository,
        progress.habit.id,
        today,
        before,
        messenger,
        failed,
      ),
    ),
  );
}

/// Long-press on a reduce habit (Flow C): a stepper for today's count. It
/// shows the real count even above 10 (a restored expense can push it
/// there), but + stops at 10 (06 §5, phase 1).
Future<void> openCountStepper(
  BuildContext context,
  HabitProgress progress,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final repository = container.read(habitRepositoryProvider);
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final picked = await showAppSheet<int>(
    context,
    builder: (context) =>
        _CountSheet(habit: progress.habit, initial: progress.todayCount),
  );
  if (picked == null || picked == progress.todayCount) return;
  final today = LocalDate.fromDateTime(
    container.read(nowProvider.notifier).refresh(),
  );
  final saved = await _setCount(
    repository,
    progress.habit.id,
    today,
    picked,
    messenger,
    l10n.errorSaveFailed,
  );
  if (saved && picked > progress.todayCount) {
    unawaited(HapticFeedback.lightImpact());
  }
}

Future<bool> _setCount(
  HabitRepository repository,
  String habitId,
  LocalDate date,
  int count,
  ScaffoldMessengerState messenger,
  String failed,
) async {
  try {
    await repository.setCount(habitId, date, count);
    return true;
  } on Object catch (error, stackTrace) {
    _log(error, stackTrace);
    messenger.showSnackBar(SnackBar(content: Text(failed)));
    return false;
  }
}

void _log(Object error, StackTrace stackTrace) => developer.log(
  'Check-in failed',
  name: 'compound_me',
  error: error,
  stackTrace: stackTrace,
);

class _CountSheet extends StatefulWidget {
  const _CountSheet({required this.habit, required this.initial});

  final Habit habit;
  final int initial;

  @override
  State<_CountSheet> createState() => _CountSheetState();
}

class _CountSheetState extends State<_CountSheet> {
  late int _count = widget.initial;

  void _change(int next) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _count = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final cost = widget.habit.costPerOccurrence ?? 0;
    const max = HabitRepository.maxDailyCount;
    return SheetBody(
      title: widget.habit.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.habitCountToday,
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Center(
            child: CountStepper(
              value: '$_count',
              semanticValue: l10n.habitCountValue(_count),
              labels: (
                decrease: l10n.stepperDecrease,
                increase: l10n.stepperIncrease,
              ),
              onDecrease: _count > 0 ? () => _change(_count - 1) : null,
              onIncrease: _count < max ? () => _change(_count + 1) : null,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            l10n.habitCountCost(
              _count,
              formatRupiah(cost),
              formatRupiah(cost * _count),
            ),
            style: AppTextStyles.bodySmall.tabular.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_count >= max) ...[
            const SizedBox(height: AppSpacing.space1),
            Text(
              l10n.habitCountMax(max),
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.space6),
          PrimaryButton(
            label: l10n.actionSave,
            onPressed: () => Navigator.of(context).pop(_count),
          ),
        ],
      ),
    );
  }
}
