import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; 
import 'package:compound_me/src/core/database/app_database.dart'; // Import DB
import 'package:compound_me/src/core/utils/currency_input_formatter.dart'; 

import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/category_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  // Tambahkan parameter opsional untuk mode EDIT
  final Transaction? transactionToEdit;
  
  const AddTransactionScreen({super.key, this.transactionToEdit});

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
  void initState() {
    super.initState();
    // JIKA MODE EDIT: Isi form dengan data lama
    if (widget.transactionToEdit != null) {
      final trx = widget.transactionToEdit!;
      
      // Format angka (hapus minus jika ada, karena input selalu positif)
      final positiveAmount = trx.amount.abs();
      _amountController.text = NumberFormat('#,###', 'id_ID').format(positiveAmount);
      
      _noteController.text = trx.note ?? "";
      _selectedDate = trx.date;
      _selectedWalletId = trx.walletId;
      _selectedCategoryId = trx.categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Ubah Judul jika sedang Edit
    final isEditMode = widget.transactionToEdit != null;
    final title = isEditMode ? "Edit Transaksi" : "Tambah Transaksi";
    final buttonText = isEditMode ? "UPDATE PERUBAHAN" : "SIMPAN TRANSAKSI";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, 
                  CurrencyInputFormatter(), 
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
                  child: Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      final amount = CurrencyInputFormatter.toDouble(_amountController.text);
      final note = _noteController.text;
      
      // LOGIKA SIMPAN
      if (widget.transactionToEdit != null) {
        // --- MODE EDIT ---
        await ref.read(transactionListProvider.notifier).editTransaction(
          id: widget.transactionToEdit!.id,
          newAmount: amount,
          newNote: note,
          newDate: _selectedDate,
          newCategoryId: _selectedCategoryId!,
          newWalletId: _selectedWalletId!,
          // Kirim data lama untuk koreksi saldo dompet
          oldAmount: widget.transactionToEdit!.amount,
          oldWalletId: widget.transactionToEdit!.walletId,
        );
      } else {
        // --- MODE TAMBAH BARU ---
        await ref.read(transactionListProvider.notifier).addTransaction(
          amount: amount,
          note: note,
          date: _selectedDate,
          categoryId: _selectedCategoryId!,
          walletId: _selectedWalletId!,
        );
      }

      // Refresh data dompet juga biar sinkron
      ref.invalidate(walletListProvider);

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transactionToEdit != null ? "Data berhasil di-update!" : "Transaksi berhasil disimpan!"),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }
}