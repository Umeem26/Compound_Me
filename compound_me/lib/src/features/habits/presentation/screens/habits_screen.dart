import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // Import Wajib
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/core/utils/currency_input_formatter.dart'; // Import Formatter
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);
    final todayLogsAsync = ref.watch(todayHabitLogsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Habits"),
        elevation: 0,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
             return const Center(child: Text("Belum ada kebiasaan. Tambah dulu!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isDone = todayLogsAsync.value?.any((log) => log.habitId == habit.id) ?? false;

              Color cardColor;
              if (isDone) {
                 cardColor = isDarkMode ? Colors.green.shade900.withOpacity(0.3) : Colors.green[50]!;
              } else {
                 cardColor = Theme.of(context).cardColor;
              }

              return Card(
                elevation: 0,
                color: cardColor, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isDone ? const BorderSide(color: Colors.green) : BorderSide.none
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(habit.color).withOpacity(0.2),
                    child: Icon(
                      isDone ? Icons.check : Icons.timer, 
                      color: Color(habit.color)
                    ),
                  ),
                  title: Text(
                    habit.name,
                    style: TextStyle(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.green : null,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: habit.costPerUnit > 0 
                    ? Text("Biaya: ${CurrencyFormatter.toRupiah(habit.costPerUnit)}")
                    : const Text("Good Habit (Gratis)"),
                  trailing: isDone 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.white : Colors.black, 
                          foregroundColor: isDarkMode ? Colors.black : Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12)
                        ),
                        onPressed: () {
                          ref.read(todayHabitLogsProvider.notifier).checkHabit(habit);
                        },
                        child: const Icon(Icons.check),
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
        onPressed: () {
          _showAddHabitDialog(context, ref);
        },
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final costController = TextEditingController(text: "0"); 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Kebiasaan"),
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
              
              // PASANG FORMATTER DI SINI
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],

              decoration: const InputDecoration(
                prefixText: "Rp ",
                labelText: "Biaya per kali (Opsional)",
                helperText: "Isi 0 jika gratis. Isi harga jika berbayar (cth: Rokok)",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              // BERSIHKAN FORMAT TITIK
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