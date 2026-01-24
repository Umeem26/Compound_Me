import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/core/utils/currency_input_formatter.dart';
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';
import 'package:flutter/services.dart';
import 'package:compound_me/src/core/utils/bounce_button.dart'; // Import Bounce Button

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

              // ANIMASI PERUBAHAN WARNA (AnimatedContainer)
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
                child: BounceButton( // EFEK MENTAL SAAT DIKLIK
                  onTap: () {
                     ref.read(todayHabitLogsProvider.notifier).checkHabit(habit);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300), // Durasi Transisi Warna
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDone 
                          ? Colors.teal 
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDone ? Colors.teal.withOpacity(0.4) : Colors.black.withOpacity(0.05),
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
                            color: isDone ? Colors.white.withOpacity(0.2) : Color(habit.color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check : Icons.timer_outlined, 
                            color: isDone ? Colors.white : Color(habit.color),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Teks
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDone ? Colors.white : null,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              if (habit.costPerUnit > 0)
                                Text(
                                  "Biaya: ${CurrencyFormatter.toRupiah(habit.costPerUnit)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12, 
                                    color: isDone ? Colors.white70 : Colors.grey
                                  ),
                                )
                              else
                                Text(
                                  "Good Habit",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12, 
                                    color: isDone ? Colors.white70 : Colors.grey
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Checkbox Custom
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
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddHabitDialog(context, ref),
      ),
    );
  }

  // ... (Fungsi _showAddHabitDialog tetap sama, copy dari sebelumnya atau biarkan saja)
  // Biar kode tidak terlalu panjang, saya asumsikan fungsi dialognya sama.
  // Jika hilang, kabari saya ya!
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
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