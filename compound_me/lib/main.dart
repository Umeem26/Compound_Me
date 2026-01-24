import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:compound_me/src/core/theme/theme_provider.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/splash_screen.dart';

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
    final currentTheme = ref.watch(themeProvider);

    // 1. Text Theme (Poppins)
    final textTheme = GoogleFonts.poppinsTextTheme();

    // 2. Input Decoration (Kotak Input Bulat)
    final inputDecorationTheme = InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );

    // 3. Button Theme
    final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );

    return MaterialApp(
      title: 'CompoundMe',
      debugShowCheckedModeBanner: false,
      
      // --- LIGHT THEME ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: textTheme,
        inputDecorationTheme: inputDecorationTheme.copyWith(fillColor: Colors.grey[200]),
        elevatedButtonTheme: elevatedButtonTheme,
        
        // HAPUS CARD THEME AGAR TIDAK ERROR (Material 3 sudah otomatis rounded)
        
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.black),
        ),

        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      // --- DARK THEME ---
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        inputDecorationTheme: inputDecorationTheme.copyWith(fillColor: const Color(0xFF2C2C2C)),
        elevatedButtonTheme: elevatedButtonTheme,
        
        // HAPUS CARD THEME DARI SINI JUGA
        
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.tealAccent,
        ),

        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      themeMode: currentTheme, 
      home: const SplashScreen(),
    );
  }
}