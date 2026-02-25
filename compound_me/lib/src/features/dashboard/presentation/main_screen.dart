import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/core/theme/theme_provider.dart';

// Import Halaman-Halaman Utama
import 'package:compound_me/src/features/dashboard/presentation/home_view.dart';
import 'package:compound_me/src/features/habits/presentation/screens/habits_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // Daftar Halaman yang akan ditampilkan
  final List<Widget> _pages = const [
    HomeView(),      // Halaman 1: Dashboard
    HabitsScreen(),  // Halaman 2: Habits
    SettingsScreen() // Halaman 3: Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai urutan index
      body: _pages[_currentIndex],
      
      // Menu Navigasi Bawah
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Theme.of(context).cardColor,
          indicatorColor: AppColors.tealPrimary.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.tealPrimary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer, color: AppColors.tealPrimary),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings, color: AppColors.tealPrimary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}