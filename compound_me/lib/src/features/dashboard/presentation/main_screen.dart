import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:compound_me/src/features/dashboard/presentation/home_view.dart';
import 'package:compound_me/src/features/habits/presentation/screens/habits_screen.dart';
import 'package:compound_me/src/features/dashboard/presentation/screens/settings_screen.dart';
import 'package:compound_me/src/features/finance/presentation/screens/add_transaction_screen.dart'; // Import Add Screen

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
    const SettingsScreen(), // 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cek Dark Mode untuk warna Nav Bar
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedColor = Colors.teal;
    final unselectedColor = Colors.grey;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // TOMBOL TENGAH (MENGAMBANG)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi Tombol Tengah: Buka Layar Tambah Transaksi
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: Colors.teal, // Warna Hijau Gojek-style
        elevation: 4,
        shape: const CircleBorder(), // Bulat sempurna
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      // LOKASI TOMBOL: DITANCAP DI TENGAH
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // NAVIGASI BAWAH
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Coak untuk tombol
        notchMargin: 8.0, // Jarak coak
        color: navBarColor,
        elevation: 10,
        height: 65,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // KIRI: Dashboard & Habits
            _buildNavItem(Icons.dashboard, "Home", 0, selectedColor, unselectedColor),
            _buildNavItem(Icons.task_alt, "Habits", 1, selectedColor, unselectedColor),
            
            // SPASI KOSONG DI TENGAH (UNTUK TOMBOL ADD)
            const SizedBox(width: 48), 
            
            // KANAN: Settings (Dan mungkin future feature)
            _buildNavItem(Icons.settings, "Settings", 2, selectedColor, unselectedColor),
            // Dummy item biar seimbang (Opsional, saat ini 2 kiri 1 kanan)
            // Kalau mau seimbang sempurna, bisa tambah menu 'Laporan' di masa depan
             const SizedBox(width: 40), // Penyeimbang visual
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Item Navigasi
  Widget _buildNavItem(IconData icon, String label, int index, Color selectedColor, Color unselectedColor) {
    final isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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