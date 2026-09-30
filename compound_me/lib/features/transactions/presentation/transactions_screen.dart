import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/presentation/category_providers.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/transactions/domain/day_groups.dart';
import 'package:compound_me/features/transactions/domain/transaction_entry.dart';
import 'package:compound_me/features/transactions/presentation/month_picker.dart';
import 'package:compound_me/features/transactions/presentation/transaction_day_list.dart';
import 'package:compound_me/features/transactions/presentation/transaction_detail_sheet.dart';
import 'package:compound_me/features/transactions/presentation/transaction_form_sheet.dart';
import 'package:compound_me/features/transactions/presentation/transaction_providers.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:compound_me/features/wallets/presentation/wallet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Picker value meaning "no filter", since null means the sheet was
/// dismissed.
const _all = '';

/// Transaction history (S-13): search, month / category / wallet filters,
/// the month's summary and the list per day. Scrolling to the end loads
/// the month before, until the oldest transaction.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({
    this.month,
    this.categoryId,
    this.walletId,
    super.key,
  });

  final YearMonth? month;
  final String? categoryId;
  final String? walletId;

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late YearMonth _month =
      widget.month ?? YearMonth.of(ref.read(clockProvider)());
  late String? _categoryId = widget.categoryId;
  late String? _walletId = widget.walletId;
  final _search = TextEditingController();
  String _query = '';

  /// Months loaded before [_month] so far.
  int _monthsBack = 0;

  /// Whether the oldest transaction's month is loaded.
  bool _reachedStart = false;
  bool _loadingMore = false;

  /// Shown while a changed filter or one more month loads, so the list
  /// doesn't blink.
  List<TransactionListItem>? _lastItems;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _filtered =>
      _categoryId != null || _walletId != null || _query.trim().isNotEmpty;

  /// Any change starts again from the chosen month only.
  void _refilter(VoidCallback change) => setState(() {
    change();
    _monthsBack = 0;
    _reachedStart = false;
  });

  TransactionFilter _filter(List<Category> categories) {
    final text = _query.trim().toLowerCase();
    final l10n = context.l10n;
    return TransactionFilter(
      year: _month.year,
      month: _month.month,
      monthsBack: _monthsBack,
      categoryId: _categoryId,
      walletId: _walletId,
      query: text.isEmpty ? null : text,
      // Default names are translated, not stored, so SQL can't match them.
      extraCategoryIds: text.isEmpty
          ? const {}
          : {
              for (final c in categories)
                if (c.isDefault &&
                    categoryName(l10n, c).toLowerCase().contains(text))
                  c.id,
            },
    );
  }

  /// Called when the end of the list shows: loads one more month, unless
  /// the oldest transaction is already in.
  Future<void> _loadMore() async {
    if (_loadingMore || _reachedStart) return;
    _loadingMore = true;
    final first = await ref
        .read(transactionRepositoryProvider)
        .firstOccurredAt();
    _loadingMore = false;
    if (!mounted) return;
    final start = _month.addMonths(-_monthsBack);
    setState(() {
      if (first == null || start.compareTo(YearMonth.of(first)) <= 0) {
        _reachedStart = true;
      } else {
        _monthsBack++;
      }
    });
  }

  Future<void> _pickMonth() async {
    final first = await ref
        .read(transactionRepositoryProvider)
        .firstOccurredAt();
    if (!mounted) return;
    final picked = await showMonthPicker(
      context,
      selected: _month,
      now: ref.read(clockProvider)(),
      firstOccurredAt: first,
    );
    if (picked != null && picked != _month) _refilter(() => _month = picked);
  }

  Future<void> _pickCategory(List<Category> categories) async {
    final l10n = context.l10n;
    final picked = await showOptionSheet<String>(
      context,
      title: l10n.txFilterCategory,
      selected: _categoryId ?? _all,
      options: [
        SheetOption(value: _all, label: l10n.txFilterAllCategories),
        for (final category in categories)
          SheetOption(
            value: category.id,
            label: categoryName(l10n, category),
            leading: IconBadge(
              iconKey: category.iconKey,
              colorKey: category.colorKey,
            ),
          ),
      ],
    );
    if (picked == null) return;
    _refilter(() => _categoryId = picked == _all ? null : picked);
  }

  Future<void> _pickWallet(List<Wallet> wallets) async {
    final l10n = context.l10n;
    final picked = await showOptionSheet<String>(
      context,
      title: l10n.txFilterWallet,
      selected: _walletId ?? _all,
      options: [
        SheetOption(value: _all, label: l10n.txFilterAllWallets),
        for (final wallet in wallets)
          SheetOption(
            value: wallet.id,
            label: wallet.name,
            leading: IconBadge(
              iconKey: wallet.iconKey,
              colorKey: wallet.colorKey,
            ),
          ),
      ],
    );
    if (picked == null) return;
    _refilter(() => _walletId = picked == _all ? null : picked);
  }

  void _clearFilters() {
    _search.clear();
    _refilter(() {
      _categoryId = null;
      _walletId = null;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final categories = [
      ...?ref.watch(categoriesOfKindProvider(CategoryKind.expense)).value,
      ...?ref.watch(categoriesOfKindProvider(CategoryKind.income)).value,
    ];
    final wallets = [
      for (final w
          in ref.watch(activeWalletsProvider).value ?? const <WalletBalance>[])
        w.wallet,
      ...?ref.watch(archivedWalletsProvider).value,
    ];
    final history = ref.watch(transactionHistoryProvider(_filter(categories)));
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);

    String? nameOf<T>(
      List<T> items,
      String? id,
      String Function(T) name,
      String Function(T) idOf,
    ) {
      for (final item in items) {
        if (idOf(item) == id) return name(item);
      }
      return null;
    }

    final categoryLabel = nameOf<Category>(
      categories,
      _categoryId,
      (c) => categoryName(l10n, c),
      (c) => c.id,
    );
    final walletLabel = nameOf<Wallet>(
      wallets,
      _walletId,
      (w) => w.name,
      (w) => w.id,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppLargeTitle(
            title: l10n.transactionsTitle,
            backLabel: l10n.actionBack,
          ),
          SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: AppSearchField(
                controller: _search,
                hintText: l10n.txSearchHint,
                clearLabel: l10n.txSearchClear,
                onChanged: (text) => _refilter(() => _query = text),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: pad,
              child: Row(
                children: [
                  AppChip(
                    label: l10n.monthLabel(_month.year, _month.month),
                    trailingIcon: AppIcons.caretDown,
                    onTap: () => unawaited(_pickMonth()),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  AppChip(
                    label: categoryLabel ?? l10n.txFilterCategory,
                    selected: categoryLabel != null,
                    trailingIcon: AppIcons.caretDown,
                    onTap: () => unawaited(_pickCategory(categories)),
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  AppChip(
                    label: walletLabel ?? l10n.txFilterWallet,
                    selected: walletLabel != null,
                    trailingIcon: AppIcons.caretDown,
                    onTap: () => unawaited(_pickWallet(wallets)),
                  ),
                ],
              ),
            ),
          ),
          ...switch (history.value ?? _lastItems) {
            final items? => _content(
              _lastItems = items,
              now,
              settled: history is AsyncData,
            ),
            null => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AsyncBody<void>(
                  value: history,
                  data: (_) => const SizedBox.shrink(),
                  errorLabels: l10n.loadErrorLabels,
                  onRetry: () => ref.invalidate(transactionHistoryProvider),
                ),
              ),
            ],
          },
        ],
      ),
    );
  }

  /// [settled] is false while a new filter is still loading; the end of
  /// the list only asks for more once the current query has answered.
  List<Widget> _content(
    List<TransactionListItem> items,
    DateTime now, {
    required bool settled,
  }) {
    final l10n = context.l10n;
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    final groups = groupByDay(items);
    final summary = SliverPadding(
      padding: pad.copyWith(top: AppSpacing.space2, bottom: AppSpacing.space4),
      sliver: SliverToBoxAdapter(
        child: _PeriodSummary(
          totals: totalsOfMonth(items, _month.year, _month.month),
        ),
      ),
    );
    if (items.isEmpty && _reachedStart && settled) {
      return [
        summary,
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: _filtered
                ? EmptyState(
                    icon: AppIcons.magnifyingGlass,
                    title: l10n.txNoMatchTitle,
                    message: l10n.txNoMatchBody,
                    actionLabel: l10n.txClearFilters,
                    onAction: _clearFilters,
                  )
                : EmptyState(
                    icon: AppIcons.receipt,
                    title: l10n.homeEmptyTitle,
                    message: l10n.homeEmptyBody,
                    actionLabel: l10n.homeEmptyAction,
                    onAction: () => unawaited(openTransactionForm(context)),
                  ),
          ),
        ),
      ];
    }
    return [
      summary,
      SliverPadding(
        padding: pad,
        sliver: SliverList.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) => TransactionDaySection(
            group: groups[index],
            today: LocalDate.fromDateTime(now),
            onTap: (item) => unawaited(openTransactionDetail(context, item)),
            onDelete: (item) => deleteTransaction(context, item),
          ),
        ),
      ),
      if (!_reachedStart)
        SliverToBoxAdapter(
          child: _LoadMoreTrigger(
            onVisible: settled ? () => unawaited(_loadMore()) : null,
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
    ];
  }
}

/// Masuk · Keluar · Selisih of the chosen month under the current filters.
class _PeriodSummary extends StatelessWidget {
  const _PeriodSummary({required this.totals});

  final PeriodTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    Widget cell(String label, String amount, Color color) => Expanded(
      child: Semantics(
        // One node per figure, read as "Keluar, Rp 52.000".
        container: true,
        label: '$label, $amount',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                amount,
                style: AppTextStyles.bodyStrong.tabular.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
    return AppCard(
      child: Row(
        children: [
          cell(l10n.txIncome, formatRupiah(totals.income), colors.income),
          cell(
            l10n.txExpense,
            formatRupiah(totals.expense),
            colors.textPrimary,
          ),
          cell(
            l10n.txNet,
            formatRupiah(totals.net, signed: true),
            colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

/// Shown after the last loaded month; asks for the month before as soon
/// as it is built, which happens when it scrolls into view (or right away
/// when the list is short).
class _LoadMoreTrigger extends StatefulWidget {
  const _LoadMoreTrigger({required this.onVisible});

  final VoidCallback? onVisible;

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  Widget build(BuildContext context) {
    final onVisible = widget.onVisible;
    if (onVisible != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onVisible();
      });
    }
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.space4),
      child: DelayedReveal(child: SkeletonList(rows: 1)),
    );
  }
}
