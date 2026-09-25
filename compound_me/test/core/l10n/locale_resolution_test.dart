import 'package:compound_me/core/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  group('resolveAppLocale', () {
    test('uses Indonesian for id and the legacy Android code in', () {
      expect(
        resolveAppLocale([const Locale('id', 'ID')], supported),
        const Locale('id'),
      );
      expect(
        resolveAppLocale([const Locale('in')], supported),
        const Locale('id'),
      );
    });

    test('picks the first supported language in the preference list', () {
      expect(
        resolveAppLocale([
          const Locale('fr'),
          const Locale('id'),
          const Locale('en'),
        ], supported),
        const Locale('id'),
      );
    });

    test('falls back to English for other or missing languages', () {
      expect(
        resolveAppLocale([const Locale('fr')], supported),
        const Locale('en'),
      );
      expect(resolveAppLocale(null, supported), const Locale('en'));
    });
  });
}
