import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Provider untuk cek apakah fitur aktif/tidak (disimpan di HP)
final biometricEnabledProvider = StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(false) {
    _loadSettings();
  }

  // Load settingan dari memori HP
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_biometric_enabled') ?? false;
  }

  // Ubah settingan (ON/OFF)
  Future<void> toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_biometric_enabled', value);
    state = value;
  }
}

// 2. Service untuk memanggil sensor jari
class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      // Cek apakah HP punya hardware fingerprint
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // Kalau HP jadul gak ada sensor, loloskan saja

      // Panggil Dialog Fingerprint Bawaan HP
      return await _auth.authenticate(
        localizedReason: 'Scan sidik jari untuk membuka CompoundMe',
        options: const AuthenticationOptions(
          stickyAuth: true, // Biar dialog gak gampang nutup sendiri
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false; // Gagal scan
    }
  }
}