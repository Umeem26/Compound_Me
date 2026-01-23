import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';
import 'package:compound_me/src/features/finance/presentation/screens/add_wallet_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/widgets/month_picker.dart';

// Hapus import add_transaction_screen karena sudah pindah ke main_screen

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    final transactionsAsync = ref.watch(transactionListProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CompoundMe", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        // TOMBOL TAMBAH DIHAPUS DARI SINI
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: MonthPicker()), 
            const SizedBox(height: 20),

            _buildTotalBalanceCard(walletsAsync),

            const SizedBox(height: 24),
            const Text("Dompet Saya", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWalletList(walletsAsync, ref, context),
            
            const SizedBox(height: 24),
            
            const SizedBox(height: 24),
            const Text("Transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTransactionList(transactionsAsync, ref, context),
            
            // Tambahan ruang di bawah agar list paling bawah tidak tertutup tombol FAB
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  // ... (SISA KODE WIDGET KE BAWAH SAMA PERSIS SEPERTI SEBELUMNYA) ...
  // _buildTotalBalanceCard, _buildWalletList, _buildTransactionList, _buildAddWalletButton
  // Pastikan copy function-function tersebut dari kode sebelumnya.

  Widget _buildTotalBalanceCard(AsyncValue<List<dynamic>> walletsAsync) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Aset", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          walletsAsync.when(
            data: (wallets) {
              final total = wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
              return Text(
                CurrencyFormatter.toRupiah(total),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              );
            },
            loading: () => const CircularProgressIndicator(color: Colors.white),
            error: (err, stack) => Text("Error: $err", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletList(AsyncValue<List<dynamic>> walletsAsync, WidgetRef ref, BuildContext context) {
    return SizedBox(
      height: 120, 
      child: walletsAsync.when(
        data: (wallets) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wallets.length + 1, 
            itemBuilder: (context, index) {
              if (index == wallets.length) {
                return _buildAddWalletButton(ref, context);
              }
              final wallet = wallets[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(wallet.color).withOpacity(0.2),
                      child: Icon(Icons.wallet, color: Color(wallet.color)),
                    ),
                    const Spacer(),
                    Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text(
                      CurrencyFormatter.toRupiah(wallet.balance), 
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text("Gagal memuat dompet"),
      ),
    );
  }

  Widget _buildAddWalletButton(WidgetRef ref, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWalletScreen()));
          },
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: const Center(child: Icon(Icons.add, color: Colors.grey)),
          ),
        );
      }
    );
  }

  Widget _buildTransactionList(AsyncValue<List<dynamic>> transactionsAsync, WidgetRef ref, BuildContext context) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.center,
            child: const Text("Belum ada transaksi di bulan ini.", style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final trx = transactions[index];
            final isExpense = trx.amount < 0; 

            return Dismissible(
              key: Key(trx.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Hapus Transaksi?"),
                    content: const Text("Saldo dompet akan dikembalikan seperti semula."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                ref.read(transactionListProvider.notifier).deleteTransaction(trx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaksi dihapus & Saldo dikembalikan!")));
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                color: Theme.of(context).cardColor, 
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    child: Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward, 
                      color: isExpense ? Colors.red : Colors.green,
                    )
                  ),
                  title: Text(trx.note ?? "Auto-Habit"),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(trx.date)),
                  trailing: Text(
                    CurrencyFormatter.toRupiah(trx.amount),
                    style: TextStyle(
                      color: isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text("Gagal memuat transaksi"),
    );
  }
}