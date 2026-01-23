import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/dashboard/presentation/widgets/expense_pie_chart.dart';
import 'package:compound_me/src/features/dashboard/presentation/widgets/month_picker.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/category_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Keuangan"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. FILTER BULAN
            const MonthPicker(),
            const SizedBox(height: 24),

            // 2. KARTU RINGKASAN (PEMASUKAN vs PENGELUARAN)
            transactionsAsync.when(
              data: (transactions) {
                // Hitung Manual
                double income = 0;
                double expense = 0;
                
                for (var t in transactions) {
                  // Ingat: Di DB kita, Pemasukan = Positif, Pengeluaran = Negatif
                  if (t.amount > 0) {
                    income += t.amount;
                  } else {
                    expense += t.amount.abs(); // Kita ambil positifnya untuk ditampilkan
                  }
                }

                return Row(
                  children: [
                    // KARTU PEMASUKAN
                    Expanded(
                      child: _buildSummaryCard(
                        context, 
                        "Pemasukan", 
                        income, 
                        Icons.arrow_downward, 
                        Colors.green
                      ),
                    ),
                    const SizedBox(width: 16),
                    // KARTU PENGELUARAN
                    Expanded(
                      child: _buildSummaryCard(
                        context, 
                        "Pengeluaran", 
                        expense, 
                        Icons.arrow_upward, 
                        Colors.red
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_,__) => const SizedBox(),
            ),

            const SizedBox(height: 24),
            
            // 3. GRAFIK (PIE CHART)
            const Text("Distribusi Pengeluaran", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ExpensePieChart(),
            
            const SizedBox(height: 24),

            // 4. DETAIL LIST KATEGORI (RANKING BOROS)
            const Align(
              alignment: Alignment.centerLeft, 
              child: Text("Rincian Pengeluaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 10),
            
            _buildCategoryBreakdown(transactionsAsync, categoriesAsync, context, isDarkMode),
            
            const SizedBox(height: 40), // Spasi bawah biar lega
          ],
        ),
      ),
    );
  }

  // WIDGET: Kartu Ringkasan Kecil
  Widget _buildSummaryCard(BuildContext context, String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.toRupiah(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // WIDGET: List Detail Kategori
  Widget _buildCategoryBreakdown(
    AsyncValue<List<dynamic>> trxAsync, 
    AsyncValue<List<dynamic>> catAsync, 
    BuildContext context,
    bool isDarkMode
  ) {
    return trxAsync.when(
      data: (transactions) {
        return catAsync.when(
          data: (categories) {
            // 1. Filter & Grouping Data
            final expenseTrx = transactions.where((t) => t.amount < 0).toList();
            if (expenseTrx.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Belum ada pengeluaran.", style: TextStyle(color: Colors.grey[600])),
              );
            }

            final Map<int, double> dataMap = {};
            for (var trx in expenseTrx) {
              dataMap[trx.categoryId] = (dataMap[trx.categoryId] ?? 0) + trx.amount.abs();
            }

            // 2. Sorting (Terbesar ke Terkecil)
            final sortedEntries = dataMap.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // 3. Tampilkan List
            return ListView.separated(
              shrinkWrap: true, // Agar bisa masuk dalam SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedEntries.length,
              separatorBuilder: (_,__) => const Divider(),
              itemBuilder: (context, index) {
                final entry = sortedEntries[index];
                final cat = categories.firstWhere((c) => c.id == entry.key);
                final totalAmount = entry.value;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: Text("${index + 1}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    CurrencyFormatter.toRupiah(totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox(),
          error: (_,__) => const SizedBox(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_,__) => const Text("Gagal memuat data"),
    );
  }
}