import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:compound_me/src/core/database/app_database.dart';
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
    // Ambil data untuk Dropdown
    final walletsAsync = ref.watch(walletListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Transaksi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. INPUT NOMINAL (Besar)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nominal (Rp)",
                  prefixText: "Rp ",
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(fontSize: 20),
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                validator: (val) => val!.isEmpty ? "Harus diisi" : null,
              ),
              const SizedBox(height: 16),

              // 2. TANGGAL
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
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

              // 3. DROPDOWN CATEGORY
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Kategori"),
                  value: _selectedCategoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name + (cat.type == 1 ? " (Masuk)" : " (Keluar)")),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (val) => val == null ? "Pilih kategori" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Error: $e"),
              ),
              const SizedBox(height: 16),

              // 4. DROPDOWN WALLET
              walletsAsync.when(
                data: (wallets) => DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Dari Dompet"),
                  value: _selectedWalletId,
                  items: wallets.map((w) {
                    return DropdownMenuItem(
                      value: w.id,
                      child: Text("${w.name} (Sisa: ${CurrencyFormatter.toRupiah(w.balance)})"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedWalletId = val),
                  validator: (val) => val == null ? "Pilih dompet" : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Error: $e"),
              ),
              const SizedBox(height: 16),

              // 5. CATATAN
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Catatan (Optional)",
                  icon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 32),

              // 6. TOMBOL SIMPAN
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
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
      
      // Panggil Controller untuk simpan ke DB
      await ref.read(transactionListProvider.notifier).addTransaction(
        amount: amount,
        note: _noteController.text,
        date: _selectedDate,
        categoryId: _selectedCategoryId!,
        walletId: _selectedWalletId!,
      );

      if (mounted) {
        Navigator.pop(context); // Kembali ke Home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaksi Berhasil Disimpan!")),
        );
      }
    }
  }
}