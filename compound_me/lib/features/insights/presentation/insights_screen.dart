import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/insights/domain/insights_calculator.dart';
import 'package:compound_me/features/insights/domain/month_insights.dart';
import 'package:compound_me/features/insights/presentation/insights_labels.dart';
import 'package:compound_me/features/insights/presentation/insights_providers.dart';
import 'package:compound_me/features/insights/presentation/simulator_sheet.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/presentation/month_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Compound Insights (S-30): how much of the month's spending comes from
/// reduce habits, what each costs per year, how build habits are doing and
/// where the money goes by category. Waits for a week of data.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  /// Month shown; null follows the current month, also across midnight.
  YearMonth? _month;

  Future<void> _pickMonth(YearMonth current) async {
    final first = await ref
        .read(transactionRepositoryProvider)
        .firstOccurredAt();
    if (!mounted) return;
    final picked = await showMonthPicker(
      context,
      selected: current,
      now: ref.read(nowProvider),
      firstOccurredAt: first,
    );
    if (picked != null && mounted) setState(() => _month = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = ref.watch(nowProvider);
    final month = _month ?? YearMonth.of(now);
    final days = ref.watch(recordedDaysProvider);
    final enough =
        days.value != null && days.value! >= InsightsCalculator.minDays;
    final monthLabel = month.year == now.year
        ? l10n.monthLabel(month.year, month.month, withYear: false)
        : l10n.monthLabel(month.year, month.month);

    return CustomScrollView(
      slivers: [
        AppLargeTitle(
          title: l10n.navInsights,
          actions: [
            if (enough)
              PickerPill(
                label: monthLabel,
                semanticLabel: l10n.summaryMonthPicker(monthLabel),
                onTap: () => unawaited(_pickMonth(month)),
              ),
          ],
        ),
        ...switch (days) {
          AsyncData(:final value) when value < InsightsCalculator.minDays => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: _NotEnoughData(days: value)),
            ),
          ],
          AsyncData() => _MonthSlivers.build(
            context,
            ref,
            month: month,
            monthLabel: monthLabel,
            isCurrent: month == YearMonth.of(now),
          ),
          _ => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AsyncBody<void>(
                value: days,
                data: (_) => const SizedBox.shrink(),
                errorLabels: l10n.loadErrorLabels,
                onRetry: () => ref.invalidate(recordedDaysProvider),
              ),
            ),
          ],
        },
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
      ],
    );
  }
}

/// Fewer than seven days: an explanation and how far along the user is.
class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EmptyState(
          icon: AppIcons.chartPieSlice,
          title: l10n.insightsEmptyTitle,
          message: l10n.insightsEmptyBody,
        ),
        DaysProgress(
          current: days,
          total: InsightsCalculator.minDays,
          label: l10n.insightsDaysProgress(days, InsightsCalculator.minDays),
        ),
      ],
    );
  }
}

/// The slivers of one month, from its [MonthInsights].
abstract final class _MonthSlivers {
  static const _pad = EdgeInsets.symmetric(
    horizontal: AppSpacing.screenHorizontal,
  );

  static List<Widget> build(
    BuildContext context,
    WidgetRef ref, {
    required YearMonth month,
    required String monthLabel,
    required bool isCurrent,
  }) {
    final l10n = context.l10n;
    final insights = ref.watch(monthInsightsProvider(month));
    final data = insights.value;
    if (data == null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AsyncBody<void>(
            value: insights,
            data: (_) => const SizedBox.shrink(),
            errorLabels: l10n.loadErrorLabels,
            onRetry: () => ref.invalidate(monthInsightsProvider(month)),
          ),
        ),
      ];
    }
    final period = isCurrent
        ? l10n.insightsPeriodThis
        : l10n.insightsPeriodIn(monthLabel);
    return [
      SliverPadding(
        padding: _pad,
        sliver: SliverToBoxAdapter(
          child: data.reduce.isEmpty
              ? const _NoReduceCard()
              : _ShareCard(insights: data, period: period),
        ),
      ),
      if (data.reduce.isNotEmpty)
        ..._section(
          title: l10n.insightsReduceSection,
          child: _ReduceList(items: data.reduce),
        ),
      if (data.build.isNotEmpty)
        ..._section(
          title: l10n.insightsBuildSection,
          child: _BuildList(items: data.build),
        ),
      ..._section(
        title: l10n.insightsCategorySection,
        child: data.categories.isEmpty
            ? _Muted(l10n.insightsNoSpending(period))
            : _CategoryBreakdown(insights: data),
      ),
    ];
  }

  static List<Widget> _section({
    required String title,
    required Widget child,
  }) => [
    SliverPadding(
      padding: _pad.copyWith(top: AppSpacing.space6),
      sliver: SliverToBoxAdapter(child: SectionHeader(title: title)),
    ),
    SliverPadding(
      padding: _pad.copyWith(top: AppSpacing.space2),
      sliver: SliverToBoxAdapter(child: child),
    ),
  ];
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.body.copyWith(
      color: context.tokens.colors.textSecondary,
    ),
  );
}

/// "18%" of this month's spending came from reduce habits (US-09.1).
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.insights, required this.period});

  final MonthInsights insights;
  final String period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final share = insights.reduceShare.share;
    if (share == null) {
      return AppCard(child: _Muted(l10n.insightsNoSpending(period)));
    }
    final percent = (share * 100).round();
    return AppCard(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.percentValue(percent),
              style: AppTextStyles.amountHero.tabular.copyWith(
                color: colors.accentText,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              l10n.insightsShareCaption(
                period,
                formatRupiah(insights.reduceShare.reduceAmount),
              ),
              style: AppTextStyles.body.tabular.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            ProportionBar(value: share),
          ],
        ),
      ),
    );
  }
}

/// Shown instead of the share card until a reduce habit exists.
class _NoReduceCard extends StatelessWidget {
  const _NoReduceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.insightsNoReduceTitle,
              style: AppTextStyles.titleSmall.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            l10n.insightsNoReduceBody,
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          SecondaryButton(
            label: l10n.insightsNoReduceAction,
            expand: false,
            onPressed: () => unawaited(context.push(AppRoutes.habitNew)),
          ),
        ],
      ),
    );
  }
}

/// Reduce habits with the month's cost and the yearly projection; a tap
/// opens the simulator (S-31).
class _ReduceList extends StatelessWidget {
  const _ReduceList({required this.items});

  final List<ReduceHabitInsight> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppListGroup(
      children: [
        for (final item in items)
          AppListTile(
            leading: IconBadge(
              iconKey: item.habit.iconKey,
              colorKey: item.habit.colorKey,
            ),
            title: item.habit.name,
            subtitle: l10n.insightsReduceSubtitle(
              perWeekText(l10n, item.perWeek),
              formatRupiah(
                item.annualProjection,
                compact: true,
                localeCode: l10n.localeName,
              ),
            ),
            value: formatRupiah(item.spent),
            onTap: () => unawaited(showSimulatorSheet(context, item.habit.id)),
          ),
      ],
    );
  }
}

/// Build habits with this month's consistency and the change from last
/// month; a tap opens the habit (S-22).
class _BuildList extends StatelessWidget {
  const _BuildList({required this.items});

  final List<BuildHabitInsight> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppListGroup(
      children: [
        for (final item in items)
          AppListTile(
            leading: IconBadge(
              iconKey: item.habit.iconKey,
              colorKey: item.habit.colorKey,
            ),
            title: item.habit.name,
            subtitle: l10n.insightsConsistency,
            value: l10n.percentValue((item.consistency * 100).round()),
            trailing: _trend(l10n, item.trendPoints),
            onTap: () => context.go(AppRoutes.habit(item.habit.id)),
          ),
      ],
    );
  }

  Widget? _trend(AppLocalizations l10n, int? points) {
    if (points == null) return null;
    if (points == 0) {
      return TrendLabel(
        text: l10n.insightsTrendFlat,
        direction: TrendDirection.flat,
        semanticLabel: l10n.insightsTrendFlatSpoken,
      );
    }
    final up = points > 0;
    final size = points.abs();
    return TrendLabel(
      text: l10n.insightsTrendPoints(size),
      direction: up ? TrendDirection.up : TrendDirection.down,
      semanticLabel: up
          ? l10n.insightsTrendUp(size)
          : l10n.insightsTrendDown(size),
    );
  }
}

/// Donut and list of the month's spending per category; both lead to the
/// history filtered by that category (US-09.4).
class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.insights});

  final MonthInsights insights;

  void _open(BuildContext context, CategorySlice slice) => unawaited(
    context.push(
      AppRoutes.insightsTransactions(
        month: insights.month.toIso(),
        category: slice.category.id,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slices = insights.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CategoryDonut(
            slices: [
              for (final s in slices)
                DonutSlice(
                  value: s.amount.toDouble(),
                  color: context.presetColor(s.category.colorKey).foreground,
                ),
            ],
            centerLabel: l10n.insightsDonutCenter,
            centerValue: formatRupiah(
              insights.totalExpense,
              compact: true,
              localeCode: l10n.localeName,
            ),
            onSliceTap: (index) => _open(context, slices[index]),
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        AppListGroup(
          children: [
            for (final slice in slices)
              AppListTile(
                leading: _Dot(color: slice.category.colorKey),
                title: categoryName(l10n, slice.category),
                subtitle: l10n.percentValue((slice.share * 100).round()),
                value: formatRupiah(slice.amount),
                onTap: () => _open(context, slice),
              ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final String color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: AppSizes.legendDot,
      height: AppSizes.legendDot,
      decoration: BoxDecoration(
        color: context.presetColor(color).foreground,
        shape: BoxShape.circle,
      ),
    ),
  );
}
