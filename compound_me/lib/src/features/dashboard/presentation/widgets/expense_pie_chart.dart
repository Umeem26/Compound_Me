import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/category_controller.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';

class ExpensePieChart extends ConsumerWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return transactionsAsync.when(
      data: (transactions) {
        return categoriesAsync.when(
          data: (categories) {
            // 1. Ambil ID Kategori Expense (Type 0)
            final expenseCategoryIds = categories
                .where((c) => c.type == 0)
                .map((c) => c.id)
                .toSet();

            // 2. Filter Transaksi: Hanya yang Expense & Nilainya Minus
            final expenseTrx = transactions
                .where((t) => expenseCategoryIds.contains(t.categoryId) && t.amount < 0)
                .toList();

            if (expenseTrx.isEmpty) {
              return const SizedBox(); 
            }

            // 3. Grouping Data
            final Map<int, double> dataMap = {};
            double totalExpense = 0;

            for (var trx in expenseTrx) {
              // PENTING: Gunakan .abs() agar minus jadi positif untuk grafik
              final positiveAmount = trx.amount.abs();
              
              dataMap[trx.categoryId] = (dataMap[trx.categoryId] ?? 0) + positiveAmount;
              totalExpense += positiveAmount;
            }

            final List<PieChartSectionData> sections = [];
            final List<Color> colors = [
              Colors.red, Colors.orange, Colors.blue, Colors.purple, Colors.green
            ];
            int colorIndex = 0;

            dataMap.forEach((catId, amount) {
              final categoryName = categories.firstWhere((c) => c.id == catId).name;
              final percentage = (amount / totalExpense) * 100;
              
              sections.add(PieChartSectionData(
                color: colors[colorIndex % colors.length],
                value: amount,
                title: '${percentage.toStringAsFixed(0)}%',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ));
              colorIndex++;
            });

            return Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("Pengeluaran Bulan Ini", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PieChart(
                            PieChartData(sections: sections, centerSpaceRadius: 40, sectionsSpace: 2),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dataMap.entries.map((entry) {
                               final cat = categories.firstWhere((c) => c.id == entry.key);
                               return Padding(
                                 padding: const EdgeInsets.only(bottom: 4),
                                 child: Row(
                                   children: [
                                     CircleAvatar(radius: 6, backgroundColor: colors[sections.indexWhere((s) => s.value == entry.value) % colors.length]),
                                     const SizedBox(width: 8),
                                     Expanded(child: Text(cat.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                   ],
                                 ),
                               );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_,__) => const SizedBox(),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const Text("Gagal load chart"),
    );
  }
}