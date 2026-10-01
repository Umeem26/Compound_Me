import 'dart:async';
import 'dart:developer' as developer;

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/presentation/habit_providers.dart';
import 'package:compound_me/features/insights/domain/compound_projection.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/insights/presentation/insights_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the habit simulator (S-31) for a reduce habit.
Future<void> showSimulatorSheet(BuildContext context, String habitId) =>
    showAppSheet<void>(
      context,
      builder: (context) => SimulatorSheet(habitId: habitId),
    );

/// "Kalau Kopi dikurangi…" (S-31): cut a reduce habit by 0–100 % and see
/// the yearly savings, optionally saved and grown with compound interest.
/// The disclaimer is pinned under the scrolling part, so it is always in
/// view.
class SimulatorSheet extends ConsumerStatefulWidget {
  const SimulatorSheet({required this.habitId, super.key});

  final String habitId;

  @override
  ConsumerState<SimulatorSheet> createState() => _SimulatorSheetState();
}

class _SimulatorSheetState extends ConsumerState<SimulatorSheet> {
  /// Flow D starts at half.
  static const _initialReduction = 50;
  static const _ratePresets = [0, 3, 5];
  static const _maxRate = 100;

  int _reduction = _initialReduction;
  bool _invest = false;
  final _rate = TextEditingController(text: '0');

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  /// Interest in percent; null when the field isn't a number from 0 to 100.
  double? get _ratePercent {
    final value = double.tryParse(_rate.text.trim().replaceAll(',', '.'));
    if (value == null || value < 0 || value > _maxRate) return null;
    return value;
  }

  Future<void> _setLimit(Habit habit, int limit) async {
    final l10n = context.l10n;
    final repository = ref.read(habitRepositoryProvider);
    final previous = habit.weeklyLimit;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.update(habit.id, _draft(habit, limit));
    } on Object catch (error, stackTrace) {
      developer.log(
        'Setting the weekly limit failed',
        name: 'compound_me',
        error: error,
        stackTrace: stackTrace,
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.simLimitFailed)));
      return;
    }
    if (!mounted) return;
    showUndoSnackbar(
      context,
      message: l10n.simLimitSet(limit),
      undoLabel: l10n.undoAction,
      onUndo: () =>
          unawaited(repository.update(habit.id, _draft(habit, previous))),
    );
    Navigator.of(context).pop();
  }

  HabitDraft _draft(Habit habit, int? weeklyLimit) => HabitDraft(
    name: habit.name,
    kind: habit.kind,
    iconKey: habit.iconKey,
    colorKey: habit.colorKey,
    scheduleType: habit.scheduleType,
    scheduleDays: habit.scheduleDays,
    timesPerWeek: habit.timesPerWeek,
    costPerOccurrence: habit.costPerOccurrence,
    walletId: habit.walletId,
    categoryId: habit.categoryId,
    weeklyLimit: weeklyLimit,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final habit = ref.watch(habitDetailProvider(widget.habitId)).value?.habit;
    final logs = ref.watch(habitLogsProvider(widget.habitId)).value;
    if (habit == null || logs == null) {
      return SheetBody(
        title: l10n.navInsights,
        child: const SizedBox(height: AppSizes.row),
      );
    }

    final today = LocalDate.fromDateTime(ref.watch(nowProvider));
    final cost = habit.costPerOccurrence ?? 0;
    final perWeek = InsightsCalculator.averagePerWeek(logs: logs, today: today);
    final yearly = InsightsCalculator.annualProjection(
      perWeek: perWeek,
      costPerOccurrence: cost,
    );
    final savings = InsightsCalculator.annualSavings(
      annualProjection: yearly,
      reduction: _reduction / 100,
    );
    final limit = (perWeek * (1 - _reduction / 100)).round();
    final rate = _ratePercent;

    return SheetBody(
      title: l10n.simTitle(habit.name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    perWeek == 0
                        ? l10n.simNoPace
                        : l10n.simPace(
                            perWeekText(l10n, perWeek),
                            formatRupiah(cost),
                          ),
                    style: AppTextStyles.bodySmall.tabular.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.simReduceLabel,
                          style: AppTextStyles.label.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        l10n.percentValue(_reduction),
                        style: AppTextStyles.titleSmall.tabular.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  PercentSlider(
                    value: _reduction,
                    valueLabel: l10n.simPercentSpoken,
                    onChanged: (v) {
                      if (v != _reduction) {
                        unawaited(HapticFeedback.selectionClick());
                      }
                      setState(() => _reduction = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    l10n.simSaveLabel,
                    style: AppTextStyles.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.approxAmount(formatRupiah(savings)),
                      style: AppTextStyles.amountHero.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  AppListGroup(
                    children: [
                      AppSwitchTile(
                        title: l10n.simInvestToggle,
                        subtitle: l10n.simInvestHint,
                        value: _invest,
                        onChanged: (v) => setState(() => _invest = v),
                      ),
                    ],
                  ),
                  if (_invest) ...[
                    const SizedBox(height: AppSpacing.space4),
                    _RateField(
                      controller: _rate,
                      invalid: _rate.text.trim().isNotEmpty && rate == null,
                      presets: _ratePresets,
                      selected: rate,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    AppListGroup(
                      children: [
                        for (final years in CompoundProjection.horizons)
                          AppListTile(
                            title: l10n.simHorizon(years),
                            value: formatRupiah(
                              CompoundProjection.projectedSavings(
                                annualSavings: savings,
                                annualRate: (rate ?? 0) / 100,
                                years: years,
                              ),
                            ),
                            showChevron: false,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  AppIcons.info,
                  size: AppSizes.iconXs,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  l10n.simDisclaimer,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (perWeek > 0) ...[
            const SizedBox(height: AppSpacing.space4),
            Text(
              l10n.simLimitHint(limit),
              style: AppTextStyles.bodySmall.tabular.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            SecondaryButton(
              label: l10n.simSetLimit,
              onPressed: () => unawaited(_setLimit(habit, limit)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Interest field with the 0 / 3 / 5 % quick chips.
class _RateField extends StatelessWidget {
  const _RateField({
    required this.controller,
    required this.invalid,
    required this.presets,
    required this.selected,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool invalid;
  final List<int> presets;
  final double? selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.simRateLabel,
          controller: controller,
          errorText: invalid ? l10n.simRateInvalid : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
          ],
          maxLength: 6,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.space2),
        Wrap(
          spacing: AppSpacing.space2,
          children: [
            for (final preset in presets)
              AppChip(
                label: l10n.percentValue(preset),
                selected: selected == preset,
                onTap: () {
                  controller.text = '$preset';
                  onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}
