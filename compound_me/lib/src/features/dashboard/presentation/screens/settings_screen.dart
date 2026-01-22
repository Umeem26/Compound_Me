import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/core/database/app_database.dart';

// --- IMPORT YANG TADI KURANG ---
import 'package:compound_me/src/core/database/database_provider.dart'; // Untuk akses Database langsung
import 'package:compound_me/src/features/finance/presentation/controllers/category_controller.dart'; // Untuk refresh Kategori
// ------------------------------

import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Pengaturan"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // 1. KARTU PROFIL
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Hisyam Khaeru Umam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Update Nama Kamu
                    Text("241511078", style: TextStyle(color: Colors.grey)), // Update NIM Kamu
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 2. MENU PENGATURAN
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("Tema Gelap"),
                  trailing: Switch(value: false, onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fitur Dark Mode akan hadir segera!")),
                    );
                  }),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Tentang Aplikasi"),
                  subtitle: const Text("CompoundMe v1.0.0"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 3. DANGER ZONE (Tombol Reset)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
                elevation: 0,
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text("Reset Semua Data (Bahaya)"),
              onPressed: () => _showResetDialog(context, ref),
            ),
          ),
          
          const SizedBox(height: 20),
          const Center(child: Text("Made with ❤️ by CompoundMe Team", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus SEMUA Data?"),
        content: const Text("Tindakan ini tidak bisa dibatalkan. Dompet, Transaksi, dan Habits akan hilang selamanya."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              
              // LOGIKA MENGHAPUS SEMUA TABEL
              final db = ref.read(appDatabaseProvider);
              
              await db.delete(db.transactions).go();
              await db.delete(db.habitLogs).go();
              await db.delete(db.habits).go();
              await db.delete(db.wallets).go();
              await db.delete(db.categories).go();
              
              // Refresh semua provider agar UI kembali kosong
              ref.invalidate(transactionListProvider);
              ref.invalidate(walletListProvider);
              ref.invalidate(habitListProvider);
              ref.invalidate(categoryListProvider); // Ini akan memicu Seeder ulang otomatis!

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Aplikasi telah di-reset ke kondisi awal.")),
                );
              }
            }, 
            child: const Text("Ya, Hapus Semuanya"),
          ),
        ],
      ),
    );
  }
}