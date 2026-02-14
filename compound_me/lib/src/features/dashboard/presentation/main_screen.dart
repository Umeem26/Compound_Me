import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Screens & Themes & Controller
import 'package:compound_me/src/core/theme/theme_provider.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/splash_screen.dart'; // PASTIKAN BARIS INI ADA
import 'package:compound_me/src/features/dashboard/presentation/screens/lock_screen.dart'; 
import 'package:compound_me/src/features/dashboard/presentation/controllers/biometric_controller.dart'; 

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'CompoundMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // BUNGKUS DENGAN APP LIFECYCLE MANAGER
      home: const AppLifecycleManager(child: SplashScreen()),
    );
  }
}

// WIDGET KHUSUS UNTUK MEMANTAU STATUS APLIKASI (Buka/Tutup)
class AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;
  const AppLifecycleManager({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager> with WidgetsBindingObserver {
  bool _isLocked = false; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  void _checkInitialLock() {
    // Cek apakah user mengaktifkan fitur biometrik
    final isEnabled = ref.read(biometricEnabledProvider);
    if (isEnabled) {
      setState(() => _isLocked = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Kalau aplikasi masuk background (di-minimize/pindah app)
    if (state == AppLifecycleState.paused) {
      final isEnabled = ref.read(biometricEnabledProvider);
      if (isEnabled) {
        setState(() => _isLocked = true); // KUNCI OTOMATIS
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kalau terkunci, tampilkan LockScreen
    if (_isLocked) {
      return LockScreen(
        onUnlock: () {
          setState(() => _isLocked = false); // Buka Kunci
        },
      );
    }
    
    // Kalau tidak, tampilkan aplikasi normal
    return widget.child; 
  }
}