import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' as drift; // Alias biar gak bentrok

// Import Core
import 'package:compound_me/src/core/theme/theme_provider.dart';
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/core/database/database_provider.dart';

// Import Controller
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';

// --- PROVIDER KHUSUS STATISTIK ---
// Mengambil Data Kategori dari Database
final categoriesFutureProvider = FutureProvider((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return await db.select(db.categories).get();
});

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int touchedIndex = -1; // Untuk animasi saat grafik disentuh

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Data Transaksi
    final transactionsAsync = ref.watch(transactionListProvider);
    // 2. Ambil Data Kategori
    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Analisis Keuangan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER JUDUL
            Text(
              "Pengeluaran Bulan Ini",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // CHART SECTION
            categoriesAsync.when(
              data: (categories) {
                return transactionsAsync.when(
                  data: (transactions) {
                    // FILTER: Hanya Pengeluaran (Negatif)
                    final expenses = transactions.where((t) => t.amount < 0).toList();
                    
                    if (expenses.isEmpty) {
                      return _buildEmptyState();
                    }

                    // GROUPING: Hitung total per kategori
                    // Map<CategoryId, TotalAmount>
                    Map<int, double> allocation = {};
                    double totalExpense = 0;

                    for (var trx in expenses) {
                      final amount = trx.amount.abs(); // Jadikan positif biar gampang
                      allocation[trx.categoryId] = (allocation[trx.categoryId] ?? 0) + amount;
                      totalExpense += amount;
                    }

                    // SIAPKAN DATA CHART
                    List<PieChartSectionData> sections = [];
                    int index = 0;
                    
                    // Warna Palette Sultan
                    final List<Color> palette = [
                      AppColors.tealPrimary,
                      AppColors.goldPrimary,
                      AppColors.tealDark,
                      const Color(0xFFD4AF37), // Metallic Gold
                      Colors.tealAccent,
                      Colors.orangeAccent,
                    ];

                    allocation.forEach((catId, amount) {
                      final isTouched = index == touchedIndex;
                      final fontSize = isTouched ? 18.0 : 12.0;
                      final radius = isTouched ? 110.0 : 100.0;
                      
                      // --- PERBAIKAN DISINI (SAFE LOOKUP) ---
                      // Cari kategori berdasarkan ID. Jika tidak ada, pakai "Lainnya"
                      final matchedList = categories.where((c) => c.id == catId);
                      final catName = matchedList.isNotEmpty ? matchedList.first.name : "Lainnya";
                      // --------------------------------------

                      final percent = (amount / totalExpense * 100).toStringAsFixed(1);

                      sections.add(PieChartSectionData(
                        color: palette[index % palette.length],
                        value: amount,
                        title: '$percent%',
                        radius: radius,
                        titleStyle: GoogleFonts.poppins(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [const Shadow(color: Colors.black26, blurRadius: 2)]
                        ),
                        badgeWidget: _buildBadge(catName, amount),
                        badgePositionPercentageOffset: 1.3, // Posisi label di luar lingkaran
                      ));
                      index++;
                    });

                    return Column(
                      children: [
                        // WIDGET GRAFIK LINGKARAN
                        SizedBox(
                          height: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection == null) {
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 2, // Jarak antar potongan
                                  centerSpaceRadius: 40, // Bolong tengah (Donut)
                                  sections: sections,
                                ),
                              ),
                              // TEXT TOTAL DI TENGAH DONAT
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Total", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                                  Text(
                                    CurrencyFormatter.toRupiah(totalExpense).replaceAll("Rp ", ""),
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // DAFTAR KETERANGAN (LEGEND) DI BAWAH
                        ...List.generate(sections.length, (i) {
                          final section = sections[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 16, height: 16,
                                  decoration: BoxDecoration(color: section.color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_getBadgeText(section.badgeWidget), style: GoogleFonts.poppins())),
                                Text(CurrencyFormatter.toRupiah(section.value), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        })
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_,__) => const Text("Gagal memuat data"),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_,__) => const Text("Error Kategori"),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text("Belum ada pengeluaran bulan ini.", style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 8),
          Text("Hemat pangkal kaya! 🤑", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.tealPrimary)),
        ],
      ),
    );
  }

  // Label Kecil di luar grafik
  Widget _buildBadge(String catName, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
        ]
      ),
      child: Text(catName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
  
  // Helper ekstrak teks
  String _getBadgeText(Widget? widget) {
    if (widget is Container && widget.child is Text) {
      return (widget.child as Text).data ?? "";
    }
    return "";
  }
}