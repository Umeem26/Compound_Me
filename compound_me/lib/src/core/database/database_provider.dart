import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_database.dart';

// Wajib untuk code generation
part 'database_provider.g.dart';

// @Riverpod(keepAlive: true) artinya provider ini bersifat 'Singleton' & abadi
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}