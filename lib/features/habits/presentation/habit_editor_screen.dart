import 'dart:async';

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/habits/data/drift_habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit.dart';
import 'package:compound_me/features/habits/domain/habit_repository.dart';
import 'package:compound_me/features/habits/domain/habit_templates.dart';
import 'package:compound_me/features/habits/presentation/habit_labels.dart';
import 'package:compound_me/features/transactions/data/drift_transaction_repository.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_editor_screen.g.dart';

const _nameMaxLength = 40;

/// Highest weekly limit the stepper offers: ten a day, every day.
const int _maxWeeklyLimit = HabitRepository.maxDailyCount * 7;

/// What a new habit's form starts from: a template (S-20) or the habit
/// whose kind could not change (S-21, "Buat kebiasaan baru").
class HabitEditorSeed {
  const HabitEditorSeed({required this.draft, this.categoryNameKey});

  factory HabitEditorSeed.fromTemplate(
    HabitTemplate template, {
    required String name,
  }) => HabitEditorSeed(
    draft: template.toDraft(name: name),
    categoryNameKey: template.categoryNameKey,
  );

  final HabitDraft draft;

  /// Default category to look up when [draft] has none (templates).
  final String? categoryNameKey;
}

enum HabitEditAction { archived, deleted }

typedef HabitEditOutcome = ({HabitEditAction action, Habit habit});

/// Opens S-21 for a new habit, a template, or [habitId]; archiving or
/// deleting there comes back with an undo snackbar on [context].
Future<void> openHabitEditor(
  BuildContext context, {
  String? habitId,
  HabitEditorSeed? seed,
}) async {
  final outcome = await context.push<HabitEditOutcome>(
    habitId == null ? AppRoutes.habitNew : AppRoutes.habitEdit(habitId),
    extra: seed,
  );
  if (outcome == null || !context.mounted) return;
  final l10n = context.l10n;
  final repository = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(habitRepositoryProvider);
  showUndoSnackbar(
    context,
    message: switch (outcome.action) {
      HabitEditAction.archived => l10n.habitArchivedDone,
      HabitEditAction.deleted => l10n.habitDeletedDone,
    },
    undoLabel: l10n.undoAction,
    onUndo: () => unawaited(switch (outcome.action) {
      HabitEditAction.archived => repository.unarchive(outcome.habit.id),
      HabitEditAction.deleted => repository.undoDelete(outcome.habit),
    }),
  );
}

/// What the form needs besides the habit: whether it has check-ins (its
/// kind is then fixed), and the wallets and expense categories to pick.
typedef HabitEditorSource = ({
  Habit? habit,
  bool hasCheckIns,
  List<Wallet> wallets,
  List<Category> categories,
  String? lastWalletId,
});

@riverpod
Future<HabitEditorSource> habitEditorSource(Ref ref, String? id) async {
  final habits = ref.watch(habitRepositoryProvider);
  final habit = id == null ? null : await habits.findById(id);
  return (
    habit: habit,
    hasCheckIns: habit != null && await habits.hasCheckIns(habit.id),
    wallets: await ref.watch(walletRepositoryProvider).listActive(),
    categories: await ref
        .watch(categoryRepositoryProvider)
        .listActive(CategoryKind.expense),
    lastWalletId: await ref
        .watch(transactionRepositoryProvider)
        .lastUsedWalletId(),
  );
}

/// New or existing habit (S-21), one scrolling form: kind, name, icon and
/// color, schedule, and for reduce habits cost, wallet, category and an
/// optional weekly limit. A habit with check-ins can be archived, one
/// without can be deleted.
class HabitEditorScreen extends ConsumerWidget {
  const HabitEditorScreen({this.habitId, this.seed, super.key});

  final String? habitId;
  final HabitEditorSeed? seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final source = ref.watch(habitEditorSourceProvider(habitId));
    return switch (source) {
      AsyncData(:final value) when habitId != null && value.habit == null =>
        Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: AppIcons.checkCircle,
            title: l10n.habitsEmptyTitle,
            message: l10n.errorLoadBody,
          ),
        ),
      AsyncData(:final value) => _HabitForm(source: value, seed: seed),
      _ => Scaffold(
        appBar: AppBar(),
        body: AsyncBody<void>(
          value: source,
          data: (_) => const SizedBox.shrink(),
          errorLabels: l10n.loadErrorLabels,
          onRetry: () => ref.invalidate(habitEditorSourceProvider(habitId)),
        ),
      ),
    };
  }
}

class _HabitForm extends ConsumerStatefulWidget {
  const _HabitForm({required this.source, required this.seed});

  final HabitEditorSource source;
  final HabitEditorSeed? seed;

  @override
  ConsumerState<_HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends ConsumerState<_HabitForm> {
  late final Habit? _habit = widget.source.habit;
  late final HabitDraft _initial = _startDraft();
  late final TextEditingController _name = TextEditingController(
    text: _initial.name,
  );
  late HabitKind _kind = _initial.kind;
  late String _iconKey = _initial.iconKey;
  late String _colorKey = _initial.colorKey;
  late ScheduleType _scheduleType = _initial.scheduleType;
  late int _scheduleDays = _initial.scheduleDays == 0
      ? Weekdays.workdays
      : _initial.scheduleDays;
  late int _timesPerWeek = _initial.timesPerWeek ?? 3;
  late Money _cost = _initial.costPerOccurrence ?? 0;
  late String? _walletId = _initial.walletId;
  late String? _categoryId = _initial.categoryId;
  late int? _weeklyLimit = _initial.weeklyLimit;

  String? _nameError;
  bool _costError = false;
  bool _walletError = false;
  bool _categoryError = false;
  bool _busy = false;

  bool get _reduce => _kind == HabitKind.reduce;

  HabitDraft _startDraft() {
    final habit = widget.source.habit;
    if (habit != null) {
      return HabitDraft(
        name: habit.name,
        kind: habit.kind,
        iconKey: habit.iconKey,
        colorKey: habit.colorKey,
        scheduleType: habit.scheduleType,
        scheduleDays: habit.scheduleDays,
        timesPerWeek: habit.timesPerWeek,
        costPerOccurrence: habit.costPerOccurrence,
        walletId: habit.walletId,
        categoryId: habit.categoryId,
        weeklyLimit: habit.weeklyLimit,
      );
    }
    final seed = widget.seed;
    final draft = seed?.draft;
    final wallets = widget.source.wallets;
    final wallet =
        draft?.walletId ??
        widget.source.lastWalletId ??
        wallets.firstOrNull?.id;
    var category = draft?.categoryId;
    final key = seed?.categoryNameKey;
    if (category == null && key != null) {
      for (final c in widget.source.categories) {
        if (c.nameKey == key) category = c.id;
      }
    }
    return HabitDraft(
      name: draft?.name ?? '',
      kind: draft?.kind ?? HabitKind.build,
      iconKey: draft?.iconKey ?? 'plant',
      colorKey: draft?.colorKey ?? AppPresetColor.teal.key,
      scheduleType: draft?.scheduleType ?? ScheduleType.daily,
      scheduleDays: draft?.scheduleDays ?? 0,
      timesPerWeek: draft?.timesPerWeek,
      costPerOccurrence: draft?.costPerOccurrence,
      walletId: wallet,
      categoryId: category,
      weeklyLimit: draft?.weeklyLimit,
    );
  }

  HabitDraft get _draft => HabitDraft(
    name: _name.text.trim(),
    kind: _kind,
    iconKey: _iconKey,
    colorKey: _colorKey,
    scheduleType: _scheduleType,
    scheduleDays: _scheduleType == ScheduleType.weekdays ? _scheduleDays : 0,
    timesPerWeek: _scheduleType == ScheduleType.timesPerWeek
        ? _timesPerWeek
        : null,
    costPerOccurrence: _reduce ? _cost : null,
    walletId: _reduce ? _walletId : null,
    categoryId: _reduce ? _categoryId : null,
    weeklyLimit: _reduce ? _weeklyLimit : null,
  );

  /// Anything differing from what the form opened with (03 §4).
  bool get _hasChanges {
    final a = _draft;
    final b = _initial;
    return a.name != b.name.trim() ||
        a.kind != b.kind ||
        a.iconKey != b.iconKey ||
        a.colorKey != b.colorKey ||
        a.scheduleType != b.scheduleType ||
        (a.scheduleType == ScheduleType.weekdays &&
            a.scheduleDays !=
                (b.scheduleDays == 0 ? Weekdays.workdays : b.scheduleDays)) ||
        (a.scheduleType == ScheduleType.timesPerWeek &&
            a.timesPerWeek != (b.timesPerWeek ?? 3)) ||
        (_reduce &&
            (a.costPerOccurrence != (b.costPerOccurrence ?? 0) ||
                a.walletId != b.walletId ||
                a.categoryId != b.categoryId ||
                a.weeklyLimit != b.weeklyLimit));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _setKind(HabitKind kind) {
    if (kind == _kind) return;
    if (_habit != null && widget.source.hasCheckIns) {
      unawaited(_explainKindLocked(kind));
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    setState(() => _kind = kind);
  }

  /// A habit with check-ins keeps its kind, so its history and expenses
  /// stay true (HabitHasLogsException). Offer a new habit of [kind].
  Future<void> _explainKindLocked(HabitKind kind) async {
    final l10n = context.l10n;
    final create = await showAppSheet<bool>(
      context,
      builder: (context) {
        final colors = context.tokens.colors;
        return SheetBody(
          title: l10n.habitKindLockedTitle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.habitKindLockedBody(habitKindLabel(l10n, kind)),
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.space6),
              PrimaryButton(
                label: l10n.habitKindLockedAction,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: AppSpacing.space2),
              GhostButton(
                label: l10n.actionCancel,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
      },
    );
    if (create != true || !mounted) return;
    final draft = _draft;
    // The new habit starts as this one with the other kind; this form
    // closes without saving.
    context.pushReplacement(
      AppRoutes.habitNew,
      extra: HabitEditorSeed(
        draft: HabitDraft(
          name: draft.name,
          kind: kind,
          iconKey: draft.iconKey,
          colorKey: draft.colorKey,
          scheduleType: draft.scheduleType,
          scheduleDays: draft.scheduleDays,
          timesPerWeek: draft.timesPerWeek,
          costPerOccurrence: _cost == 0 ? null : _cost,
          walletId: _walletId,
          categoryId: _categoryId,
          weeklyLimit: _weeklyLimit,
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    final l10n = context.l10n;
    final key = await showIconPickerSheet(
      context,
      title: l10n.iconPickerTitle,
      selectedKey: _iconKey,
      colorKey: _colorKey,
      semanticLabel: l10n.iconPosition,
    );
    if (key != null) setState(() => _iconKey = key);
  }

  Future<void> _editCost() async {
    final l10n = context.l10n;
    final amount = await showAmountSheet(
      context,
      title: l10n.habitCostField,
      initial: _cost,
      saveLabel: l10n.actionSave,
      backspaceLabel: l10n.keypadBackspace,
    );
    if (amount != null) {
      setState(() {
        _cost = amount;
        _costError = false;
      });
    }
  }

  Future<void> _pickWallet() async {
    final picked = await showOptionSheet<String?>(
      context,
      title: context.l10n.txWalletPickerTitle,
      selected: _walletId,
      options: [
        for (final wallet in widget.source.wallets)
          SheetOption(
            value: wallet.id,
            label: wallet.name,
            leading: IconBadge(
              iconKey: wallet.iconKey,
              colorKey: wallet.colorKey,
            ),
          ),
      ],
    );
    if (picked != null) {
      setState(() {
        _walletId = picked;
        _walletError = false;
      });
    }
  }

  Future<void> _pickCategory() async {
    final l10n = context.l10n;
    final picked = await showOptionSheet<String?>(
      context,
      title: l10n.txCategoryPickerTitle,
      selected: _categoryId,
      options: [
        for (final category in widget.source.categories)
          SheetOption(
            value: category.id,
            label: categoryName(l10n, category),
            leading: IconBadge(
              iconKey: category.iconKey,
              colorKey: category.colorKey,
            ),
          ),
      ],
    );
    if (picked != null) {
      setState(() {
        _categoryId = picked;
        _categoryError = false;
      });
    }
  }

  bool _validate() {
    final l10n = context.l10n;
    final name = _name.text.trim();
    setState(() {
      _nameError = name.isEmpty ? l10n.errorNameRequired : null;
      _costError = _reduce && _cost <= 0;
      _walletError = _reduce && _walletId == null;
      _categoryError = _reduce && _categoryId == null;
    });
    return _nameError == null &&
        !_costError &&
        !_walletError &&
        !_categoryError &&
        !(_scheduleType == ScheduleType.weekdays && _scheduleDays == 0);
  }

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.errorSaveFailed;
    setState(() => _busy = true);
    try {
      await action();
    } on HabitHasLogsException {
      if (mounted) {
        setState(() => _busy = false);
        await _explainKindLocked(_kind);
      }
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!_validate()) return;
    final navigator = Navigator.of(context);
    final habit = _habit;
    await _run(() async {
      final repository = ref.read(habitRepositoryProvider);
      if (habit == null) {
        await repository.create(_draft);
      } else {
        await repository.update(habit.id, _draft);
      }
      navigator.pop();
    });
  }

  Future<void> _archiveOrDelete(HabitEditAction action) async {
    final habit = _habit!;
    final navigator = Navigator.of(context);
    await _run(() async {
      final repository = ref.read(habitRepositoryProvider);
      switch (action) {
        case HabitEditAction.archived:
          await repository.archive(habit.id);
        case HabitEditAction.deleted:
          await repository.delete(habit.id);
      }
      navigator.pop<HabitEditOutcome>((action: action, habit: habit));
    });
  }

  void _toggleDay(int weekday) {
    unawaited(HapticFeedback.selectionClick());
    setState(() => _scheduleDays ^= Weekdays.bitFor(weekday));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final habit = _habit;
    final stepper = (
      decrease: l10n.stepperDecrease,
      increase: l10n.stepperIncrease,
    );
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: colors.textSecondary),
      ),
    );
    Widget error(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.space1),
      child: Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: colors.danger),
        ),
      ),
    );

    return UnsavedChangesGuard(
      hasChanges: _hasChanges && !_busy,
      labels: l10n.discardLabels,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(AppIcons.x),
            tooltip: l10n.actionClose,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(habit == null ? l10n.habitNewTitle : l10n.habitEditTitle),
        ),
        // The save button sits in the body so it rises above the keyboard.
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.space4,
                  AppSpacing.screenHorizontal,
                  AppSpacing.space8,
                ),
                children: [
                  label(l10n.habitKindField),
                  SelectableCard(
                    title: l10n.habitKindBuild,
                    subtitle: l10n.habitKindBuildHint,
                    selected: _kind == HabitKind.build,
                    onTap: () => _setKind(HabitKind.build),
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  SelectableCard(
                    title: l10n.habitKindReduce,
                    subtitle: l10n.habitKindReduceHint,
                    selected: _kind == HabitKind.reduce,
                    onTap: () => _setKind(HabitKind.reduce),
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  AppTextField(
                    label: l10n.fieldHabitName,
                    controller: _name,
                    hintText: l10n.habitNameHint,
                    errorText: _nameError,
                    maxLength: _nameMaxLength,
                    autofocus: habit == null && widget.seed == null,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  RowPicker(
                    label: l10n.fieldIcon,
                    value: '',
                    leading: IconBadge(iconKey: _iconKey, colorKey: _colorKey),
                    onTap: _pickIcon,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  label(l10n.fieldColor),
                  ColorPicker(
                    selectedKey: _colorKey,
                    onChanged: (key) => setState(() => _colorKey = key),
                    semanticLabel: l10n.presetColorName,
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  label(l10n.habitScheduleField),
                  SegmentedToggle<ScheduleType>(
                    options: [
                      SegmentedToggleOption(
                        value: ScheduleType.daily,
                        label: l10n.scheduleDaily,
                      ),
                      SegmentedToggleOption(
                        value: ScheduleType.weekdays,
                        label: l10n.scheduleSpecificDays,
                      ),
                      SegmentedToggleOption(
                        value: ScheduleType.timesPerWeek,
                        label: l10n.scheduleTimesOption,
                      ),
                    ],
                    selected: _scheduleType,
                    onChanged: (type) => setState(() => _scheduleType = type),
                  ),
                  if (_scheduleType == ScheduleType.weekdays) ...[
                    const SizedBox(height: AppSpacing.space3),
                    _WeekdayChips(
                      selected: _scheduleDays,
                      onToggle: _toggleDay,
                    ),
                    if (_scheduleDays == 0) error(l10n.habitDaysError),
                  ],
                  if (_scheduleType == ScheduleType.timesPerWeek) ...[
                    const SizedBox(height: AppSpacing.space3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.habitTimesPerWeekField,
                            style: AppTextStyles.body.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        CountStepper(
                          value: '$_timesPerWeek',
                          semanticValue: l10n.habitTimesPerWeekValue(
                            _timesPerWeek,
                          ),
                          labels: stepper,
                          onDecrease: _timesPerWeek > 1
                              ? () => setState(() => _timesPerWeek--)
                              : null,
                          onIncrease: _timesPerWeek < 7
                              ? () => setState(() => _timesPerWeek++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                  if (_reduce) ...[
                    const SizedBox(height: AppSpacing.space6),
                    RowPicker(
                      label: l10n.habitCostField,
                      value: _cost > 0
                          ? formatRupiah(_cost)
                          : l10n.habitCostSet,
                      valueMuted: _cost <= 0,
                      onTap: _editCost,
                    ),
                    if (_costError) error(l10n.habitCostError),
                    const SizedBox(height: AppSpacing.space2),
                    RowPicker(
                      label: l10n.txWallet,
                      value: _walletName(),
                      valueMuted: _walletId == null,
                      onTap: _pickWallet,
                    ),
                    if (_walletError) error(l10n.habitWalletError),
                    const SizedBox(height: AppSpacing.space2),
                    RowPicker(
                      label: l10n.habitCategoryField,
                      value: _categoryName(),
                      valueMuted: _categoryId == null,
                      onTap: _pickCategory,
                    ),
                    if (_categoryError) error(l10n.habitCategoryError),
                    const SizedBox(height: AppSpacing.space4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.habitLimitField,
                            style: AppTextStyles.body.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        CountStepper(
                          value: _weeklyLimit == null
                              ? l10n.habitLimitNone
                              : '$_weeklyLimit',
                          semanticValue: _weeklyLimit == null
                              ? l10n.habitLimitNone
                              : l10n.habitLimitValue(_weeklyLimit!),
                          labels: stepper,
                          onDecrease: _weeklyLimit == null
                              ? null
                              : () => setState(
                                  () => _weeklyLimit = _weeklyLimit == 0
                                      ? null
                                      : _weeklyLimit! - 1,
                                ),
                          onIncrease: (_weeklyLimit ?? -1) < _maxWeeklyLimit
                              ? () => setState(
                                  () => _weeklyLimit = (_weeklyLimit ?? -1) + 1,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      l10n.habitLimitHelper,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  if (habit != null) ...[
                    const SizedBox(height: AppSpacing.space8),
                    AppListGroup(
                      children: [
                        if (widget.source.hasCheckIns)
                          AppListTile(
                            title: l10n.habitArchive,
                            subtitle: l10n.habitArchiveHint,
                            showChevron: false,
                            onTap: _busy || habit.isArchived
                                ? null
                                : () => _archiveOrDelete(
                                    HabitEditAction.archived,
                                  ),
                          )
                        else
                          AppListTile(
                            title: l10n.habitDelete,
                            subtitle: l10n.habitDeleteHint,
                            destructive: true,
                            showChevron: false,
                            onTap: _busy
                                ? null
                                : () =>
                                      _archiveOrDelete(HabitEditAction.deleted),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.space3,
                  AppSpacing.screenHorizontal,
                  AppSpacing.space4,
                ),
                child: PrimaryButton(
                  label: l10n.actionSave,
                  loading: _busy,
                  onPressed: _busy ? null : _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _walletName() {
    for (final wallet in widget.source.wallets) {
      if (wallet.id == _walletId) return wallet.name;
    }
    return context.l10n.txWalletPickerTitle;
  }

  String _categoryName() {
    final l10n = context.l10n;
    for (final category in widget.source.categories) {
      if (category.id == _categoryId) return categoryName(l10n, category);
    }
    return l10n.txCategoryPickerTitle;
  }
}

/// Seven round day toggles, Monday first like every week in the app
/// (05 §4.2). Single letters on screen, full names for screen readers.
class _WeekdayChips extends StatelessWidget {
  const _WeekdayChips({required this.selected, required this.onToggle});

  final int selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final short = l10n.weekdayNames(short: true);
    final full = l10n.weekdayNames(short: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var day = 1; day <= 7; day++)
          Builder(
            builder: (context) {
              final on = selected & Weekdays.bitFor(day) != 0;
              return Semantics(
                button: true,
                selected: on,
                label: full[day - 1],
                excludeSemantics: true,
                onTap: () => onToggle(day),
                child: InkResponse(
                  onTap: () => onToggle(day),
                  radius: AppSizes.chip / 2,
                  child: Container(
                    width: AppSizes.chip,
                    height: AppSizes.chip,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: on ? colors.primary : colors.surfaceMuted,
                    ),
                    child: Text(
                      short[day - 1],
                      style: AppTextStyles.label.copyWith(
                        color: on ? colors.onPrimary : colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
