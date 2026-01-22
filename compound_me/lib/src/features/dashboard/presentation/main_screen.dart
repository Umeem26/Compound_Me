import 'package:flutter/material.dart';
import 'package:compound_me/src/features/dashboard/presentation/home_view.dart';
import 'package:compound_me/src/features/habits/presentation/screens/habits_screen.dart';
// IMPORT HALAMAN BARU
import 'package:compound_me/src/features/dashboard/presentation/screens/settings_screen.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // DAFTAR HALAMAN (Sekarang ada 3)
  final List<Widget> _pages = [
    const HomeView(),     // 0
    const HabitsScreen(), // 1
    const SettingsScreen(), // 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Habits',
          ),
          // MENU KETIGA
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}