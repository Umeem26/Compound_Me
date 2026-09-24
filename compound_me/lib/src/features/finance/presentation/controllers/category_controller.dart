import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:compound_me/src/core/database/app_database.dart';
import 'package:compound_me/src/features/finance/data/repositories/finance_repository_impl.dart';

part 'category_controller.g.dart';

@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final repository = ref.watch(financeRepositoryProvider);
    return repository.getCategories();
  }
}