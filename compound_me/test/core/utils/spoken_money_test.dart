import 'package:compound_me/core/utils/spoken_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Indonesian', () {
    test('spells out amounts the way people say them', () {
      expect(spokenRupiah(0), 'nol rupiah');
      expect(spokenRupiah(100), 'seratus rupiah');
      expect(spokenRupiah(1000), 'seribu rupiah');
      expect(spokenRupiah(11000), 'sebelas ribu rupiah');
      expect(spokenRupiah(22000), 'dua puluh dua ribu rupiah');
      expect(spokenRupiah(25000), 'dua puluh lima ribu rupiah');
      expect(spokenRupiah(112500), 'seratus dua belas ribu lima ratus rupiah');
      expect(
        spokenRupiah(1250000),
        'satu juta dua ratus lima puluh ribu rupiah',
      );
      expect(
        spokenRupiah(1950000),
        'satu juta sembilan ratus lima puluh ribu rupiah',
      );
      expect(spokenRupiah(1500000000), 'satu miliar lima ratus juta rupiah');
    });

    test('marks the direction of signed amounts', () {
      expect(spokenRupiah(-22000), 'minus dua puluh dua ribu rupiah');
      expect(spokenRupiah(500000, signed: true), 'plus lima ratus ribu rupiah');
      expect(spokenRupiah(500000), 'lima ratus ribu rupiah');
    });
  });

  group('English', () {
    test('spells out amounts', () {
      expect(spokenRupiah(0, localeCode: 'en'), 'zero rupiah');
      expect(spokenRupiah(1000, localeCode: 'en'), 'one thousand rupiah');
      expect(
        spokenRupiah(22000, localeCode: 'en'),
        'twenty-two thousand rupiah',
      );
      expect(
        spokenRupiah(1250000, localeCode: 'en'),
        'one million two hundred fifty thousand rupiah',
      );
      expect(
        spokenRupiah(-3500000, localeCode: 'en'),
        'minus three million five hundred thousand rupiah',
      );
      expect(
        spokenRupiah(75, signed: true, localeCode: 'en'),
        'plus seventy-five rupiah',
      );
    });
  });
}
