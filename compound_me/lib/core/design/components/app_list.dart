import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// Titled group of rows on one flat card (Profile, Settings, S-40/S-43).
class AppListGroup extends StatelessWidget {
  const AppListGroup({required this.children, this.title, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.lg));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.space1,
              bottom: AppSpacing.space2,
            ),
            child: Semantics(
              header: true,
              // Its own node, or a one-row group reads as "Tentang, Tentang
              // CompoundMe" to screen readers.
              container: true,
              child: Text(
                title!,
                style: AppTextStyles.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0)
                  const Divider(indent: AppSpacing.space4, height: 0),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One row in an [AppListGroup]: optional leading badge, title, subtitle,
/// a value on the right and a chevron when it can be opened.
class AppListTile extends StatelessWidget {
  const AppListTile({
    required this.title,
    this.subtitle,
    this.value,
    this.leading,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.showChevron,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  /// Defaults to showing a chevron whenever the row can be tapped.
  final bool? showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final chevron = showChevron ?? onTap != null;
    return Semantics(
      container: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.row),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.space3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          color: destructive
                              ? colors.danger
                              : colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  // Sized to its text so it sits by the chevron, but never
                  // wider than half the screen, leaving the title the rest.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width / 2,
                    ),
                    child: Text(
                      value!,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.space2),
                  trailing!,
                ],
                if (chevron) ...[
                  const SizedBox(width: AppSpacing.space1),
                  ExcludeSemantics(
                    child: Icon(
                      AppIcons.caretRight,
                      size: AppSizes.iconSm,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row with a switch; the whole row toggles it.
class AppSwitchTile extends StatelessWidget {
  const AppSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: AppListTile(
        title: title,
        subtitle: subtitle,
        onTap: () => onChanged(!value),
        showChevron: false,
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

/// Form row that opens a picker sheet: "Tipe · Bank ›" (§7.5). Styled like
/// the text field so forms read as one column of inputs.
class RowPicker extends StatelessWidget {
  const RowPicker({
    required this.label,
    required this.value,
    required this.onTap,
    this.leading,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.sm));
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: value.isEmpty ? label : '$label, $value',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: colors.surfaceMuted,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.row),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space2,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AppSpacing.space3),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Text(
                      value,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space1),
                  Icon(
                    AppIcons.caretRight,
                    size: AppSizes.iconSm,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
