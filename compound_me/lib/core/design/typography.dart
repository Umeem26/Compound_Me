import 'package:flutter/painting.dart';

/// Type scale from docs/v2/02-design-system.md §4. Styles carry no color;
/// widgets apply a role color from `context.tokens.colors`.
abstract final class AppTextStyles {
  static const String fontFamily = 'PlusJakartaSans';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextStyle amountHero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    height: 40 / 34,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w700,
    fontFeatures: _tabular,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 30 / 24,
    letterSpacing: -0.3,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  /// The only style allowed in all caps ("TOTAL SALDO").
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w600,
  );
}

extension TabularFigures on TextStyle {
  /// Every money amount must use tabular digits so columns line up in lists.
  TextStyle get tabular => copyWith(fontFeatures: AppTextStyles._tabular);
}
