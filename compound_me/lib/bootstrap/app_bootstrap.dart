import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Everything that must be ready before the first frame, done while the
/// native splash is still on screen (05 §2, 04 §5).
class AppBootstrap {
  const AppBootstrap._({required this.database, required this.preferences});

  final AppDatabase database;
  final AppPreferences preferences;

  static Future<AppBootstrap> load() async {
    // v1 crashed with LocaleDataException because this was missing.
    await Future.wait([
      initializeDateFormatting('id'),
      initializeDateFormatting('en'),
    ]);
    final preferences = await AppPreferences.load();
    final database = AppDatabase();
    // Drift opens lazily; force it now so migrations run behind the splash.
    await database.customSelect('SELECT 1').get();
    return AppBootstrap._(database: database, preferences: preferences);
  }

  List<Override> get overrides => [
    appDatabaseProvider.overrideWithValue(database),
    appPreferencesProvider.overrideWithValue(preferences),
  ];
}
