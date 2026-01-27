import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// --- DEFINISI WARNA SULTAN (Luxury Theme) ---
class AppColors {
  // Palette Teal (Hijau Laut - Warna Dasar)
  static const Color tealDark = Color(0xFF004D40);
  static const Color tealPrimary = Color(0xFF00695C);
  static const Color tealLight = Color(0xFF4DB6AC);

  // Palette Gold (Emas - Warna Aksen Mewah)
  static const Color goldDark = Color(0xFFC5A000);
  static const Color goldPrimary = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFECB3);
  
  // Gradient Emas (Untuk Tombol/Kartu/Badge)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, goldPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Gradient Teal (Untuk Background Utama & Splash)
  static const LinearGradient tealGradient = LinearGradient(
    colors: [tealDark, tealPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Provider untuk Mengontrol Dark/Light Mode
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  // --- TEMA TERANG (LIGHT) ---
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.tealPrimary,
    scaffoldBackgroundColor: Colors.grey[50], // Putih bersih
    
    // Skema Warna Utama
    colorScheme: const ColorScheme.light(
      primary: AppColors.tealPrimary,
      secondary: AppColors.goldPrimary, // Aksen Emas
      surface: Colors.white,
      onPrimary: Colors.white,
    ),

    // Font Modern (Poppins)
    textTheme: GoogleFonts.poppinsTextTheme(),

    // AppBar Mewah
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.tealDark,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Transisi Halaman Mulus (Zoom)
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // --- TEMA GELAP (DARK) ---
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.tealPrimary,
    scaffoldBackgroundColor: const Color(0xFF121212), // Hitam Elegan
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.tealPrimary,
      secondary: AppColors.goldPrimary,
      surface: Color(0xFF1E1E1E),
      onPrimary: Colors.white,
    ),

    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: AppColors.goldPrimary, // Teks Emas di mode gelap
      elevation: 0,
      centerTitle: true,
    ),
    
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}