import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORT DATABASE & PROVIDER ---
import 'package:compound_me/src/core/database/app_database.dart'; 
import 'package:compound_me/src/core/database/database_provider.dart'; 
import 'package:compound_me/src/core/theme/theme_provider.dart'; // <--- IMPORT TEMA

// --- IMPORT CONTROLLERS ---
import 'package:compound_me/src/features/finance/presentation/controllers/category_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cek status tema saat ini (untuk Switch)
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      // Warna background menyesuaikan tema otomatis
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Pengaturan"),
        elevation: 0,
        // Hapus backgroundColor manual agar ikut tema AppBarTheme di main.dart
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // 1. KARTU PROFIL
          Container(
            color: Theme.of(context).cardColor, // Warna kartu ikut tema
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
                    Text("Hisyam Khaeru Umam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                    Text("241511078", style: TextStyle(color: Colors.grey)), 
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 2. MENU PENGATURAN
          Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // SAKLAR DARK MODE (SUDAH AKTIF)
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("Tema Gelap"),
                  trailing: Switch(
                    value: isDarkMode, 
                    onChanged: (val) {
                      // Ubah state global
                      ref.read(themeProvider.notifier).state = 
                          val ? ThemeMode.dark : ThemeMode.light;
                    }
                  ),
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
              
              final db = ref.read(appDatabaseProvider);
              
              await db.delete(db.transactions).go();
              await db.delete(db.habitLogs).go();
              await db.delete(db.habits).go();
              await db.delete(db.wallets).go();
              await db.delete(db.categories).go();
              
              ref.invalidate(transactionListProvider);
              ref.invalidate(walletListProvider);
              ref.invalidate(habitListProvider);
              ref.invalidate(categoryListProvider); 

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