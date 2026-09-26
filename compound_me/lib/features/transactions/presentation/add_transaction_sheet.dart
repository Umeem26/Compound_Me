import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Opens the add-transaction sheet (S-11). Phase 0 only shows its title;
/// the keypad and form arrive in phase 3.
Future<void> showAddTransactionSheet(BuildContext context) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  final duration = AppDurations.resolve(
    AppDurations.sheet,
    reduceMotion: reduceMotion,
  );
  return showModalBottomSheet<void>(
    context: context,
    // Root navigator so the sheet covers the bottom navigation.
    useRootNavigator: true,
    sheetAnimationStyle: AnimationStyle(
      duration: duration,
      reverseDuration: duration,
      curve: AppDurations.sheetInCurve,
      reverseCurve: AppDurations.sheetOutCurve,
    ),
    builder: (context) => const AddTransactionSheet(),
  );
}

class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.screenHorizontal,
          end: AppSpacing.screenHorizontal,
          bottom: AppSpacing.space8,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Semantics(
            header: true,
            child: Text(
              context.l10n.navAdd,
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
