import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/core/utils/currency_formatter.dart';
import 'package:compound_me/src/features/habits/presentation/controllers/habit_controller.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);
    final todayLogsAsync = ref.watch(todayHabitLogsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Daily Habits"),
        backgroundColor: Colors.white,
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
              
              // Cek apakah habit ini sudah dicentang hari ini?
              final isDone = todayLogsAsync.value?.any((log) => log.habitId == habit.id) ?? false;

              return Card(
                elevation: 0,
                color: isDone ? Colors.green[50] : Colors.white, // Jadi hijau kalau selesai
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
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12)
                        ),
                        onPressed: () {
                          // AKSI CENTANG
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
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          _showAddHabitDialog(context, ref);
        },
      ),
    );
  }

  // Dialog Sederhana untuk Tambah Habit
  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final costController = TextEditingController(text: "0"); // Default gratis

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
              decoration: const InputDecoration(
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
              ref.read(habitListProvider.notifier).addHabit(
                name: nameController.text,
                cost: double.tryParse(costController.text) ?? 0,
                color: Colors.blue.value, // Default warna biru dulu
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