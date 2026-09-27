// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'CompoundMe';

  @override
  String get navHome => 'Beranda';

  @override
  String get navHabits => 'Kebiasaan';

  @override
  String get navInsights => 'Wawasan';

  @override
  String get navProfile => 'Profil';

  @override
  String get navAdd => 'Tambah transaksi';

  @override
  String get homeEmptyTitle => 'Belum ada transaksi';

  @override
  String get homeEmptyBody => 'Catat yang pertama, cuma butuh beberapa detik.';

  @override
  String get homeEmptyAction => 'Catat transaksi pertama';

  @override
  String get habitsEmptyTitle => 'Mulai dari satu kebiasaan';

  @override
  String get habitsEmptyBody =>
      'Kebiasaan kecil yang diulang akan terlihat dampaknya di sini.';

  @override
  String get insightsEmptyTitle => 'Wawasan muncul setelah seminggu mencatat';

  @override
  String get insightsEmptyBody =>
      'Catat setiap hari, lalu lihat polanya di sini.';

  @override
  String get profileEmptyTitle => 'Profil belum diatur';

  @override
  String get profileEmptyBody =>
      'Nama panggilan dan dompetmu akan tersimpan di sini.';

  @override
  String get undoAction => 'Urungkan';

  @override
  String get catFood => 'Makanan & minuman';

  @override
  String get catTransport => 'Transportasi';

  @override
  String get catShopping => 'Belanja';

  @override
  String get catBills => 'Tagihan';

  @override
  String get catEntertainment => 'Hiburan';

  @override
  String get catHealth => 'Kesehatan';

  @override
  String get catEducation => 'Pendidikan';

  @override
  String get catOtherExpense => 'Lainnya';

  @override
  String get catAllowance => 'Uang saku / gaji';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catGift => 'Hadiah';

  @override
  String get catOtherIncome => 'Lainnya';

  @override
  String get actionNext => 'Lanjut';

  @override
  String get actionBack => 'Kembali';

  @override
  String get actionSkip => 'Lewati';

  @override
  String get actionSave => 'Simpan';

  @override
  String get actionGotIt => 'Mengerti';

  @override
  String get errorSaveFailed => 'Gagal menyimpan. Coba lagi.';

  @override
  String get keypadBackspace => 'Hapus satu angka';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingLanguageTitle => 'Pilih bahasa';

  @override
  String get onboardingLanguageBody => 'Bisa diganti kapan saja di Pengaturan.';

  @override
  String get onboardingValueGrowthTitle => 'Kebiasaan kecil, dampak besar';

  @override
  String get onboardingValueGrowthBody =>
      'Lihat berapa sebenarnya harga rutinitasmu, lalu arahkan ke hal yang lebih berarti.';

  @override
  String get onboardingValueSpeedTitle => 'Catat dalam hitungan detik';

  @override
  String get onboardingValueSpeedBody =>
      'Keypad cepat untuk pengeluaran, satu ketukan untuk check-in kebiasaan.';

  @override
  String get onboardingValuePrivacyTitle => 'Privat di perangkatmu';

  @override
  String get onboardingValuePrivacyBody =>
      'Tanpa akun. Datamu tidak pernah keluar dari HP ini.';

  @override
  String onboardingPageLabel(int current, int total) {
    return 'Halaman $current dari $total';
  }

  @override
  String get onboardingNameTitle => 'Panggil kamu siapa?';

  @override
  String get onboardingNameBody => 'Dipakai untuk sapaan saja.';

  @override
  String get fieldName => 'Nama';

  @override
  String get errorNameRequired => 'Nama belum diisi.';

  @override
  String get onboardingWalletTitle => 'Dompet pertama';

  @override
  String get onboardingWalletBody =>
      'Tempat uangmu dicatat, misalnya uang tunai atau rekening bank.';

  @override
  String get onboardingWalletHelper => 'Bisa ditambah atau diubah nanti.';

  @override
  String get fieldWalletName => 'Nama dompet';

  @override
  String get fieldWalletType => 'Tipe';

  @override
  String get fieldInitialBalance => 'Saldo awal';

  @override
  String get walletDefaultName => 'Tunai';

  @override
  String get walletTypeCash => 'Tunai';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeEwallet => 'E-wallet';

  @override
  String get walletTypeOther => 'Lainnya';

  @override
  String get onboardingHabitsTitle => 'Pilih kebiasaan';

  @override
  String get onboardingHabitsBody =>
      'Pilih sampai 3. Semuanya bisa diubah nanti.';

  @override
  String get habitGroupBuild => 'Ingin dibangun';

  @override
  String get habitGroupReduce => 'Ingin dikurangi';

  @override
  String get templateExercise => 'Olahraga';

  @override
  String get templateRead => 'Baca 10 halaman';

  @override
  String get templatePackLunch => 'Bawa bekal';

  @override
  String get templateDrinkWater => 'Minum air 8 gelas';

  @override
  String get templateCafeCoffee => 'Kopi kekinian';

  @override
  String get templateLateSnacks => 'Jajan malam';

  @override
  String get templateShortRides => 'Ojol jarak dekat';

  @override
  String get templateImpulseBuys => 'Belanja impulsif';

  @override
  String get scheduleDaily => 'Setiap hari';

  @override
  String get scheduleWorkdays => 'Hari kerja';

  @override
  String scheduleTimesPerWeek(int count) {
    return '${count}x seminggu';
  }

  @override
  String templateCostEdit(String template, String amount) {
    return 'Ubah biaya $template, sekarang $amount';
  }

  @override
  String get templateCostTitle => 'Biaya per kali';

  @override
  String get actionStart => 'Mulai';

  @override
  String get actionSkipForNow => 'Lewati dulu';

  @override
  String get coachMarkAdd => 'Catat pengeluaran dan pemasukan dari tombol ini.';
}
