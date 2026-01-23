import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 1. Jika input kosong, biarkan kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Hapus semua karakter selain angka (misal titik yg lama)
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Cegah error jika hasil cleanText kosong
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    // 3. Ubah ke Angka lalu Format ulang dengan titik
    // Locale 'id_ID' otomatis pakai titik sebagai pemisah ribuan
    final int value = int.parse(cleanText);
    final formatter = NumberFormat('#,###', 'id_ID'); 
    final String newText = formatter.format(value);

    // 4. Kembalikan teks baru dengan kursor tetap di ujung kanan
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
  
  // Fungsi statis untuk mengubah "10.000" kembali jadi angka murni (10000)
  static double toDouble(String formattedText) {
    if (formattedText.isEmpty) return 0;
    // Hapus titik, lalu parse ke double
    return double.tryParse(formattedText.replaceAll('.', '')) ?? 0;
  }
}