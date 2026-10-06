import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// Large choice card (onboarding language and habit templates). Selected
/// uses the chip pattern of §7.5: `primaryTint` fill and a `primary` border.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// Extra control on the right, e.g. an editable cost.
  final Widget? trailing;
  final bool selected;

  /// Null disables the card (e.g. the template limit is reached).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));
    final enabled = onTap != null || selected;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: Opacity(
        opacity: enabled ? 1 : AppOpacity.disabled,
        child: Material(
          color: selected ? colors.primaryTint : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selected ? colors.primary : colors.border,
              width: selected ? AppSizes.borderSelected : AppSizes.border,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.selectableCardMin,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                  vertical: AppSpacing.space3,
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
                            style: AppTextStyles.titleSmall.copyWith(
                              color: colors.textPrimary,
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
                    if (trailing != null) ...[
                      const SizedBox(width: AppSpacing.space2),
                      trailing!,
                    ],
                    const SizedBox(width: AppSpacing.space2),
                    ExcludeSemantics(
                      child: Icon(
                        selected ? AppIcons.checkCircleFill : AppIcons.circle,
                        size: AppSizes.iconMd,
                        color: selected ? colors.primary : colors.textTertiary,
                      ),
                    ),
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

/// Onboarding page dots: the current page is a wider pill (mockup S-01).
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    required this.count,
    required this.index,
    required this.semanticLabel,
    super.key,
  });

  final int count;
  final int index;

  /// E.g. "Halaman 1 dari 3".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final duration = AppDurations.resolve(
      AppDurations.base,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.space1),
            AnimatedContainer(
              duration: duration,
              curve: AppDurations.baseCurve,
              width: i == index ? AppSizes.pageDotActive : AppSizes.pageDot,
              height: AppSizes.pageDot,
              decoration: BoxDecoration(
                color: i == index ? colors.primary : colors.primaryTintPressed,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.full),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Initial of the user's name in a tinted circle (S-40 header, S-10). An
/// empty name shows the user icon instead.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    required this.name,
    this.size = AppSizes.avatar,
    super.key,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final trimmed = name.trim();
    final initial = trimmed.isEmpty
        ? ''
        : String.fromCharCode(trimmed.runes.first).toUpperCase();
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: initial.isEmpty
            ? Icon(
                AppIcons.user,
                size: size < AppSizes.avatar
                    ? AppSizes.iconSm
                    : AppSizes.iconLg,
                color: colors.onPrimaryTint,
              )
            : Text(
                initial,
                style:
                    (size < AppSizes.avatar
                            ? AppTextStyles.titleSmall
                            : AppTextStyles.titleLarge)
                        .copyWith(color: colors.onPrimaryTint),
              ),
      ),
    );
  }
}
