import 'package:compound_me/core/design/components/buttons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// Designed empty state (§7.6): icon in a tinted circle, a title, a short
/// explanation and at most one action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be provided together',
       );

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.space8,
        AppSpacing.screenHorizontal,
        AppSpacing.space8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.emptyStateCircle,
            height: AppSizes.emptyStateCircle,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: ExcludeSemantics(
              child: Icon(
                icon,
                size: AppSizes.emptyStateIcon,
                color: colors.onPrimaryTint,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.space6),
            PrimaryButton(
              label: actionLabel!,
              onPressed: onAction,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
