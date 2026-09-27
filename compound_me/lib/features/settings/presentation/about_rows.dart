import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/settings/application/settings_controller.dart';
import 'package:compound_me/features/settings/domain/app_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// The app icon as drawn on the launcher, for About and the licenses page.
class AppIconImage extends StatelessWidget {
  const AppIconImage({super.key});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
    child: Image.asset(
      appIconAsset,
      width: AppSizes.appIcon,
      height: AppSizes.appIcon,
      excludeFromSemantics: true,
    ),
  );
}

/// Version, credits, source code and licenses. Shared by the About screen
/// and the About group in Settings so both always say the same.
class AboutRows extends ConsumerWidget {
  const AboutRows({this.title, super.key});

  final String? title;

  Future<void> _openSource(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.linkOpenFailed;
    final opened = await launchUrl(
      Uri.parse(repositoryUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final version = ref.watch(appVersionProvider).value ?? '';
    return AppListGroup(
      title: title,
      children: [
        AppListTile(title: l10n.aboutVersion, value: version),
        AppListTile(title: l10n.aboutCreator),
        AppListTile(
          title: l10n.aboutSource,
          showChevron: false,
          trailing: Icon(
            AppIcons.arrowSquareOut,
            size: AppSizes.iconSm,
            color: colors.textTertiary,
          ),
          onTap: () => unawaited(_openSource(context)),
        ),
        AppListTile(
          title: l10n.aboutLicenses,
          onTap: () => showLicensePage(
            context: context,
            useRootNavigator: true,
            applicationName: l10n.appTitle,
            applicationVersion: version,
            applicationIcon: const Padding(
              padding: EdgeInsets.all(AppSpacing.space2),
              child: AppIconImage(),
            ),
          ),
        ),
      ],
    );
  }
}
