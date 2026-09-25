import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/transactions/presentation/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Scaffold around the four tab branches with the bottom navigation.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
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
