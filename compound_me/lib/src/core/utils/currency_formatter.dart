import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String toRupiah(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0, // Tidak perlu sen
    );
    return format.format(amount);
  }
}