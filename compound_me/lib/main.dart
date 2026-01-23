import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:compound_me/src/features/dashboard/presentation/main_screen.dart';
// IMPORT PROVIDER TEMA
import 'package:compound_me/src/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. DENGARKAN SAKLAR TEMA
    final currentTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'CompoundMe',
      debugShowCheckedModeBanner: false,
      
      // 2. SETTING TEMA LIGHT (TERANG)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50], 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, 
        ),
      ),

      // 3. SETTING TEMA DARK (GELAP)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, 
          brightness: Brightness.dark // Kunci Dark Mode
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212), // Background gelap
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white, 
        ),
        // Bagian CardTheme dihapus karena otomatis dihandle Material 3
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        )
      ),

      // 4. TERAPKAN PILIHAN USER
      themeMode: currentTheme, 
      
      home: const MainScreen(),
    );
  }
}