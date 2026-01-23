import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Import Wajib

// Import Formatter Baru
import 'package:compound_me/src/core/utils/currency_input_formatter.dart'; 

import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/category_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedWalletId;
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Transaksi"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Berapa nominalnya?", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                
                // PASANG FORMATTER DI SINI
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Hanya angka
                  CurrencyInputFormatter(), // Format Titik Otomatis
                ],

                decoration: const InputDecoration(
                  prefixText: "Rp ",
                  hintText: "0",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                validator: (val) => val!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 24),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Tanggal", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600])),
                subtitle: Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const Divider(),

              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Kategori"),
                  dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
                  value: _selectedCategoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Row(
                        children: [
                          Icon(
                            cat.type == 0 ? Icons.arrow_upward : Icons.arrow_downward, 
                            color: cat.type == 0 ? Colors.red : Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(cat.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (val) => val == null ? "Pilih kategori dulu" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Gagal load kategori: $e"),
              ),
              const SizedBox(height: 16),

              walletsAsync.when(
                data: (wallets) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Pakai Dompet Mana?"),
                  dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
                  value: _selectedWalletId,
                  items: wallets.map((w) {
                    return DropdownMenuItem(
                      value: w.id,
                      child: Text("${w.name} (Saldo: ${CurrencyFormatter.toRupiah(w.balance)})"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedWalletId = val),
                  validator: (val) => val == null ? "Pilih dompet dulu" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Gagal load dompet: $e"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Catatan (Opsional)",
                  icon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveTransaction,
                  child: const Text("SIMPAN TRANSAKSI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      // BERSIHKAN FORMAT: "5.000.000" -> 5000000.0
      final amount = CurrencyInputFormatter.toDouble(_amountController.text);
      
      await ref.read(transactionListProvider.notifier).addTransaction(
        amount: amount,
        note: _noteController.text,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
      );

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi berhasil disimpan!"),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }
}