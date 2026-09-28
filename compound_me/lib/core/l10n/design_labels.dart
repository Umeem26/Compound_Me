import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/l10n.dart';

/// Translated labels that design components take as parameters.
extension DesignLabels on AppLocalizations {
  String presetColorName(AppPresetColor color) => switch (color) {
    AppPresetColor.teal => presetTeal,
    AppPresetColor.gold => presetGold,
    AppPresetColor.coral => presetCoral,
    AppPresetColor.violet => presetViolet,
    AppPresetColor.blue => presetBlue,
    AppPresetColor.green => presetGreen,
    AppPresetColor.rose => presetRose,
    AppPresetColor.slate => presetSlate,
  };

  AsyncErrorLabels get loadErrorLabels =>
      (title: errorLoadTitle, message: errorLoadBody, retry: actionRetry);

  DiscardLabels get discardLabels => (
    title: discardTitle,
    message: discardBody,
    discard: discardAction,
    keepEditing: keepEditingAction,
  );
}
