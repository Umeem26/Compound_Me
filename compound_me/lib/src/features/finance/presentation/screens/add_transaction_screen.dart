import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    
    // Cek tema untuk warna teks
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // HAPUS backgroundColor manual, ikut tema
      appBar: AppBar(
        title: const Text("Tambah Transaksi"),
        elevation: 0,
        // HAPUS backgroundColor manual
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. INPUT NOMINAL
              Text("Berapa nominalnya?", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  hintText: "0",
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  // Warna border ikut tema otomatis
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                validator: (val) => val!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 24),

              // 2. PILIH TANGGAL
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
                    // DatePicker otomatis gelap di Dark Mode
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const Divider(),

              // 3. PILIH KATEGORI (Dropdown)
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Kategori"),
                  dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white, // Warna menu dropdown
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
                          Text(cat.name), // Text otomatis putih di dark mode
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

              // 4. PILIH DOMPET (Dropdown)
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

              // 5. CATATAN
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Catatan (Opsional)",
                  icon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 40),

              // 6. TOMBOL SIMPAN
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
      final amount = double.tryParse(_amountController.text) ?? 0;
      
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