import 'package:compound_me/core/design/components/amount_input.dart';
import 'package:compound_me/core/design/components/buttons.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet with the motion tokens (§8) on the root navigator,
/// so it covers the bottom navigation. The content moves above the
/// keyboard. Sheets that take input pass `enableDrag: false`, because a
/// drag closes the sheet past an UnsavedChangesGuard; they have no drag
/// handle then and close through a [SheetHeader] X, back, or a tap outside.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool enableDrag = true,
}) {
  final duration = AppDurations.resolve(
    AppDurations.sheet,
    reduceMotion: MediaQuery.disableAnimationsOf(context),
  );
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: enableDrag,
    showDragHandle: enableDrag,
    sheetAnimationStyle: AnimationStyle(
      duration: duration,
      reverseDuration: duration,
      curve: AppDurations.sheetInCurve,
      reverseCurve: AppDurations.sheetOutCurve,
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(top: false, child: builder(context)),
    ),
  );
}

/// Standard sheet layout: a title, then [child], with screen margins.
class SheetBody extends StatelessWidget {
  const SheetBody({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.screenHorizontal,
        end: AppSpacing.screenHorizontal,
        bottom: AppSpacing.space6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Title row of a sheet without a drag handle, with an X that closes it
/// through `Navigator.maybePop`, so an UnsavedChangesGuard still asks.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    required this.title,
    required this.closeLabel,
    this.subtitle,
    super.key,
  });

  final String title;
  final String closeLabel;

  /// A line under the title, e.g. the amount while the keypad is hidden.
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.screenHorizontal,
        end: AppSpacing.space2,
        top: AppSpacing.space2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                ?subtitle,
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: closeLabel,
            icon: const Icon(AppIcons.x),
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Amount entry sheet: display, keypad and a save button. Returns the new
/// amount, or null when dismissed.
Future<Money?> showAmountSheet(
  BuildContext context, {
  required String title,
  required Money initial,
  required String saveLabel,
  required String backspaceLabel,
}) => showAppSheet<Money>(
  context,
  builder: (context) => _AmountSheet(
    title: title,
    initial: initial,
    saveLabel: saveLabel,
    backspaceLabel: backspaceLabel,
  ),
);

class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.title,
    required this.initial,
    required this.saveLabel,
    required this.backspaceLabel,
  });

  final String title;
  final Money initial;
  final String saveLabel;
  final String backspaceLabel;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late Money _amount = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SheetBody(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AmountDisplay(amount: _amount),
          const SizedBox(height: AppSpacing.space6),
          AmountKeypad(
            amount: _amount,
            onChanged: (value) => setState(() => _amount = value),
            backspaceLabel: widget.backspaceLabel,
          ),
          const SizedBox(height: AppSpacing.space4),
          PrimaryButton(
            label: widget.saveLabel,
            onPressed: () => Navigator.of(context).pop(_amount),
          ),
        ],
      ),
    );
  }
}

/// One choice in [showOptionSheet]; [leading] replaces [icon] when both
/// are given, e.g. a colored badge.
class SheetOption<T> {
  const SheetOption({
    required this.value,
    required this.label,
    this.icon,
    this.leading,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Widget? leading;
}

/// Single choice list in a sheet, the current value marked with a check.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetOption<T>> options,
  required T selected,
}) => showAppSheet<T>(
  context,
  builder: (context) {
    final colors = context.tokens.colors;
    return SheetBody(
      title: title,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final option in options)
            Semantics(
              selected: option.value == selected,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.sm),
                ),
                onTap: () => Navigator.of(context).pop(option.value),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppSizes.row),
                  child: Row(
                    children: [
                      if (option.leading != null) ...[
                        option.leading!,
                        const SizedBox(width: AppSpacing.space3),
                      ] else if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: AppSizes.iconMd,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: AppSpacing.space3),
                      ],
                      Expanded(
                        child: Text(
                          option.label,
                          style: AppTextStyles.body.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (option.value == selected)
                        Icon(
                          AppIcons.check,
                          size: AppSizes.iconMd,
                          color: colors.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  },
);

/// Calendar in a sheet (S-11 date row). Returns the picked day at local
/// midnight, or null when dismissed.
Future<DateTime?> showDateSheet(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required DateTime first,
  required DateTime last,
}) => showAppSheet<DateTime>(
  context,
  builder: (context) => SheetBody(
    title: title,
    child: CalendarDatePicker(
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      onDateChanged: (day) => Navigator.of(context).pop(day),
    ),
  ),
);
