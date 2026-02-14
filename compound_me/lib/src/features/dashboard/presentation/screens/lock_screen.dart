import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:compound_me/src/core/theme/theme_provider.dart'; // Import Warna Sultan
import 'package:compound_me/src/features/dashboard/presentation/controllers/biometric_controller.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlock; // Fungsi yang dijalankan kalau sukses
  const LockScreen({super.key, required this.onUnlock});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _startAuth(); // Langsung scan pas dibuka
  }

  Future<void> _startAuth() async {
    setState(() => _isAuthenticating = true);
    
    // Panggil Service Biometrik
    bool success = await BiometricService.authenticate();
    
    if (success) {
      widget.onUnlock(); // Buka Kunci!
    }

    if (mounted) setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.tealGradient, // Background Mewah
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Gembok Emas
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldPrimary, width: 2),
              ),
              child: const Icon(Icons.fingerprint, size: 80, color: AppColors.goldPrimary),
            ),
            const SizedBox(height: 30),
            
            Text(
              "CompoundMe Locked",
              style: GoogleFonts.poppins(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Amankan aset finansialmu.",
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            
            const SizedBox(height: 50),

            // Tombol Unlock Manual (Kalau scan gagal)
            if (!_isAuthenticating)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.tealDark,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _startAuth,
                icon: const Icon(Icons.lock_open),
                label: Text("Buka Kunci", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}