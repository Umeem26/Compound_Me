import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/presentation/category_editor_screen.dart';
import 'package:compound_me/features/categories/presentation/category_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Categories (S-42): expense and income lists with their icon and color,
/// an add row and the archived ones folded away.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  CategoryKind _kind = CategoryKind.expense;
  bool _showArchived = false;

  Future<void> _open({String? id}) async {
    final outcome = await context.push<CategoryEditOutcome>(
      id == null ? AppRoutes.categoryNew(_kind.name) : AppRoutes.category(id),
    );
    if (outcome == null || !mounted) return;
    final l10n = context.l10n;
    final repository = ref.read(categoryRepositoryProvider);
    showUndoSnackbar(
      context,
      message: switch (outcome.action) {
        CategoryEditAction.archived => l10n.categoryArchivedDone,
        CategoryEditAction.deleted => l10n.categoryDeletedDone,
      },
      undoLabel: l10n.undoAction,
      onUndo: () => unawaited(switch (outcome.action) {
        CategoryEditAction.archived => repository.unarchive(
          outcome.category.id,
        ),
        CategoryEditAction.deleted => repository.undoDelete(outcome.category),
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = ref.watch(categoriesOfKindProvider(_kind));
    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppLargeTitle(
            title: l10n.categoriesTitle,
            backLabel: l10n.actionBack,
          ),
          SliverPadding(
            padding: pad,
            sliver: SliverToBoxAdapter(
              child: SegmentedToggle<CategoryKind>(
                options: [
                  SegmentedToggleOption(
                    value: CategoryKind.expense,
                    label: l10n.categoryKindExpense,
                  ),
                  SegmentedToggleOption(
                    value: CategoryKind.income,
                    label: l10n.categoryKindIncome,
                  ),
                ],
                selected: _kind,
                onChanged: (kind) => setState(() {
                  _kind = kind;
                  _showArchived = false;
                }),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space4)),
          if (categories case AsyncData(:final value))
            SliverPadding(
              padding: pad,
              sliver: SliverToBoxAdapter(child: _content(value)),
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: AsyncBody<void>(
                value: categories,
                data: (_) => const SizedBox.shrink(),
                errorLabels: l10n.loadErrorLabels,
                onRetry: () => ref.invalidate(categoriesOfKindProvider(_kind)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(List<Category> categories) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final active = [
      for (final c in categories)
        if (!c.isArchived) c,
    ];
    final archived = [
      for (final c in categories)
        if (c.isArchived) c,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (active.isEmpty)
          EmptyState(
            icon: AppIcons.receipt,
            title: l10n.categoriesEmptyTitle,
            message: l10n.categoriesEmptyBody,
          )
        else
          AppListGroup(
            children: [
              for (final category in active)
                AppListTile(
                  leading: IconBadge(
                    iconKey: category.iconKey,
                    colorKey: category.colorKey,
                  ),
                  title: categoryName(l10n, category),
                  onTap: () => _open(id: category.id),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.space4),
        AppListGroup(
          children: [
            AppListTile(
              leading: Icon(
                AppIcons.plus,
                size: AppSizes.iconMd,
                color: colors.primary,
              ),
              title: l10n.categoriesAdd,
              showChevron: false,
              onTap: _open,
            ),
          ],
        ),
        if (archived.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space6),
          AppListGroup(
            children: [
              AppListTile(
                title: l10n.categoriesArchived(archived.length),
                showChevron: false,
                trailing: Icon(
                  _showArchived ? AppIcons.caretUp : AppIcons.caretDown,
                  size: AppSizes.iconSm,
                  color: colors.textTertiary,
                ),
                onTap: () => setState(() => _showArchived = !_showArchived),
              ),
              if (_showArchived)
                for (final category in archived)
                  AppListTile(
                    leading: IconBadge(
                      iconKey: category.iconKey,
                      colorKey: category.colorKey,
                    ),
                    title: categoryName(l10n, category),
                    showChevron: false,
                    trailing: TextButton(
                      onPressed: () => unawaited(
                        ref
                            .read(categoryRepositoryProvider)
                            .unarchive(category.id),
                      ),
                      child: Text(l10n.actionRestore),
                    ),
                  ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.space8),
      ],
    );
  }
}
