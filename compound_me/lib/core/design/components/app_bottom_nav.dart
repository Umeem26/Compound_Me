import 'dart:async';

import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Bottom navigation with four tabs and a raised add button in the middle
/// (§7.1). [items] must contain exactly four tabs; the add button sits
/// between the second and third.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    required this.addIcon,
    required this.addLabel,
    required this.onAdd,
    super.key,
  }) : assert(items.length == 4, 'AppBottomNav expects exactly four tabs');

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final IconData addIcon;
  final String addLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    Widget tab(int index) => Expanded(
      child: _NavTab(
        item: items[index],
        selected: index == currentIndex,
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onSelected(index);
        },
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.bottomNavHeight,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                tab(0),
                tab(1),
                Expanded(
                  child: _AddButton(
                    icon: addIcon,
                    label: addLabel,
                    onTap: () {
                      unawaited(HapticFeedback.selectionClick());
                      onAdd();
                    },
                  ),
                ),
                tab(2),
                tab(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final color = selected ? colors.primary : colors.textTertiary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: AppSizes.iconMd,
                color: color,
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                item.label,
                style: AppTextStyles.caption.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -AppSizes.addButtonLift),
        child: Semantics(
          button: true,
          label: label,
          onTap: onTap,
          excludeSemantics: true,
          child: Tooltip(
            message: label,
            excludeFromSemantics: true,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: tokens.floatingShadow,
              ),
              child: Material(
                color: colors.primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  child: SizedBox.square(
                    dimension: AppSizes.addButton,
                    child: Icon(
                      icon,
                      size: AppSizes.iconMd,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
