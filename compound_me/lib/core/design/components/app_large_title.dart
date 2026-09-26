import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// iOS-style large title (§7.1): `titleLarge` aligned left under the status
/// bar, collapsing into a small centered title while scrolling. Must be the
/// first sliver of a [CustomScrollView].
class AppLargeTitle extends StatelessWidget {
  const AppLargeTitle({required this.title, this.actions = const [], super.key})
    : assert(actions.length <= 2, 'At most two actions on the right');

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final scaler = MediaQuery.textScalerOf(context);
    final largeTitleLine =
        scaler.scale(AppTextStyles.titleLarge.fontSize!) *
        AppTextStyles.titleLarge.height!;

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: colors.bg,
      expandedHeight:
          AppSizes.appBarHeight + largeTitleLine + AppSpacing.space3,
      actions: [
        ...actions,
        const SizedBox(width: AppSpacing.space2),
      ],
      flexibleSpace: _LargeTitleSpace(title: title),
    );
  }
}

class _LargeTitleSpace extends StatelessWidget {
  const _LargeTitleSpace({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    var expandedFraction = 1.0;
    if (settings != null && settings.maxExtent > settings.minExtent) {
      expandedFraction =
          ((settings.currentExtent - settings.minExtent) /
                  (settings.maxExtent - settings.minExtent))
              .clamp(0, 1);
    }
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        // Small title shown once the large one has scrolled away. It is a
        // visual echo only, so screen readers hear the title once.
        Positioned(
          top: topInset,
          left: AppSizes.minTouchTarget,
          right: AppSizes.minTouchTarget,
          height: AppSizes.appBarHeight,
          child: ExcludeSemantics(
            child: Opacity(
              opacity: 1 - expandedFraction,
              child: Center(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.screenHorizontal,
          right: AppSpacing.screenHorizontal,
          bottom: AppSpacing.space2,
          child: Opacity(
            opacity: expandedFraction,
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
