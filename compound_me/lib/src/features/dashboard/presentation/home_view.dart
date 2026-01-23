import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Pake Font Baru

import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';
import 'package:compound_me/src/features/finance/presentation/screens/add_wallet_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/widgets/month_picker.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    final transactionsAsync = ref.watch(transactionListProvider);
    
    return Scaffold(
      // Kita pakai SafeArea + Column custom sbg pengganti AppBar standar
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER CUSTOM (Greeting)
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // 2. MONTH PICKER (Clean Style)
              const Center(child: MonthPicker()), 
              const SizedBox(height: 20),

              // 3. PREMIUM BALANCE CARD
              _buildPremiumTotalCard(walletsAsync, context),

              const SizedBox(height: 30),
              
              // 4. WALLETS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dompet Saya", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWalletScreen())),
                    child: Text("+ Tambah", style: GoogleFonts.poppins(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWalletList(walletsAsync, ref, context),
              
              const SizedBox(height: 30),
              
              // 5. TRANSACTIONS HEADER
              Text("Riwayat Transaksi", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildTransactionList(transactionsAsync, ref, context),
              
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET: Header Greeting
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat Datang, 👋", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            Text(
              "Hisyam K.U", // Ganti Nama Panggilanmu
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        )
      ],
    );
  }

  // WIDGET: Kartu Saldo "Premium"
  Widget _buildPremiumTotalCard(AsyncValue<List<dynamic>> walletsAsync, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Gradasi Elegan
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF4DB6AC)], // Teal Tua ke Muda
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi Lingkaran Transparan (Pattern)
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -40,
            right: 40,
            child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.1)),
          ),

          // Konten Utama
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.8), size: 18),
                  const SizedBox(width: 8),
                  Text("Total Aset Bersih", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              walletsAsync.when(
                data: (wallets) {
                  final total = wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
                  return FittedBox( // Agar teks tidak terpotong kalau angkanya miliaran
                    child: Text(
                      CurrencyFormatter.toRupiah(total),
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                loading: () => const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: Colors.white)),
                error: (_, __) => const Text("---", style: TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("Financial Freedom 🚀", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              )
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET: List Wallet (Clean Style)
  Widget _buildWalletList(AsyncValue<List<dynamic>> walletsAsync, WidgetRef ref, BuildContext context) {
    return SizedBox(
      height: 140, 
      child: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
             return Center(child: Text("Belum ada dompet", style: GoogleFonts.poppins(color: Colors.grey)));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wallets.length, 
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(wallet.color).withOpacity(0.15),
                      child: Icon(Icons.wallet, color: Color(wallet.color)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wallet.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.toRupiah(wallet.balance), 
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox(),
      ),
    );
  }

  // WIDGET: Transaction List (Grouped Feel)
  Widget _buildTransactionList(AsyncValue<List<dynamic>> transactionsAsync, WidgetRef ref, BuildContext context) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Belum ada transaksi bulan ini", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
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
                margin: const EdgeInsets.only(bottom: 12),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Hapus?"),
                    content: const Text("Saldo akan dikembalikan."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                ref.read(transactionListProvider.notifier).deleteTransaction(trx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ]
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, 
                      color: isExpense ? Colors.red : Colors.green,
                      size: 20,
                    ),
                  ),
                  title: Text(trx.note?.isNotEmpty == true ? trx.note! : "Transaksi", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(trx.date), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  trailing: Text(
                    CurrencyFormatter.toRupiah(trx.amount),
                    style: GoogleFonts.poppins(
                      color: isExpense ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text("Error"),
    );
  }
}