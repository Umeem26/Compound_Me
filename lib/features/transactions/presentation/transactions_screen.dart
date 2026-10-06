import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/clock_provider.dart';
import 'package:compound_me/core/utils/dates.dart';
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

/// Search results load in pages of this size.
const searchPageSize = 50;

/// Transaction history (S-13). Browsing, the month is a strict filter: the
/// list and summary show that month only, and a "Lihat" button for the
/// month before steps back until the oldest transaction. Searching covers
/// every month, loads results in pages, and the summary counts them all.
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
  /// Null follows the current month, also across midnight.
  late YearMonth? _pickedMonth = widget.month;
  late String? _categoryId = widget.categoryId;
  late String? _walletId = widget.walletId;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String _query = '';
  int _limit = searchPageSize;

  /// Shown while a changed filter loads, so the list doesn't blink.
  List<TransactionListItem>? _lastItems;

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool get _searching => _query.trim().isNotEmpty;

  YearMonth get _month => _pickedMonth ?? YearMonth.of(ref.read(nowProvider));

  void _refilter(VoidCallback change) => setState(() {
    change();
    _limit = searchPageSize;
  });

  void _showMonth(YearMonth month) {
    _refilter(() => _pickedMonth = month);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  TransactionFilter _filter(List<Category> categories, YearMonth month) {
    final text = _query.trim().toLowerCase();
    final l10n = context.l10n;
    if (text.isEmpty) {
      return TransactionFilter(
        year: month.year,
        month: month.month,
        categoryId: _categoryId,
        walletId: _walletId,
      );
    }
    return TransactionFilter(
      categoryId: _categoryId,
      walletId: _walletId,
      query: text,
      // Default names are translated, not stored, so SQL can't match them.
      extraCategoryIds: {
        for (final c in categories)
          if (c.isDefault && categoryName(l10n, c).toLowerCase().contains(text))
            c.id,
      },
    );
  }

  Future<void> _pickMonth() async {
    final first = await ref
        .read(transactionRepositoryProvider)
        .firstOccurredAt();
    if (!mounted) return;
    final picked = await showMonthPicker(
      context,
      selected: _month,
      now: ref.read(nowProvider),
      firstOccurredAt: first,
    );
    if (picked != null && picked != _month) _showMonth(picked);
  }

  /// Category name for the filter; a name both kinds use ("Lainnya") gets
  /// its kind, so the two can be told apart.
  String _filterName(Category category, List<Category> all) {
    final l10n = context.l10n;
    final name = categoryName(l10n, category);
    final shared = all.any(
      (c) => c.kind != category.kind && categoryName(l10n, c) == name,
    );
    if (!shared) return name;
    final kind = category.kind == CategoryKind.expense
        ? l10n.txKindExpense
        : l10n.txKindIncome;
    return l10n.txFilterCategoryWithKind(name, kind);
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
            label: _filterName(category, categories),
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
    final now = ref.watch(nowProvider);
    final month = _pickedMonth ?? YearMonth.of(now);
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
    final filter = _filter(categories, month);
    final history = ref.watch(
      transactionHistoryProvider(filter, _searching ? _limit : null),
    );
    final totals = ref.watch(transactionTotalsProvider(filter)).value;
    final oldest = ref.watch(oldestTransactionMonthProvider).value;
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
      (c) => _filterName(c, categories),
      (c) => c.id,
    );
    final walletLabel = nameOf<Wallet>(
      wallets,
      _walletId,
      (w) => w.name,
      (w) => w.id,
    );
    final monthLabel = l10n.monthLabel(month.year, month.month);

    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
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
                    // A search looks through every month.
                    label: _searching ? l10n.txAllMonths : monthLabel,
                    trailingIcon: _searching ? null : AppIcons.caretDown,
                    onTap: _searching ? null : () => unawaited(_pickMonth()),
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
          SliverPadding(
            padding: pad.copyWith(
              top: AppSpacing.space2,
              bottom: AppSpacing.space4,
            ),
            sliver: SliverToBoxAdapter(
              child: PeriodSummaryCard(
                title: _searching ? l10n.txSearchResults : monthLabel,
                income: totals?.income,
                expense: totals?.expense,
                labels: l10n.periodSummaryLabels,
              ),
            ),
          ),
          ...switch (history.value ?? _lastItems) {
            final items? => _content(
              _lastItems = items,
              today: LocalDate.fromDateTime(now),
              month: month,
              oldest: oldest,
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

  /// [settled] is false while a changed filter is still loading.
  List<Widget> _content(
    List<TransactionListItem> items, {
    required LocalDate today,
    required YearMonth month,
    required YearMonth? oldest,
    required bool settled,
  }) {
    final l10n = context.l10n;
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    final previous = month.addMonths(-1);
    final hasPrevious =
        !_searching && oldest != null && previous.compareTo(oldest) >= 0;
    final previousLabel = l10n.txShowMonth(
      l10n.monthLabel(previous.year, previous.month),
    );

    if (items.isEmpty && settled) {
      final Widget empty;
      if (oldest == null && !_searching) {
        empty = EmptyState(
          icon: AppIcons.receipt,
          title: l10n.homeEmptyTitle,
          message: l10n.homeEmptyBody,
          actionLabel: l10n.homeEmptyAction,
          onAction: () => unawaited(openTransactionForm(context)),
        );
      } else if (_searching || _categoryId != null || _walletId != null) {
        empty = EmptyState(
          icon: AppIcons.magnifyingGlass,
          title: l10n.txNoMatchTitle,
          message: l10n.txNoMatchBody,
          actionLabel: l10n.txClearFilters,
          onAction: _clearFilters,
        );
      } else {
        empty = EmptyState(
          icon: AppIcons.calendarBlank,
          title: l10n.txMonthEmptyTitle(
            l10n.monthLabel(month.year, month.month),
          ),
          message: l10n.txMonthEmptyBody,
          actionLabel: hasPrevious ? previousLabel : null,
          onAction: hasPrevious ? () => _showMonth(previous) : null,
        );
      }
      final filtered = _categoryId != null || _walletId != null;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                empty,
                // With a filter, stepping back a month is the second way on.
                if (filtered && hasPrevious)
                  GhostButton(
                    label: previousLabel,
                    onPressed: () => _showMonth(previous),
                  ),
              ],
            ),
          ),
        ),
      ];
    }

    final groups = groupByDay(items);
    return [
      SliverPadding(
        padding: pad,
        sliver: SliverList.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) => TransactionDaySection(
            group: groups[index],
            today: today,
            onTap: (item) => unawaited(openTransactionDetail(context, item)),
            onDelete: (item) => deleteTransaction(context, item),
          ),
        ),
      ),
      if (_searching && items.length >= _limit)
        SliverToBoxAdapter(
          child: _LoadMoreTrigger(
            onVisible: settled
                ? () => setState(() => _limit += searchPageSize)
                : null,
          ),
        ),
      if (hasPrevious)
        SliverPadding(
          padding: pad,
          sliver: SliverToBoxAdapter(
            child: SecondaryButton(
              label: previousLabel,
              onPressed: () => _showMonth(previous),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
    ];
  }
}

/// Shown after the last loaded page of search results; asks for the next
/// page as soon as it is built, which happens when it scrolls into view.
class _LoadMoreTrigger extends StatelessWidget {
  const _LoadMoreTrigger({required this.onVisible});

  final VoidCallback? onVisible;

  @override
  Widget build(BuildContext context) {
    final callback = onVisible;
    if (callback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) callback();
      });
    }
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.space4),
      child: DelayedReveal(child: SkeletonList(rows: 1)),
    );
  }
}
