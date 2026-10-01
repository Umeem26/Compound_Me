import 'dart:async';
import 'dart:developer' as developer;

import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/features/settings/data/debug_sample_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug-only group in Settings (06 §2 phase 5). Settings builds it only
/// under `kDebugMode`, so it, and the sample data code behind it, are not
/// part of release builds.
class DebugTools extends ConsumerStatefulWidget {
  const DebugTools({super.key});

  @override
  ConsumerState<DebugTools> createState() => _DebugToolsState();
}

class _DebugToolsState extends ConsumerState<DebugTools> {
  bool _busy = false;

  Future<void> _fill() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    String message;
    try {
      final added = await ref.read(debugSampleDataProvider).fill();
      message = added ? l10n.debugSampleDone : l10n.debugSampleExists;
    } on Object catch (error, stackTrace) {
      developer.log(
        'Filling sample data failed',
        name: 'compound_me',
        error: error,
        stackTrace: stackTrace,
      );
      message = l10n.errorSaveFailed;
    }
    if (mounted) setState(() => _busy = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppListGroup(
      title: l10n.settingsGroupDebug,
      children: [
        AppListTile(
          title: l10n.debugSampleTitle,
          subtitle: l10n.debugSampleHint,
          showChevron: false,
          trailing: _busy
              ? const SizedBox.square(
                  dimension: AppSizes.spinner,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizes.spinnerStroke,
                  ),
                )
              : null,
          onTap: _busy ? null : () => unawaited(_fill()),
        ),
      ],
    );
  }
}
