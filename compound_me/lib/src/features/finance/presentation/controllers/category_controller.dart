import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:compound_me/src/features/finance/domain/repositories/finance_repository.dart';

part 'category_controller.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final repository = ref.watch(financeRepositoryProvider);
    final categories = await repository.getCategories();

    print("CEK KATEGORI: Jumlah data = ${categories.length}");
    
    // LOGIC SEEDER: Jika kategori kosong, kita isi otomatis!
    if (categories.isEmpty) {
      await _seedDefaultCategories(repository);
      return repository.getCategories(); // Ambil ulang setelah diisi
    }
    
    return categories;
  }

  Future<void> _seedDefaultCategories(FinanceRepository repo) async {
    // Kategori Pengeluaran (Type 0)
    final expenses = ['Makanan', 'Transport', 'Belanja', 'Tagihan', 'Hiburan'];
    for (var name in expenses) {
      // PERBAIKAN: Gunakan repo.addCategory, bukan repo.db
      await repo.addCategory(
        CategoriesCompanion.insert(
          name: name, 
          type: 0, 
          icon: 'assets/icons/expense.png',
          color: 0xFFF44336, 
        )
      );
    }

    // Kategori Pemasukan (Type 1)
    final incomes = ['Gaji', 'Bonus', 'Investasi'];
    for (var name in incomes) {
      // PERBAIKAN: Gunakan repo.addCategory
      await repo.addCategory(
        CategoriesCompanion.insert(
          name: name, 
          type: 1, 
          icon: 'assets/icons/income.png', 
          color: 0xFF4CAF50, 
        )
      );
    }
  }
}