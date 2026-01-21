import 'package:flutter/material.dart';
import 'package:compound_me/src/features/dashboard/presentation/home_view.dart';
import 'package:compound_me/src/features/habits/presentation/screens/habits_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Daftar Halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const HomeView(),     // Index 0: Dashboard
    const HabitsScreen(), // Index 1: Habits
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga halaman tetap "hidup" saat pindah tab
      // Jadi kalau scroll di Dashboard, pindah ke Habits, balik lagi posisinya gak reset.
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
        ],
      ),
    );
  }
}