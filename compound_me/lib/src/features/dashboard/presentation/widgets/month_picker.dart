import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:compound_me/src/features/finance/presentation/controllers/transaction_controller.dart';

class MonthPicker extends ConsumerWidget {
  const MonthPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // <--- IKUT TEMA
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = DateTime(selectedDate.year, selectedDate.month - 1);
              ref.read(selectedDateProvider.notifier).updateDate(newDate);
              ref.invalidate(transactionListProvider);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = DateTime(selectedDate.year, selectedDate.month + 1);
              ref.read(selectedDateProvider.notifier).updateDate(newDate);
              ref.invalidate(transactionListProvider);
            },
          ),
        ],
      ),
    );
  }
}