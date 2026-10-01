import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/wallets/application/balance_visibility.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:compound_me/features/wallets/presentation/wallet_editor_screen.dart';
import 'package:compound_me/features/wallets/presentation/wallet_labels.dart';
import 'package:compound_me/features/wallets/presentation/wallet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wallets (S-41): total, active wallets with their computed balance in
/// drag-to-sort order, and the archived ones folded away.
class WalletsScreen extends ConsumerStatefulWidget {
  const WalletsScreen({super.key});

  @override
  ConsumerState<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends ConsumerState<WalletsScreen> {
  /// Order after a drag, shown until the database stream catches up so the
  /// row doesn't jump back for a frame.
  List<String>? _pendingOrder;
  bool _showArchived = false;

  Future<void> _open(String? id) async {
    final outcome = await context.push<WalletEditOutcome>(
      id == null ? AppRoutes.walletNew : AppRoutes.wallet(id),
    );
    if (outcome == null || !mounted) return;
    final l10n = context.l10n;
    final repository = ref.read(walletRepositoryProvider);
    showUndoSnackbar(
      context,
      message: switch (outcome.action) {
        WalletEditAction.archived => l10n.walletArchivedDone,
        WalletEditAction.deleted => l10n.walletDeletedDone,
      },
      undoLabel: l10n.undoAction,
      onUndo: () => unawaited(switch (outcome.action) {
        WalletEditAction.archived => repository.unarchive(outcome.wallet.id),
        WalletEditAction.deleted => repository.undoDelete(outcome.wallet),
      }),
    );
  }

  List<WalletBalance> _ordered(List<WalletBalance> wallets) {
    final pending = _pendingOrder;
    if (pending == null) return wallets;
    final ids = [for (final w in wallets) w.wallet.id];
    if (ids.join() == pending.join() || ids.length != pending.length) {
      _pendingOrder = null;
      return wallets;
    }
    final byId = {for (final w in wallets) w.wallet.id: w};
    return [for (final id in pending) ?byId[id]];
  }

  void _reorder(List<WalletBalance> wallets, int from, int to) {
    final ids = [for (final w in wallets) w.wallet.id];
    // onReorderItem already accounts for the removed item in [to].
    ids.insert(to, ids.removeAt(from));
    setState(() => _pendingOrder = ids);
    unawaited(ref.read(walletRepositoryProvider).reorder(ids));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final active = ref.watch(activeWalletsProvider);
    final archived = ref.watch(archivedWalletsProvider).value ?? const [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppLargeTitle(title: l10n.walletsTitle, backLabel: l10n.actionBack),
          if (active case AsyncData(:final value))
            ..._content(_ordered(value), archived)
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: AsyncBody<void>(
                value: active,
                data: (_) => const SizedBox.shrink(),
                errorLabels: l10n.loadErrorLabels,
                onRetry: () => ref.invalidate(activeWalletsProvider),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _content(List<WalletBalance> wallets, List<Wallet> archived) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);
    final total = wallets.fold<Money>(0, (sum, w) => sum + w.balance);
    final hidden = ref.watch(balanceHiddenProvider);
    return [
      SliverPadding(
        padding: pad,
        sliver: SliverToBoxAdapter(
          child: AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.walletsTotal,
                        style: AppTextStyles.overline.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space1),
                      BalanceText(
                        amount: total,
                        hidden: hidden,
                        hiddenLabel: l10n.balanceHidden,
                        style: AppTextStyles.titleLarge.tabular.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                BalanceEyeButton(
                  hidden: hidden,
                  onPressed: ref.read(balanceHiddenProvider.notifier).toggle,
                  labels: l10n.balanceVisibilityLabels,
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
      if (wallets.isEmpty)
        SliverToBoxAdapter(
          child: EmptyState(
            icon: AppIcons.wallet,
            title: l10n.walletsEmptyTitle,
            message: l10n.walletsEmptyBody,
          ),
        )
      else
        SliverPadding(
          padding: pad,
          sliver: SliverReorderableList(
            itemCount: wallets.length,
            onReorderItem: (from, to) => _reorder(wallets, from, to),
            itemBuilder: (context, index) {
              final item = wallets[index];
              return Padding(
                key: ValueKey(item.wallet.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                child: _WalletRow(
                  wallet: item.wallet,
                  balance: item.balance,
                  hidden: hidden,
                  index: index,
                  onTap: () => _open(item.wallet.id),
                ),
              );
            },
          ),
        ),
      SliverPadding(
        padding: pad,
        sliver: SliverToBoxAdapter(
          child: AppListGroup(
            children: [
              AppListTile(
                leading: Icon(
                  AppIcons.plus,
                  size: AppSizes.iconMd,
                  color: colors.primary,
                ),
                title: l10n.walletsAdd,
                onTap: () => _open(null),
                showChevron: false,
              ),
            ],
          ),
        ),
      ),
      if (archived.isNotEmpty) ...[
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space6)),
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
                    color: colors.textTertiary,
                  ),
                  onTap: () => setState(() => _showArchived = !_showArchived),
                ),
                if (_showArchived)
                  for (final wallet in archived)
                    AppListTile(
                      leading: IconBadge(
                        iconKey: wallet.iconKey,
                        colorKey: wallet.colorKey,
                      ),
                      title: wallet.name,
                      subtitle: walletTypeLabel(l10n, wallet.type),
                      showChevron: false,
                      trailing: TextButton(
                        onPressed: () => unawaited(
                          ref
                              .read(walletRepositoryProvider)
                              .unarchive(wallet.id),
                        ),
                        child: Text(l10n.actionRestore),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space8)),
    ];
  }
}

class _WalletRow extends StatelessWidget {
  const _WalletRow({
    required this.wallet,
    required this.balance,
    required this.hidden,
    required this.index,
    required this.onTap,
  });

  final Wallet wallet;
  final Money balance;
  final bool hidden;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.row),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.space4,
              top: AppSpacing.space2,
              bottom: AppSpacing.space2,
            ),
            child: Row(
              children: [
                IconBadge(iconKey: wallet.iconKey, colorKey: wallet.colorKey),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        wallet.name,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        walletTypeLabel(l10n, wallet.type),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                BalanceText(
                  amount: balance,
                  hidden: hidden,
                  hiddenLabel: l10n.balanceHidden,
                  shrinkToFit: true,
                  style: AppTextStyles.bodyStrong.tabular.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Semantics(
                    label: l10n.walletsReorder(wallet.name),
                    child: SizedBox.square(
                      dimension: AppSizes.minTouchTarget,
                      child: Icon(
                        AppIcons.dotsSixVertical,
                        size: AppSizes.iconSm,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
