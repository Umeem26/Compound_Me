import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/day_groups.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/month_picker.dart';
import 'package:compound_me/features/transactions/presentation/transaction_day_list.dart';
import 'package:compound_me/features/transactions/presentation/transaction_detail_sheet.dart';
import 'package:compound_me/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:compound_me/features/transactions/presentation/transaction_providers.dart';
import 'package:compound_me/features/wallets/application/balance_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home (S-10): greeting, total balance, the month summary card and the
/// latest transactions per day. The habit strip and the insight card come
/// in phases 4 and 5. Everything follows Drift streams.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Month of the summary; null follows the current month, also across
  /// midnight at the end of a month.
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
    final today = LocalDate.fromDateTime(now);
    final month = _month ?? YearMonth.of(now);
    final hidden = ref.watch(balanceHiddenProvider);
    final balance = ref.watch(totalBalanceProvider);
    final totals = ref
        .watch(
          transactionTotalsProvider(
            TransactionFilter(year: month.year, month: month.month),
          ),
        )
        .value;
    final monthLabel = month.year == now.year
        ? l10n.monthLabel(month.year, month.month, withYear: false)
        : l10n.monthLabel(month.year, month.month);
    final recent = ref.watch(recentTransactionsProvider);
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);

    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: pad.copyWith(top: AppSpacing.space4),
            sliver: SliverToBoxAdapter(
              child: _Greeting(
                date: l10n.longDate(now),
                greeting: l10n.greeting(now, ref.watch(userNameProvider)),
                name: ref.watch(userNameProvider),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: pad.copyWith(top: AppSpacing.space6),
          sliver: SliverToBoxAdapter(
            child: BalanceHeader(
              title: l10n.walletsTotal,
              balance: balance.value,
              hidden: hidden,
              onToggleHidden: ref.read(balanceHiddenProvider.notifier).toggle,
              labels: l10n.balanceVisibilityLabels,
            ),
          ),
        ),
        SliverPadding(
          padding: pad.copyWith(top: AppSpacing.space4),
          sliver: SliverToBoxAdapter(
            child: PeriodSummaryCard(
              title: l10n.summaryTitle,
              income: totals?.income,
              expense: totals?.expense,
              labels: l10n.periodSummaryLabels,
              trailing: PickerPill(
                label: monthLabel,
                semanticLabel: l10n.summaryMonthPicker(monthLabel),
                onTap: () => unawaited(_pickMonth(month)),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: pad.copyWith(top: AppSpacing.space6),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.homeRecentTitle,
              actionLabel: l10n.homeSeeAll,
              onAction: () => unawaited(context.push(AppRoutes.transactions)),
            ),
          ),
        ),
        ...switch (recent) {
          AsyncData(:final value) when value.isEmpty => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyState(
                  icon: AppIcons.receipt,
                  title: l10n.homeEmptyTitle,
                  message: l10n.homeEmptyBody,
                  actionLabel: l10n.homeEmptyAction,
                  onAction: () => unawaited(openTransactionForm(context)),
                ),
              ),
            ),
          ],
          AsyncData(:final value) => [
            SliverPadding(
              padding: pad.copyWith(top: AppSpacing.space2),
              sliver: SliverList.list(
                children: [
                  for (final group in groupByDay(value))
                    TransactionDaySection(
                      group: group,
                      today: today,
                      onTap: (item) =>
                          unawaited(openTransactionDetail(context, item)),
                    ),
                ],
              ),
            ),
          ],
          _ => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: AsyncBody<void>(
                value: recent,
                data: (_) => const SizedBox.shrink(),
                errorLabels: l10n.loadErrorLabels,
                onRetry: () => ref.invalidate(recentTransactionsProvider),
              ),
            ),
          ],
        },
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
      ],
    );
  }
}

/// "Jumat, 25 September" over "Selamat pagi, Raka", with the avatar that
/// opens Profile.
class _Greeting extends StatelessWidget {
  const _Greeting({
    required this.date,
    required this.greeting,
    required this.name,
  });

  final String date;
  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Semantics(
                header: true,
                child: Text(
                  greeting,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Semantics(
          button: true,
          label: context.l10n.navProfile,
          excludeSemantics: true,
          child: InkResponse(
            onTap: () => context.go(AppRoutes.me),
            radius: AppSizes.minTouchTarget / 2,
            child: SizedBox.square(
              dimension: AppSizes.minTouchTarget,
              child: Center(
                child: InitialAvatar(name: name, size: AppSizes.avatarSmall),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
