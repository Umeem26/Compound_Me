import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/transactions/presentation/add_transaction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
            icon: PhosphorIconsRegular.house,
            activeIcon: PhosphorIconsFill.house,
            label: l10n.navHome,
          ),
          AppBottomNavItem(
            icon: PhosphorIconsRegular.checkCircle,
            activeIcon: PhosphorIconsFill.checkCircle,
            label: l10n.navHabits,
          ),
          AppBottomNavItem(
            icon: PhosphorIconsRegular.chartPieSlice,
            activeIcon: PhosphorIconsFill.chartPieSlice,
            label: l10n.navInsights,
          ),
          AppBottomNavItem(
            icon: PhosphorIconsRegular.user,
            activeIcon: PhosphorIconsFill.user,
            label: l10n.navProfile,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        // Tapping the active tab again returns that tab to its root.
        onSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        addIcon: PhosphorIconsBold.plus,
        addLabel: l10n.navAdd,
        onAdd: () => showAddTransactionSheet(context),
      ),
    );
  }
}
