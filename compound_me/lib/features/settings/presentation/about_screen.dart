import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/settings/application/settings_controller.dart';
import 'package:compound_me/features/settings/presentation/about_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// About CompoundMe (S-40, Tentang): icon, name, version, credits, source
/// code and open source licenses.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final version = ref.watch(appVersionProvider).value ?? '';
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppLargeTitle(title: l10n.aboutTitle, backLabel: l10n.actionBack),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: AppSpacing.space4),
                const Center(child: AppIconImage()),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  l10n.appTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  version,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.space6),
                const AboutRows(),
                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
