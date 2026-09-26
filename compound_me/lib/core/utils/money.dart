/// Money is whole Rupiah. Integers avoid floating point errors entirely and
/// Rupiah has no cents in daily use (05 §1).
typedef Money = int;

const _minusSign = '−';

/// The only way to turn money into text (05 §4.1).
///
/// - `formatRupiah(22000)` → `Rp 22.000` in every language (IDR format).
/// - `signed: true` → `+Rp 22.000`; negative values always get `−`.
/// - `compact: true` (chart axes and labels only) → `22 rb` / `1,2 jt` for
///   Indonesian, `22K` / `1.2M` for English, without the `Rp` prefix.
String formatRupiah(
  Money value, {
  bool signed = false,
  bool compact = false,
  String localeCode = 'id',
}) {
  final magnitude = value.abs();
  final body = compact
      ? _compact(magnitude, english: localeCode == 'en')
      : 'Rp ${_groupThousands(magnitude)}';
  if (value < 0) return '$_minusSign$body';
  if (signed && value > 0) return '+$body';
  return body;
}

String _groupThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

const _idUnits = [(1000000000, ' M'), (1000000, ' jt'), (1000, ' rb')];
const _enUnits = [(1000000000, 'B'), (1000000, 'M'), (1000, 'K')];

String _compact(int value, {required bool english}) {
  final units = english ? _enUnits : _idUnits;
  for (var i = 0; i < units.length; i++) {
    final (size, suffix) = units[i];
    if (value < size) continue;
    final tenths = (value * 10 / size).round();
    // 999.950 rounds to "1000 rb"; show it in the next unit instead.
    if (tenths >= 10000 && i > 0) {
      final (biggerSize, biggerSuffix) = units[i - 1];
      return _withSuffix(
        (value * 10 / biggerSize).round(),
        biggerSuffix,
        english,
      );
    }
    return _withSuffix(tenths, suffix, english);
  }
  return value.toString();
}

String _withSuffix(int tenths, String suffix, bool english) {
  final whole = tenths ~/ 10;
  final decimal = tenths % 10;
  final separator = english ? '.' : ',';
  final number = decimal == 0 ? '$whole' : '$whole$separator$decimal';
  return '$number$suffix';
}
