import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Compound Insights (S-30). Phase 0 shows the "not enough data" state.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        AppLargeTitle(title: l10n.navInsights),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: EmptyState(
              icon: PhosphorIconsRegular.chartPieSlice,
              title: l10n.insightsEmptyTitle,
              message: l10n.insightsEmptyBody,
            ),
          ),
        ),
      ],
    );
  }
}
