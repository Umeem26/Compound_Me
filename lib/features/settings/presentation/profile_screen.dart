import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/onboarding/application/onboarding_controller.dart';
import 'package:compound_me/features/settings/application/settings_controller.dart';
import 'package:compound_me/features/wallets/presentation/wallet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Profile (S-40): the name used for greetings, then money, app and about
/// groups. Lives under settings because 05 §2 has no profile folder.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final activeWallets = ref.watch(activeWalletsProvider).value;
    final version = ref.watch(appVersionProvider).value;
    return CustomScrollView(
      slivers: [
        AppLargeTitle(title: l10n.navProfile),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          sliver: SliverList.list(
            children: [
              _ProfileHeader(name: ref.watch(userNameProvider)),
              const SizedBox(height: AppSpacing.space6),
              AppListGroup(
                title: l10n.profileGroupFinance,
                children: [
                  AppListTile(
                    title: l10n.walletsTitle,
                    value: activeWallets == null
                        ? null
                        : l10n.profileActiveWallets(activeWallets.length),
                    onTap: () => context.push(AppRoutes.wallets),
                  ),
                  AppListTile(
                    title: l10n.categoriesTitle,
                    onTap: () => context.push(AppRoutes.categories),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space6),
              AppListGroup(
                title: l10n.profileGroupApp,
                children: [
                  AppListTile(
                    title: l10n.settingsTitle,
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space6),
              AppListGroup(
                title: l10n.profileGroupAbout,
                children: [
                  AppListTile(
                    title: l10n.aboutTitle,
                    value: version,
                    onTap: () => context.push(AppRoutes.about),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space8),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    return Semantics(
      button: true,
      label: l10n.profileEditName(name),
      excludeSemantics: true,
      child: AppCard(
        onTap: () => unawaited(showNameSheet(context, current: name)),
        child: Row(
          children: [
            InitialAvatar(name: name),
            const SizedBox(width: AppSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.profileTapToEdit,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.pencilSimple,
              size: AppSizes.iconSm,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet that changes the greeting name (1–24 characters, like Flow A).
Future<void> showNameSheet(BuildContext context, {required String current}) =>
    showAppSheet<void>(
      context,
      builder: (context) => _NameSheet(current: current),
    );

class _NameSheet extends ConsumerStatefulWidget {
  const _NameSheet({required this.current});

  final String current;

  @override
  ConsumerState<_NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends ConsumerState<_NameSheet> {
  late final _name = TextEditingController(text: widget.current);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.errorNameRequired);
      return;
    }
    final navigator = Navigator.of(context);
    await ref.read(userNameProvider.notifier).set(name);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SheetBody(
      title: l10n.profileNameTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.fieldName,
            controller: _name,
            errorText: _error,
            maxLength: onboardingNameMaxLength,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => unawaited(_save()),
          ),
          const SizedBox(height: AppSpacing.space4),
          PrimaryButton(label: l10n.actionSave, onPressed: _save),
        ],
      ),
    );
  }
}
