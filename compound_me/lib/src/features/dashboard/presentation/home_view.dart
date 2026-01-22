import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';
import 'package:compound_me/src/features/finance/presentation/screens/add_transaction_screen.dart';
import 'package:compound_me/src/features/finance/presentation/screens/add_wallet_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/widgets/expense_pie_chart.dart';
// IMPORT BARU
import 'package:compound_me/src/features/dashboard/presentation/widgets/month_picker.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    final transactionsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("CompoundMe", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Tambah Transaksi",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
            }, 
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN 0: PILIH BULAN (TIME TRAVEL) ---
            const Center(child: MonthPicker()), 
            const SizedBox(height: 20),

            // --- BAGIAN 1: TOTAL SALDO ---
            _buildTotalBalanceCard(walletsAsync),

            const SizedBox(height: 24),
            const Text("Dompet Saya", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWalletList(walletsAsync, ref),
            
            const SizedBox(height: 24),
            // Pie Chart (Otomatis ikut berubah sesuai bulan yg dipilih)
            const ExpensePieChart(),
            
            const SizedBox(height: 24),
            const Text("Transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTransactionList(transactionsAsync, ref, context),
          ],
        ),
      ),
    );
  }

  // ... (SISA KODE KE BAWAH TETAP SAMA SEPERTI SEBELUMNYA) ...
  // (Copy saja method _buildTotalBalanceCard, _buildWalletList, _buildTransactionList dari kode sebelumnya)
  
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

  Widget _buildWalletList(AsyncValue<List<dynamic>> walletsAsync, WidgetRef ref) {
    return SizedBox(
      height: 120, 
      child: walletsAsync.when(
        data: (wallets) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wallets.length + 1, 
            itemBuilder: (context, index) {
              if (index == wallets.length) {
                return _buildAddWalletButton(ref);
              }
              final wallet = wallets[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
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
                    Text(CurrencyFormatter.toRupiah(wallet.balance), style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildAddWalletButton(WidgetRef ref) {
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
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
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
                color: Colors.white,
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