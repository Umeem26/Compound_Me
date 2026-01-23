import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/features/dashboard/presentation/home_view.dart';
import 'package:compound_me/src/features/habits/presentation/screens/habits_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/settings_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/stats_screen.dart'; // IMPORT BARU
import 'package:compound_me/src/features/finance/presentation/screens/add_transaction_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),     // 0
    const HabitsScreen(), // 1
    const StatsScreen(),  // 2 (POSISI BARU: LAPORAN)
    const SettingsScreen(), // 3 (GESER JADI NOMOR 3)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedColor = Colors.teal;
    final unselectedColor = Colors.grey;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.teal,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: navBarColor,
        elevation: 10,
        height: 65,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // KIRI (2 Item)
            _buildNavItem(Icons.dashboard_rounded, "Home", 0, selectedColor, unselectedColor),
            _buildNavItem(Icons.task_alt_rounded, "Habits", 1, selectedColor, unselectedColor),
            
            const SizedBox(width: 48), // SPASI TENGAH
            
            // KANAN (2 Item - SEIMBANG!)
            _buildNavItem(Icons.pie_chart_rounded, "Laporan", 2, selectedColor, unselectedColor), // MENU BARU
            _buildNavItem(Icons.settings_rounded, "Settings", 3, selectedColor, unselectedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color selectedColor, Color unselectedColor) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Padding sedikit dikecilkan biar muat
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: isSelected ? selectedColor : unselectedColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : unselectedColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}