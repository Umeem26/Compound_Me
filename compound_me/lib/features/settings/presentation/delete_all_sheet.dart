import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/settings/application/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Hapus semua data" (PRD F-10): two steps, the second asks for the word
/// HAPUS / DELETE. The only confirmation in the app, because it is the only
/// action that cannot be undone (03 §4).
Future<void> showDeleteAllSheet(BuildContext context) =>
    showAppSheet<void>(context, builder: (context) => const _DeleteAllSheet());

class _DeleteAllSheet extends ConsumerStatefulWidget {
  const _DeleteAllSheet();

  @override
  ConsumerState<_DeleteAllSheet> createState() => _DeleteAllSheetState();
}

class _DeleteAllSheetState extends ConsumerState<_DeleteAllSheet> {
  final _word = TextEditingController();
  bool _confirming = false;
  bool _deleting = false;

  @override
  void dispose() {
    _word.dispose();
    super.dispose();
  }

  bool get _wordMatches =>
      _word.text.trim().toUpperCase() == context.l10n.deleteAllWord;

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.errorSaveFailed;
    setState(() => _deleting = true);
    try {
      await ref.read(deleteAllDataProvider.notifier).run();
      navigator.pop();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    return SheetBody(
      title: l10n.deleteAllTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.deleteAllBody,
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space6),
          if (!_confirming)
            DestructiveButton(
              label: l10n.deleteAllContinue,
              onPressed: () => setState(() => _confirming = true),
            )
          else ...[
            AppTextField(
              label: l10n.deleteAllTypeLabel(l10n.deleteAllWord),
              controller: _word,
              hintText: l10n.deleteAllWord,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.space4),
            DestructiveButton(
              label: l10n.settingsDeleteAll,
              loading: _deleting,
              onPressed: _wordMatches ? _delete : null,
            ),
          ],
          const SizedBox(height: AppSpacing.space2),
          GhostButton(
            label: l10n.actionCancel,
            expand: true,
            onPressed: _deleting ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
