import 'dart:math' as math;

import 'package:compound_me/core/utils/money.dart';

/// "Tabung & kembangkan": saving the money a habit costs every month, with
/// monthly compound interest (05 §4.4). A simulation, never advice; the UI
/// always shows the disclaimer next to it.
abstract final class CompoundProjection {
  /// Years shown in the simulator (S-31).
  static const horizons = [1, 3, 5];

  /// Future value of a fixed monthly deposit.
  ///
  /// r = 0: `FV = P × 12n`; r > 0: `FV = P × ((1 + r/12)^(12n) − 1) / (r/12)`.
  static double futureValue({
    required double monthlyDeposit,
    required double annualRate,
    required int years,
  }) {
    final months = 12 * years;
    if (annualRate == 0) return monthlyDeposit * months;
    final monthlyRate = annualRate / 12;
    return monthlyDeposit *
        (math.pow(1 + monthlyRate, months) - 1) /
        monthlyRate;
  }

  /// Projection for [annualSavings] set aside as equal monthly deposits,
  /// rounded to the nearest thousand Rupiah.
  static Money projectedSavings({
    required Money annualSavings,
    required double annualRate,
    required int years,
  }) => roundToThousand(
    futureValue(
      monthlyDeposit: annualSavings / 12,
      annualRate: annualRate,
      years: years,
    ),
  );

  static Money roundToThousand(double value) => (value / 1000).round() * 1000;
}
