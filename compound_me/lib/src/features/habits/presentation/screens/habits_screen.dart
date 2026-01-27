import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

// Import Utilities & Colors
import 'package:compound_me/src/core/theme/theme_provider.dart'; // Import AppColors
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/core/utils/currency_input_formatter.dart';
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';
import 'package:compound_me/src/core/utils/bounce_button.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);
    final todayLogsAsync = ref.watch(todayHabitLogsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Goals 🔥", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.track_changes, size: 80, color: Colors.grey[300]),
                   const SizedBox(height: 16),
                   Text("Mulai kebiasaan baik sekarang!", style: GoogleFonts.poppins(color: Colors.grey)),
                 ],
               ),
             );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isDone = todayLogsAsync.value?.any((log) => log.habitId == habit.id) ?? false;

              return Dismissible(
                key: Key(habit.id.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(habitListProvider.notifier).deleteHabit(habit.id);
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                child: BounceButton( 
                  onTap: () {
                     ref.read(todayHabitLogsProvider.notifier).checkHabit(habit);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      // WARNA SULTAN: Jika selesai jadi Gradient Emas
                      gradient: isDone ? AppColors.goldGradient : null,
                      color: isDone ? null : Theme.of(context).cardColor,
                      
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDone ? AppColors.goldPrimary.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                          blurRadius: isDone ? 15 : 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                      border: isDone ? null : Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        // Icon Bulat
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDone ? Colors.white.withOpacity(0.3) : Color(habit.color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.star_rounded : Icons.timer_outlined, 
                            color: isDone ? Colors.white : Color(habit.color),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDone ? AppColors.tealDark : null, // Warna Kontras
                                  decoration: isDone ? TextDecoration.none : null,
                                ),
                              ),
                              if (habit.costPerUnit > 0)
                                Text(
                                  "Biaya: ${CurrencyFormatter.toRupiah(habit.costPerUnit)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12, 
                                    color: isDone ? AppColors.tealDark.withOpacity(0.7) : Colors.grey
                                  ),
                                )
                              else
                                Text(
                                  "Good Habit",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12, 
                                    color: isDone ? AppColors.tealDark.withOpacity(0.7) : Colors.grey
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        if (isDone)
                          const Icon(Icons.check_circle, color: Colors.white, size: 28)
                        else
                          Icon(Icons.radio_button_unchecked, color: Colors.grey[300], size: 28),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.tealPrimary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddHabitDialog(context, ref),
      ),
    );
  }

   void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final costController = TextEditingController(text: "0"); 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Kebiasaan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nama (cth: Lari, Ngopi)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
              decoration: const InputDecoration(
                prefixText: "Rp ",
                labelText: "Biaya (Opsional)",
                helperText: "Isi jika kebiasaan ini keluar uang",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.tealPrimary, foregroundColor: Colors.white),
            onPressed: () {
              final cost = CurrencyInputFormatter.toDouble(costController.text);
              ref.read(habitListProvider.notifier).addHabit(
                name: nameController.text,
                cost: cost,
                color: Colors.blue.value, 
              );
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }
}