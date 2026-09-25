import 'package:compound_me/core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:compound_me/core/l10n/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Follows the device language: Indonesian when the device prefers it,
/// English for everything else. Older Android versions report Indonesian as
/// the legacy code "in".
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    switch (locale.languageCode) {
      case 'id' || 'in':
        return const Locale('id');
      case 'en':
        return const Locale('en');
    }
  }
  return const Locale('en');
}
