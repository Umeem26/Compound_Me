import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_templates.dart';
import 'package:compound_me/features/habits/presentation/template_labels.dart';
import 'package:flutter/material.dart';

/// One starter habit (S-01 onboarding, S-20 "Pilih dari template"): icon,
/// name, schedule or cost. With [onEditCost] a reduce template's cost is a
/// chip that opens the amount sheet; without it the cost is shown only.
class HabitTemplateCard extends StatelessWidget {
  const HabitTemplateCard({
    required this.template,
    required this.onTap,
    this.selected = false,
    this.cost,
    this.onEditCost,
    super.key,
  });

  final HabitTemplate template;
  final bool selected;
  final Money? cost;
  final VoidCallback? onTap;
  final ValueChanged<Money>? onEditCost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = templateName(l10n, template);
    final reduce = template.kind == HabitKind.reduce;
    final amount = cost ?? template.defaultCost;
    final edit = onEditCost;
    return SelectableCard(
      title: name,
      subtitle: reduce
          ? l10n.templateCostTitle
          : templateSchedule(l10n, template),
      leading: IconBadge(
        iconKey: template.iconKey,
        colorKey: template.colorKey,
      ),
      trailing: reduce && amount != null
          ? _CostChip(
              amount: amount,
              semanticLabel: edit == null
                  ? formatRupiah(amount)
                  : l10n.templateCostEdit(name, formatRupiah(amount)),
              onTap: edit == null ? null : () => edit(amount),
            )
          : null,
      selected: selected,
      onTap: onTap,
    );
  }
}

/// Tappable cost of a reduce template, opening the amount sheet.
class _CostChip extends StatelessWidget {
  const _CostChip({
    required this.amount,
    required this.semanticLabel,
    required this.onTap,
  });

  final Money amount;
  final String semanticLabel;

  /// Null shows the cost without the pencil.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.full));
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
        child: Center(
          child: Material(
            color: colors.surfaceMuted,
            borderRadius: radius,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space3,
                  vertical: AppSpacing.space2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatRupiah(amount),
                      style: AppTextStyles.label.tabular.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: AppSpacing.space1),
                      Icon(
                        AppIcons.pencilSimple,
                        size: AppSizes.iconSm,
                        color: colors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
