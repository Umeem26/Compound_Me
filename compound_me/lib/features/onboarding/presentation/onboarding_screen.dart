import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/onboarding/application/onboarding_controller.dart';
import 'package:compound_me/features/onboarding/domain/habit_templates.dart';
import 'package:compound_me/features/onboarding/domain/onboarding_draft.dart';
import 'package:compound_me/features/onboarding/presentation/template_labels.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Flow A (S-01): language, three value pages, name, first wallet and
/// starter habits. Progress is saved after every change; the system back
/// button returns to the previous step.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingControllerProvider.select((d) => d.step));
    final controller = ref.read(onboardingControllerProvider.notifier);
    final duration = AppDurations.resolve(
      AppDurations.base,
      reduceMotion: MediaQuery.disableAnimationsOf(context),
    );
    return PopScope(
      canPop: step.previous == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.back();
      },
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: duration,
            switchInCurve: AppDurations.baseCurve,
            switchOutCurve: AppDurations.baseCurve,
            child: KeyedSubtree(
              key: ValueKey(step),
              child: switch (step) {
                OnboardingStep.language => const _LanguageStep(),
                OnboardingStep.valueGrowth => const _ValueStep(
                  kind: OnboardingArtKind.growth,
                ),
                OnboardingStep.valueSpeed => const _ValueStep(
                  kind: OnboardingArtKind.speed,
                ),
                OnboardingStep.valuePrivacy => const _ValueStep(
                  kind: OnboardingArtKind.privacy,
                ),
                OnboardingStep.name => const _NameStep(),
                OnboardingStep.wallet => const _WalletStep(),
                OnboardingStep.habits => const _HabitsStep(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared frame of a step: a top bar, scrollable content and the main
/// button pinned at the bottom.
class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.body,
    required this.bottom,
    this.showBack = false,
    this.topAction,
  });

  final Widget body;
  final Widget bottom;
  final bool showBack;
  final Widget? topAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: AppSizes.appBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space1),
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    icon: const Icon(AppIcons.arrowLeft),
                    tooltip: context.l10n.actionBack,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                const Spacer(),
                ?topAction,
              ],
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                sliver: SliverFillRemaining(hasScrollBody: false, child: body),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.space3,
            AppSpacing.screenHorizontal,
            AppSpacing.space4,
          ),
          child: bottom,
        ),
      ],
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          body,
          style: AppTextStyles.body.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = Localizations.localeOf(context).languageCode;
    final locale = ref.read(localeSettingProvider.notifier);
    return _StepLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.space8),
          _StepHeading(
            title: l10n.onboardingLanguageTitle,
            body: l10n.onboardingLanguageBody,
          ),
          const SizedBox(height: AppSpacing.space6),
          SelectableCard(
            title: l10n.languageIndonesian,
            selected: current == 'id',
            onTap: () => locale.set(const Locale('id')),
          ),
          const SizedBox(height: AppSpacing.space3),
          SelectableCard(
            title: l10n.languageEnglish,
            selected: current == 'en',
            onTap: () => locale.set(const Locale('en')),
          ),
        ],
      ),
      bottom: PrimaryButton(
        label: l10n.actionNext,
        onPressed: ref.read(onboardingControllerProvider.notifier).next,
      ),
    );
  }
}

class _ValueStep extends ConsumerWidget {
  const _ValueStep({required this.kind});

  final OnboardingArtKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(onboardingControllerProvider.notifier);
    final (title, body) = switch (kind) {
      OnboardingArtKind.growth => (
        l10n.onboardingValueGrowthTitle,
        l10n.onboardingValueGrowthBody,
      ),
      OnboardingArtKind.speed => (
        l10n.onboardingValueSpeedTitle,
        l10n.onboardingValueSpeedBody,
      ),
      OnboardingArtKind.privacy => (
        l10n.onboardingValuePrivacyTitle,
        l10n.onboardingValuePrivacyBody,
      ),
    };
    return _StepLayout(
      showBack: true,
      topAction: GhostButton(
        label: l10n.actionSkip,
        onPressed: () => controller.goTo(OnboardingStep.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Center(child: OnboardingArt(kind: kind)),
          const Spacer(),
          const SizedBox(height: AppSpacing.space6),
          _StepHeading(title: title, body: body),
          const SizedBox(height: AppSpacing.space6),
          PageIndicator(
            count: OnboardingArtKind.values.length,
            index: kind.index,
            semanticLabel: l10n.onboardingPageLabel(
              kind.index + 1,
              OnboardingArtKind.values.length,
            ),
          ),
        ],
      ),
      bottom: PrimaryButton(label: l10n.actionNext, onPressed: controller.next),
    );
  }
}

class _NameStep extends ConsumerStatefulWidget {
  const _NameStep();

  @override
  ConsumerState<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<_NameStep> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(onboardingControllerProvider).name,
  );
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = context.l10n.errorNameRequired);
      return;
    }
    ref.read(onboardingControllerProvider.notifier).next();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StepLayout(
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.space4),
          _StepHeading(
            title: l10n.onboardingNameTitle,
            body: l10n.onboardingNameBody,
          ),
          const SizedBox(height: AppSpacing.space6),
          AppTextField(
            label: l10n.fieldName,
            controller: _name,
            errorText: _error,
            maxLength: onboardingNameMaxLength,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              ref.read(onboardingControllerProvider.notifier).setName(value);
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      bottom: PrimaryButton(label: l10n.actionNext, onPressed: _submit),
    );
  }
}

class _WalletStep extends ConsumerStatefulWidget {
  const _WalletStep();

  @override
  ConsumerState<_WalletStep> createState() => _WalletStepState();
}

class _WalletStepState extends ConsumerState<_WalletStep> {
  TextEditingController? _name;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The default name follows the language picked in the first step.
    _name ??= TextEditingController(
      text:
          ref.read(onboardingControllerProvider).walletName ??
          context.l10n.walletDefaultName,
    );
  }

  @override
  void dispose() {
    _name?.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name!.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.errorNameRequired);
      return;
    }
    ref.read(onboardingControllerProvider.notifier)
      ..setWalletName(name)
      ..next();
  }

  Future<void> _editBalance(Money current) async {
    final l10n = context.l10n;
    final amount = await showAmountSheet(
      context,
      title: l10n.fieldInitialBalance,
      initial: current,
      saveLabel: l10n.actionSave,
      backspaceLabel: l10n.keypadBackspace,
    );
    if (amount != null) {
      ref.read(onboardingControllerProvider.notifier).setInitialBalance(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    return _StepLayout(
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.space4),
          _StepHeading(
            title: l10n.onboardingWalletTitle,
            body: l10n.onboardingWalletBody,
          ),
          const SizedBox(height: AppSpacing.space6),
          AppTextField(
            label: l10n.fieldWalletName,
            controller: _name!,
            errorText: _error,
            maxLength: walletNameMaxLength,
            textCapitalization: TextCapitalization.words,
            onChanged: (value) {
              controller.setWalletName(value);
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            l10n.fieldWalletType,
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space1),
          SegmentedToggle<WalletType>(
            options: [
              SegmentedToggleOption(
                value: WalletType.cash,
                label: l10n.walletTypeCash,
              ),
              SegmentedToggleOption(
                value: WalletType.bank,
                label: l10n.walletTypeBank,
              ),
              SegmentedToggleOption(
                value: WalletType.ewallet,
                label: l10n.walletTypeEwallet,
              ),
            ],
            selected: draft.walletType,
            onChanged: controller.setWalletType,
          ),
          const SizedBox(height: AppSpacing.space4),
          RowPicker(
            label: l10n.fieldInitialBalance,
            value: formatRupiah(draft.initialBalance),
            onTap: () => _editBalance(draft.initialBalance),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            l10n.onboardingWalletHelper,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      bottom: PrimaryButton(label: l10n.actionNext, onPressed: _submit),
    );
  }
}

class _HabitsStep extends ConsumerStatefulWidget {
  const _HabitsStep();

  @override
  ConsumerState<_HabitsStep> createState() => _HabitsStepState();
}

class _HabitsStepState extends ConsumerState<_HabitsStep> {
  bool _saving = false;

  Future<void> _finish() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .finish(
            defaultWalletName: l10n.walletDefaultName,
            templateName: (template) => templateName(l10n, template),
          );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorSaveFailed)));
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editCost(HabitTemplate template, Money current) async {
    final l10n = context.l10n;
    final amount = await showAmountSheet(
      context,
      title: l10n.templateCostTitle,
      initial: current,
      saveLabel: l10n.actionSave,
      backspaceLabel: l10n.keypadBackspace,
    );
    // A reduce habit always needs a cost above zero.
    if (amount != null && amount > 0) {
      ref
          .read(onboardingControllerProvider.notifier)
          .setTemplateCost(template, amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final draft = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    Widget group(String title, HabitKind kind) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
        ),
        for (final template in HabitTemplate.values)
          if (template.kind == kind) ...[
            const SizedBox(height: AppSpacing.space2),
            _TemplateCard(
              template: template,
              selected: draft.selected.contains(template),
              cost: draft.costOf(template),
              onTap: draft.selected.contains(template) || draft.canPickMore
                  ? () => controller.toggleTemplate(template)
                  : null,
              onEditCost: (cost) => _editCost(template, cost),
            ),
          ],
      ],
    );

    return _StepLayout(
      showBack: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.space4),
          _StepHeading(
            title: l10n.onboardingHabitsTitle,
            body: l10n.onboardingHabitsBody,
          ),
          const SizedBox(height: AppSpacing.space6),
          group(l10n.habitGroupBuild, HabitKind.build),
          const SizedBox(height: AppSpacing.space6),
          group(l10n.habitGroupReduce, HabitKind.reduce),
          const SizedBox(height: AppSpacing.space4),
        ],
      ),
      bottom: PrimaryButton(
        label: draft.selected.isEmpty
            ? l10n.actionSkipForNow
            : l10n.actionStart,
        loading: _saving,
        onPressed: _finish,
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.selected,
    required this.cost,
    required this.onTap,
    required this.onEditCost,
  });

  final HabitTemplate template;
  final bool selected;
  final Money? cost;
  final VoidCallback? onTap;
  final ValueChanged<Money> onEditCost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = templateName(l10n, template);
    final reduce = template.kind == HabitKind.reduce;
    return SelectableCard(
      title: name,
      subtitle: reduce
          ? l10n.templateCostTitle
          : templateSchedule(l10n, template),
      leading: IconBadge(
        iconKey: template.iconKey,
        colorKey: template.colorKey,
      ),
      trailing: reduce && cost != null
          ? _CostChip(
              amount: cost!,
              semanticLabel: l10n.templateCostEdit(name, formatRupiah(cost!)),
              onTap: () => onEditCost(cost!),
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadius.full));
    return Semantics(
      button: true,
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
                    const SizedBox(width: AppSpacing.space1),
                    Icon(
                      AppIcons.pencilSimple,
                      size: AppSizes.iconSm,
                      color: colors.textSecondary,
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
