import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/features/settings/presentation/delete_all_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings (S-43): language and theme apply at once and are remembered,
/// the hide-balance default and deleting all data. App details live on
/// the About screen (S-40) only.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppLargeTitle(title: l10n.settingsTitle, backLabel: l10n.actionBack),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            sliver: SliverList.list(
              children: [
                AppListGroup(
                  title: l10n.settingsGroupDisplay,
                  children: [
                    _ControlRow(
                      label: l10n.settingsLanguage,
                      child: SegmentedToggle<String>(
                        options: [
                          SegmentedToggleOption(
                            value: 'id',
                            label: l10n.languageIndonesianShort,
                          ),
                          SegmentedToggleOption(
                            value: 'en',
                            label: l10n.languageEnglish,
                          ),
                        ],
                        selected: language,
                        onChanged: (code) => unawaited(
                          ref
                              .read(localeSettingProvider.notifier)
                              .set(Locale(code)),
                        ),
                      ),
                    ),
                    _ControlRow(
                      label: l10n.settingsTheme,
                      child: SegmentedToggle<ThemeMode>(
                        options: [
                          SegmentedToggleOption(
                            value: ThemeMode.system,
                            label: l10n.themeSystem,
                          ),
                          SegmentedToggleOption(
                            value: ThemeMode.light,
                            label: l10n.themeLight,
                          ),
                          SegmentedToggleOption(
                            value: ThemeMode.dark,
                            label: l10n.themeDark,
                          ),
                        ],
                        selected: ref.watch(themeModeSettingProvider),
                        onChanged: (mode) => unawaited(
                          ref.read(themeModeSettingProvider.notifier).set(mode),
                        ),
                      ),
                    ),
                    AppSwitchTile(
                      title: l10n.settingsHideBalance,
                      subtitle: l10n.settingsHideBalanceHint,
                      value: ref.watch(hideBalanceOnLaunchProvider),
                      onChanged: (hide) => unawaited(
                        ref
                            .read(hideBalanceOnLaunchProvider.notifier)
                            .set(hide: hide),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space6),
                AppListGroup(
                  title: l10n.settingsGroupData,
                  children: [
                    AppListTile(
                      title: l10n.settingsDeleteAll,
                      destructive: true,
                      showChevron: false,
                      onTap: () => unawaited(showDeleteAllSheet(context)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled control inside a settings group.
class _ControlRow extends StatelessWidget {
  const _ControlRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space3,
        AppSpacing.space4,
        AppSpacing.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.space1),
          child,
        ],
      ),
    );
  }
}
