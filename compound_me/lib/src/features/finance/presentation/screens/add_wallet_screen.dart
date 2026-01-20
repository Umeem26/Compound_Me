import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

class AddWalletScreen extends ConsumerStatefulWidget {
  const AddWalletScreen({super.key});

  @override
  ConsumerState<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends ConsumerState<AddWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: "0");
  
  // Pilihan warna sederhana
  int _selectedColor = 0xFF2196F3; // Default Blue
  final List<int> _colors = [
    0xFF2196F3, // Blue
    0xFF4CAF50, // Green
    0xFFF44336, // Red
    0xFFFF9800, // Orange
    0xFF9C27B0, // Purple
    0xFF795548, // Brown
    0xFF607D8B, // Blue Grey
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Dompet Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Dompet (cth: BCA, Dompet Saku)"),
                validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Saldo Awal",
                  prefixText: "Rp ",
                ),
                validator: (val) => val!.isEmpty ? "Saldo tidak boleh kosong" : null,
              ),
              const SizedBox(height: 24),
              const Text("Pilih Warna Kartu"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: CircleAvatar(
                      backgroundColor: Color(color),
                      radius: 20,
                      child: _selectedColor == color 
                          ? const Icon(Icons.check, color: Colors.white) 
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveWallet,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text("SIMPAN DOMPET"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveWallet() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final balance = double.tryParse(_balanceController.text) ?? 0;

      await ref.read(walletListProvider.notifier).addWallet(
        name: name,
        initialBalance: balance,
        color: _selectedColor,
      );

      if (mounted) Navigator.pop(context);
    }
  }
}