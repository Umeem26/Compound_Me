import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compound_me/src/core/theme/theme_provider.dart';
import 'package:compound_me/src/core/utils/bounce_button.dart'; // Import Bounce Button

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GROUP 1: TAMPILAN
            _buildSectionTitle("Tampilan Aplikasi"),
            const SizedBox(height: 10),
            _buildSettingCard(
              context,
              children: [
                _buildSwitchTile(
                  context,
                  icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.purple,
                  title: "Mode Gelap",
                  subtitle: isDarkMode ? "Aktif" : "Nonaktif",
                  value: isDarkMode,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // GROUP 2: KEAMANAN & DATA
            _buildSectionTitle("Keamanan & Data"),
            const SizedBox(height: 10),
            _buildSettingCard(
              context,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.fingerprint,
                  color: Colors.blue,
                  title: "Kunci Biometrik",
                  subtitle: "Segera Hadir",
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60), // Garis pemisah
                _buildActionTile(
                  context,
                  icon: Icons.picture_as_pdf,
                  color: Colors.red,
                  title: "Export Laporan",
                  subtitle: "Download PDF (Segera Hadir)",
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60),
                _buildActionTile(
                  context,
                  icon: Icons.backup,
                  color: Colors.orange,
                  title: "Backup Database",
                  subtitle: "Simpan data ke Google Drive",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 30),

            // GROUP 3: TENTANG
            _buildSectionTitle("Tentang"),
            const SizedBox(height: 10),
            _buildSettingCard(
              context,
              children: [
                _buildActionTile(
                  context,
                  icon: Icons.info_outline,
                  color: Colors.grey,
                  title: "Versi Aplikasi",
                  subtitle: "v1.0.0 (Beta)",
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60),
                _buildActionTile(
                  context,
                  icon: Icons.code,
                  color: Colors.teal,
                  title: "Developer",
                  subtitle: "Dibuat oleh Hisyam K.U",
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            Center(
              child: Text(
                "CompoundMe © 2026",
                style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER BIAR RAPI ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey,
          letterSpacing: 1.2
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {
    required IconData icon, required Color color, required String title, required String subtitle, required bool value, required Function(bool) onChanged
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.teal,
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap
  }) {
    return BounceButton( // Pakai Efek Mental
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Penting agar InkWell bekerja
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}