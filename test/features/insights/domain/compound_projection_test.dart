import 'package:compound_me/features/insights/domain/compound_projection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompoundProjection', () {
    test('r = 0 is simply the deposits added up', () {
      expect(
        CompoundProjection.futureValue(
          monthlyDeposit: 100000,
          annualRate: 0,
          years: 3,
        ),
        3600000,
      );
    });

    test('matches the hand-checked example: P 100.000, r 5%, n 1', () {
      // 100000 × ((1 + 0.05/12)^12 − 1) / (0.05/12) = 1.227.885,5...
      expect(
        CompoundProjection.futureValue(
          monthlyDeposit: 100000,
          annualRate: 0.05,
          years: 1,
        ),
        closeTo(1227886, 1),
      );
    });

    test('rounds projected savings to the nearest thousand', () {
      expect(
        CompoundProjection.projectedSavings(
          annualSavings: 1200000,
          annualRate: 0.05,
          years: 1,
        ),
        1228000,
      );
      expect(
        CompoundProjection.projectedSavings(
          annualSavings: 1200000,
          annualRate: 0,
          years: 5,
        ),
        6000000,
      );
    });

    test('longer horizons grow faster than linearly', () {
      Map<int, int> project(double rate) => {
        for (final n in CompoundProjection.horizons)
          n: CompoundProjection.projectedSavings(
            annualSavings: 1200000,
            annualRate: rate,
            years: n,
          ),
      };
      final flat = project(0);
      final compound = project(0.05);

      expect(CompoundProjection.horizons, [1, 3, 5]);
      for (final n in CompoundProjection.horizons) {
        expect(compound[n], greaterThan(flat[n]!));
      }
      expect(compound[5]! - flat[5]!, greaterThan(compound[1]! - flat[1]!));
    });

    test('rounds half-thousands up', () {
      expect(CompoundProjection.roundToThousand(1500), 2000);
      expect(CompoundProjection.roundToThousand(1499.9), 1000);
    });
  });
}
