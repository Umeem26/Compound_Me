import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Utilities & Colors
import 'package:compound_me/src/core/theme/theme_provider.dart'; // Import AppColors
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/wallet_controller.dart';

// Import Screens
import 'package:compound_me/src/features/finance/presentation/screens/add_wallet_screen.dart';
import 'package:compound_me/src/features/finance/presentation/screens/add_transaction_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/widgets/month_picker.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/notification_screen.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);
    final transactionsAsync = ref.watch(transactionListProvider);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              const Center(child: MonthPicker()), 
              const SizedBox(height: 20),
              
              // KARTU SALDO SULTAN
              _buildPremiumTotalCard(walletsAsync, context),

              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dompet Saya", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWalletScreen())),
                    child: Text("+ Tambah", style: GoogleFonts.poppins(color: AppColors.tealPrimary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWalletList(walletsAsync, ref, context),
              const SizedBox(height: 30),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat Datang, 👋", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            Text(
              "Hisyam K.U", 
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded),
                  Positioned(
                    right: 2, top: 2,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // --- KARTU SULTAN (UPDATE DISINI) ---
  Widget _buildPremiumTotalCard(AsyncValue<List<dynamic>> walletsAsync, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Background Gradient Teal
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(24),
        // Border Emas Tipis (Kesan Mahal)
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.5), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tealDark.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi Lingkaran Emas Transparan
          Positioned(right: -30, top: -30, child: CircleAvatar(radius: 70, backgroundColor: AppColors.goldPrimary.withOpacity(0.15))),
          Positioned(bottom: -50, right: 20, child: CircleAvatar(radius: 50, backgroundColor: AppColors.goldPrimary.withOpacity(0.1))),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.goldPrimary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text("Total Aset Bersih", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              walletsAsync.when(
                data: (wallets) {
                  final total = wallets.fold<double>(0, (sum, wallet) => sum + wallet.balance);
                  return FittedBox( 
                    child: Text(
                      CurrencyFormatter.toRupiah(total), 
                      style: GoogleFonts.poppins(
                        color: Colors.white, 
                        fontSize: 38, // Lebih Besar
                        fontWeight: FontWeight.bold,
                        shadows: [const Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)]
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: AppColors.goldPrimary)),
                error: (_, __) => const Text("---", style: TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              
              // Badge Financial Freedom (Gradient Emas)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient, 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.goldDark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Financial Freedom 🚀", 
                      style: GoogleFonts.poppins(color: AppColors.tealDark, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

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
                        Text(CurrencyFormatter.toRupiah(wallet.balance), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
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
              
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddTransactionScreen(transactionToEdit: trx)));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
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
                      style: GoogleFonts.poppins(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
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