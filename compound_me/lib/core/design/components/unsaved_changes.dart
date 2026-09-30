import 'package:compound_me/core/design/theme.dart';
import 'package:flutter/material.dart';

/// Text of the "Buang perubahan?" confirmation.
typedef DiscardLabels = ({
  String title,
  String message,
  String discard,
  String keepEditing,
});

/// Asks before throwing away unsaved input (03 §4). Returns true when the
/// user chooses to discard. A dialog, because discarding can't be undone.
Future<bool> confirmDiscardChanges(
  BuildContext context,
  DiscardLabels labels,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => _DiscardDialog(labels: labels),
    ) ??
    false;

class _DiscardDialog extends StatelessWidget {
  const _DiscardDialog({required this.labels});

  final DiscardLabels labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return AlertDialog(
      title: Text(labels.title),
      content: Text(labels.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(labels.keepEditing),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(labels.discard),
        ),
      ],
    );
  }
}

/// Guards a sheet or an editor screen (S-11, S-21, S-41, S-42). While
/// [hasChanges], the system back button, a close button that calls
/// `Navigator.maybePop` and a tap outside a sheet all ask
/// [confirmDiscardChanges] first. Saving should leave with
/// `Navigator.pop`, which skips the guard.
///
/// Sheets: dragging a modal sheet down closes it with `Navigator.pop`
/// (Flutter 3.47), past this guard, so open sheets that take input with
/// `showAppSheet(enableDrag: false)`.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    required this.hasChanges,
    required this.labels,
    required this.child,
    super.key,
  });

  final bool hasChanges;
  final DiscardLabels labels;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !hasChanges,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final navigator = Navigator.of(context);
      if (await confirmDiscardChanges(context, labels) && navigator.mounted) {
        navigator.pop(result);
      }
    },
    child: child,
  );
}
