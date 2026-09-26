import 'package:compound_me/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRupiah', () {
    test('uses Rp, a space and dots for thousands (05 §4.1)', () {
      expect(formatRupiah(22000), 'Rp 22.000');
      expect(formatRupiah(1250000), 'Rp 1.250.000');
      expect(formatRupiah(0), 'Rp 0');
      expect(formatRupiah(999), 'Rp 999');
    });

    test('keeps the Indonesian format in English too', () {
      expect(formatRupiah(25000, localeCode: 'en'), 'Rp 25.000');
    });

    test('signed shows + for income and − for expenses', () {
      expect(formatRupiah(22000, signed: true), '+Rp 22.000');
      expect(formatRupiah(-22000, signed: true), '−Rp 22.000');
      expect(formatRupiah(0, signed: true), 'Rp 0');
    });

    test('negative values always carry the minus sign', () {
      expect(formatRupiah(-1500), '−Rp 1.500');
    });

    test('compact uses rb / jt / M in Indonesian', () {
      expect(formatRupiah(22000, compact: true), '22 rb');
      expect(formatRupiah(1200000, compact: true), '1,2 jt');
      expect(formatRupiah(2500000000, compact: true), '2,5 M');
      expect(formatRupiah(500, compact: true), '500');
    });

    test('compact uses K / M / B in English', () {
      expect(formatRupiah(22000, compact: true, localeCode: 'en'), '22K');
      expect(formatRupiah(1200000, compact: true, localeCode: 'en'), '1.2M');
      expect(formatRupiah(2500000000, compact: true, localeCode: 'en'), '2.5B');
    });

    test('compact rounds to one decimal and moves up a unit at 1000', () {
      expect(formatRupiah(22450, compact: true), '22,5 rb');
      expect(formatRupiah(1000000, compact: true), '1 jt');
      expect(formatRupiah(999950, compact: true), '1 jt');
      expect(formatRupiah(-1200000, compact: true), '−1,2 jt');
    });
  });
}
