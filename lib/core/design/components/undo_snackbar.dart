import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// Shows the floating "Dicatat · Urungkan" snackbar (§7.6). Used instead of
/// confirmation dialogs for anything that can be undone.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUndoSnackbar(
  BuildContext context, {
  required String message,
  required String undoLabel,
  required VoidCallback onUndo,
}) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      // Kept explicit so the undo window stays tied to the token even if the
      // Material default duration changes.
      // ignore: avoid_redundant_argument_values
      duration: AppDurations.undoWindow,
      // The visual surface is drawn by UndoSnackbar so the shadow can follow
      // the design token instead of Material elevation.
      backgroundColor: context.tokens.colors.inverseSurface.withValues(
        alpha: 0,
      ),
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.space3,
      ),
      content: UndoSnackbar(
        message: message,
        undoLabel: undoLabel,
        onUndo: () {
          messenger.hideCurrentSnackBar();
          onUndo();
        },
      ),
    ),
  );
}

class UndoSnackbar extends StatelessWidget {
  const UndoSnackbar({
    required this.message,
    required this.undoLabel,
    required this.onUndo,
    super.key,
  });

  final String message;
  final String undoLabel;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
        boxShadow: tokens.floatingShadow,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.space4,
          end: AppSpacing.space1,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.space3,
                ),
                child: Text(
                  message,
                  style: AppTextStyles.body.copyWith(
                    color: colors.onInverseSurface,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: onUndo,
              style: TextButton.styleFrom(
                foregroundColor: colors.inversePrimary,
                minimumSize: const Size(
                  AppSizes.minTouchTarget,
                  AppSizes.minTouchTarget,
                ),
                textStyle: AppTextStyles.label,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
                ),
              ),
              child: Text(undoLabel),
            ),
          ],
        ),
      ),
    );
  }
}
