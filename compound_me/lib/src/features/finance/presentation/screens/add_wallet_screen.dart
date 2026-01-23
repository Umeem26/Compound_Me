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
  final _balanceController = TextEditingController();
  
  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.brown
  ];
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Dompet"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nama Dompet"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Contoh: BCA, Dompet Saku, Gopay",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 20),

              const Text("Saldo Awal"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: "Rp ",
                  hintText: "0",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? "Saldo harus diisi (min. 0)" : null,
              ),
              const SizedBox(height: 20),

              const Text("Pilih Warna"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(_colors.length, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: CircleAvatar(
                      backgroundColor: _colors[index],
                      radius: 20,
                      child: _selectedColorIndex == index 
                        ? const Icon(Icons.check, color: Colors.white) 
                        : null,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _saveWallet,
                  child: const Text("SIMPAN DOMPET", style: TextStyle(fontWeight: FontWeight.bold)),
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
      
      // PERBAIKAN: Ambil value int dari warna untuk disimpan ke DB
      final colorInt = _colors[_selectedColorIndex].value; 

      // PERBAIKAN: Gunakan 'initialBalance' (bukan 'balance') sesuai Controller
      await ref.read(walletListProvider.notifier).addWallet(
        name: name, 
        initialBalance: balance, // <--- INI PERBAIKANNYA
        color: colorInt
      );

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}