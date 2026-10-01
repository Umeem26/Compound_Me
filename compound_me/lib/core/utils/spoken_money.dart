import 'package:compound_me/core/utils/money.dart';
import 'package:flutter/widgets.dart';

/// Money as a screen reader should say it (03 §5): "dua puluh dua ribu
/// rupiah" / "twenty-two thousand rupiah". "Rp 22.000" read by an English
/// voice becomes "twenty-two point zero zero zero", so the numbers are
/// spelled out. Negative amounts start with "minus" and, with [signed],
/// positive ones with "plus" (like [formatRupiah]).
String spokenRupiah(
  Money value, {
  bool signed = false,
  String localeCode = 'id',
}) {
  final english = localeCode == 'en';
  final words = english ? _english(value.abs()) : _indonesian(value.abs());
  final body = '$words rupiah';
  if (value < 0) return 'minus $body';
  if (signed && value > 0) return 'plus $body';
  return body;
}

const _idUnits = [
  'nol',
  'satu',
  'dua',
  'tiga',
  'empat',
  'lima',
  'enam',
  'tujuh',
  'delapan',
  'sembilan',
  'sepuluh',
  'sebelas',
];

// Indonesian groups: "seribu" and "seratus" instead of "satu ...", and
// "sebelas"/"se..belas" for the teens.
String _indonesian(int n) {
  if (n < 12) return _idUnits[n];
  if (n < 20) return '${_idUnits[n - 10]} belas';
  if (n < 100) {
    final rest = n % 10;
    final tens = '${_idUnits[n ~/ 10]} puluh';
    return rest == 0 ? tens : '$tens ${_idUnits[rest]}';
  }
  if (n < 200) return _join('seratus', n - 100, _indonesian);
  if (n < 1000) {
    return _join('${_idUnits[n ~/ 100]} ratus', n % 100, _indonesian);
  }
  if (n < 2000) return _join('seribu', n - 1000, _indonesian);
  for (final (size, name) in _idScales) {
    if (n >= size) {
      return _join('${_indonesian(n ~/ size)} $name', n % size, _indonesian);
    }
  }
  return _join('${_indonesian(n ~/ 1000)} ribu', n % 1000, _indonesian);
}

const _idScales = [
  (1000000000000, 'triliun'),
  (1000000000, 'miliar'),
  (1000000, 'juta'),
];

const _enUnits = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];

const _enTens = [
  '',
  '',
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety',
];

const _enScales = [
  (1000000000000, 'trillion'),
  (1000000000, 'billion'),
  (1000000, 'million'),
  (1000, 'thousand'),
];

String _english(int n) {
  if (n < 20) return _enUnits[n];
  if (n < 100) {
    final rest = n % 10;
    final tens = _enTens[n ~/ 10];
    return rest == 0 ? tens : '$tens-${_enUnits[rest]}';
  }
  if (n < 1000) {
    return _join('${_enUnits[n ~/ 100]} hundred', n % 100, _english);
  }
  for (final (size, name) in _enScales) {
    if (n >= size) {
      return _join('${_english(n ~/ size)} $name', n % size, _english);
    }
  }
  return _enUnits[0];
}

String _join(String head, int rest, String Function(int) words) =>
    rest == 0 ? head : '$head ${words(rest)}';

extension SpokenMoneyContext on BuildContext {
  /// [spokenRupiah] in the language of the running app.
  String spokenMoney(Money value, {bool signed = false}) => spokenRupiah(
    value,
    signed: signed,
    localeCode: Localizations.localeOf(this).languageCode,
  );
}
