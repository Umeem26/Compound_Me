import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/transactions/presentation/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Scaffold around the four tab branches with the bottom navigation. Right
/// after onboarding, Home shows a one-time hint on the add button (Flow A).
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showHint =
        navigationShell.currentIndex == 0 &&
        !ref.watch(addCoachMarkSeenProvider);
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          if (showHint)
            Positioned(
              left: AppSpacing.screenHorizontal,
              right: AppSpacing.screenHorizontal,
              bottom: AppSizes.addButtonLift + AppSpacing.space1,
              child: Center(
                child: CoachMark(
                  message: l10n.coachMarkAdd,
                  dismissLabel: l10n.actionGotIt,
                  onDismiss: ref
                      .read(addCoachMarkSeenProvider.notifier)
                      .markSeen,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: [
          AppBottomNavItem(
            icon: AppIcons.house,
            activeIcon: AppIcons.houseFill,
            label: l10n.navHome,
          ),
          AppBottomNavItem(
            icon: AppIcons.checkCircle,
            activeIcon: AppIcons.checkCircleFill,
            label: l10n.navHabits,
          ),
          AppBottomNavItem(
            icon: AppIcons.chartPieSlice,
            activeIcon: AppIcons.chartPieSliceFill,
            label: l10n.navInsights,
          ),
          AppBottomNavItem(
            icon: AppIcons.user,
            activeIcon: AppIcons.userFill,
            label: l10n.navProfile,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        // Tapping the active tab again returns that tab to its root.
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        addIcon: AppIcons.plus,
        addLabel: l10n.navAdd,
        onAdd: () => showAddTransactionSheet(context),
      ),
    );
  }
}
