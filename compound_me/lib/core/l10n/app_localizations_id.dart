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

  @override
  String get errorLoadTitle => 'Data belum bisa dimuat';

  @override
  String get errorLoadBody => 'Coba lagi sebentar lagi.';

  @override
  String get actionRetry => 'Coba lagi';

  @override
  String get actionRestore => 'Pulihkan';

  @override
  String get fieldIcon => 'Ikon';

  @override
  String get fieldColor => 'Warna';

  @override
  String get iconPickerTitle => 'Pilih ikon';

  @override
  String iconPosition(int position, int total) {
    return 'Ikon $position dari $total';
  }

  @override
  String get presetTeal => 'Hijau toska';

  @override
  String get presetGold => 'Emas';

  @override
  String get presetCoral => 'Koral';

  @override
  String get presetViolet => 'Ungu';

  @override
  String get presetBlue => 'Biru';

  @override
  String get presetGreen => 'Hijau';

  @override
  String get presetRose => 'Merah muda';

  @override
  String get presetSlate => 'Abu-abu';

  @override
  String get walletsTitle => 'Dompet';

  @override
  String get walletsTotal => 'TOTAL SALDO';

  @override
  String get walletsAdd => 'Tambah dompet';

  @override
  String walletsArchived(int count) {
    return 'Diarsipkan ($count)';
  }

  @override
  String walletsReorder(String name) {
    return 'Geser untuk mengurutkan $name';
  }

  @override
  String get walletsEmptyTitle => 'Belum ada dompet aktif';

  @override
  String get walletsEmptyBody => 'Tambahkan dompet untuk mulai mencatat.';

  @override
  String get walletNewTitle => 'Dompet baru';

  @override
  String get walletEditTitle => 'Ubah dompet';

  @override
  String get walletBalanceHelper =>
      'Saldo sekarang ikut berubah sesuai selisihnya.';

  @override
  String get walletArchive => 'Arsipkan dompet';

  @override
  String get walletArchiveHint =>
      'Disembunyikan dari pilihan, riwayatnya tetap ada.';

  @override
  String get walletDelete => 'Hapus dompet';

  @override
  String get walletDeleteHint => 'Belum pernah dipakai, jadi bisa dihapus.';

  @override
  String get walletLastActive => 'Minimal harus ada satu dompet aktif.';

  @override
  String get walletArchivedDone => 'Dompet diarsipkan';

  @override
  String get walletDeletedDone => 'Dompet dihapus';

  @override
  String get categoriesTitle => 'Kategori';

  @override
  String get categoryKindExpense => 'Pengeluaran';

  @override
  String get categoryKindIncome => 'Pemasukan';

  @override
  String get categoriesAdd => 'Tambah kategori';

  @override
  String categoriesArchived(int count) {
    return 'Diarsipkan ($count)';
  }

  @override
  String get categoriesEmptyTitle => 'Belum ada kategori aktif';

  @override
  String get categoriesEmptyBody => 'Tambahkan kategori untuk jenis ini.';

  @override
  String get categoryNewTitle => 'Kategori baru';

  @override
  String get categoryEditTitle => 'Ubah kategori';

  @override
  String get fieldCategoryName => 'Nama kategori';

  @override
  String get categoryDefaultNameHelper =>
      'Nama kategori bawaan mengikuti bahasa aplikasi.';

  @override
  String get categoryArchive => 'Arsipkan kategori';

  @override
  String get categoryArchiveHint =>
      'Disembunyikan dari pilihan, transaksinya tetap ada.';

  @override
  String get categoryDelete => 'Hapus kategori';

  @override
  String get categoryDeleteHint => 'Belum pernah dipakai, jadi bisa dihapus.';

  @override
  String get categoryArchivedDone => 'Kategori diarsipkan';

  @override
  String get categoryDeletedDone => 'Kategori dihapus';

  @override
  String profileEditName(String name) {
    return 'Ubah nama, $name';
  }

  @override
  String get profileNameTitle => 'Nama panggilan';

  @override
  String get profileTapToEdit => 'Ketuk untuk mengubah';

  @override
  String get profileGroupFinance => 'Keuangan';

  @override
  String get profileGroupApp => 'Aplikasi';

  @override
  String get profileGroupAbout => 'Tentang';

  @override
  String profileActiveWallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktif',
      one: '1 aktif',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsGroupDisplay => 'Tampilan';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Ikuti sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get settingsHideBalance => 'Sembunyikan saldo';

  @override
  String get settingsHideBalanceHint =>
      'Saldo tertutup saat app dibuka. Ketuk ikon mata untuk melihatnya.';

  @override
  String get settingsGroupData => 'Data';

  @override
  String get settingsDeleteAll => 'Hapus semua data';

  @override
  String get deleteAllTitle => 'Hapus semua data?';

  @override
  String get deleteAllBody =>
      'Semua transaksi, kebiasaan, dompet, kategori buatanmu, dan pengaturan akan dihapus dari HP ini. Ini tidak bisa dibatalkan.';

  @override
  String get deleteAllContinue => 'Lanjutkan';

  @override
  String get actionCancel => 'Batal';

  @override
  String get deleteAllWord => 'HAPUS';

  @override
  String deleteAllTypeLabel(String word) {
    return 'Ketik $word untuk menghapus';
  }

  @override
  String get aboutTitle => 'Tentang CompoundMe';

  @override
  String get aboutVersion => 'Versi';

  @override
  String get aboutCreator => 'Dibuat oleh Hisyam Khaeru Umam';

  @override
  String get aboutSource => 'Kode sumber di GitHub';

  @override
  String get aboutLicenses => 'Lisensi open source';

  @override
  String get linkOpenFailed => 'Link tidak bisa dibuka.';

  @override
  String get languageIndonesianShort => 'Indonesia';

  @override
  String get discardTitle => 'Buang perubahan?';

  @override
  String get discardBody => 'Perubahan yang belum disimpan akan hilang.';

  @override
  String get discardAction => 'Buang';

  @override
  String get keepEditingAction => 'Lanjut edit';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingMidday => 'Selamat siang';

  @override
  String get greetingAfternoon => 'Selamat sore';

  @override
  String get greetingNight => 'Selamat malam';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get dayToday => 'Hari ini';

  @override
  String get dayYesterday => 'Kemarin';

  @override
  String dateTimeJoin(String date, String time) {
    return '$date, $time';
  }

  @override
  String get balanceShow => 'Tampilkan saldo';

  @override
  String get balanceHide => 'Sembunyikan saldo';

  @override
  String get balanceHidden => 'Saldo disembunyikan';

  @override
  String get homeRecentTitle => 'Transaksi terbaru';

  @override
  String get homeSeeAll => 'Lihat semua';

  @override
  String summaryMonthPicker(String month) {
    return 'Ringkasan $month, ganti bulan';
  }

  @override
  String get monthPickerTitle => 'Pilih bulan';

  @override
  String get txAddTitle => 'Tambah transaksi';

  @override
  String get txEditTitle => 'Edit transaksi';

  @override
  String get actionClose => 'Tutup';

  @override
  String get txKindExpense => 'Pengeluaran';

  @override
  String get txKindIncome => 'Pemasukan';

  @override
  String get txWallet => 'Dompet';

  @override
  String get txDate => 'Tanggal';

  @override
  String get txNote => 'Catatan';

  @override
  String get txNoteHint => 'Misalnya: makan siang kantor';

  @override
  String get txNoteAdd => 'Tambah catatan (opsional)';

  @override
  String get txSaveChanges => 'Simpan perubahan';

  @override
  String get txCategoryAll => 'Semua';

  @override
  String get txCategoryPickerTitle => 'Pilih kategori';

  @override
  String get txWalletPickerTitle => 'Pilih dompet';

  @override
  String get txDatePickerTitle => 'Pilih tanggal';

  @override
  String get txSaved => 'Tersimpan';

  @override
  String get txDeleted => 'Transaksi dihapus';

  @override
  String get txHabitTag => 'Kebiasaan';

  @override
  String txFromHabit(String name) {
    return 'Dari kebiasaan: $name';
  }

  @override
  String get txFromHabitUnknown => 'Dari check-in kebiasaan';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Hapus';

  @override
  String get txDeleteHabitTitle => 'Hapus transaksi ini?';

  @override
  String txDeleteHabitBody(String name) {
    return 'Ini juga membatalkan check-in $name hari itu.';
  }

  @override
  String get txDeleteHabitBodyUnknown =>
      'Ini juga membatalkan check-in kebiasaan hari itu.';

  @override
  String get transactionsTitle => 'Transaksi';

  @override
  String get txSearchHint => 'Cari catatan atau kategori';

  @override
  String get txSearchClear => 'Hapus pencarian';

  @override
  String get txFilterCategory => 'Kategori';

  @override
  String get txFilterAllCategories => 'Semua kategori';

  @override
  String get txFilterWallet => 'Dompet';

  @override
  String get txFilterAllWallets => 'Semua dompet';

  @override
  String get txNoMatchTitle => 'Tidak ada transaksi yang cocok';

  @override
  String get txNoMatchBody => 'Coba kata lain atau hapus filter.';

  @override
  String get txClearFilters => 'Hapus filter';

  @override
  String get txIncome => 'Masuk';

  @override
  String get txExpense => 'Keluar';

  @override
  String get txNet => 'Selisih';

  @override
  String txFilterCategoryWithKind(String name, String kind) {
    return '$name ($kind)';
  }

  @override
  String get summaryTitle => 'Ringkasan';

  @override
  String get txSearchResults => 'Hasil pencarian';

  @override
  String get txAllMonths => 'Semua bulan';

  @override
  String txShowMonth(String month) {
    return 'Lihat $month';
  }

  @override
  String txMonthEmptyTitle(String month) {
    return 'Belum ada transaksi di $month';
  }

  @override
  String get txMonthEmptyBody =>
      'Transaksi bulan itu muncul di sini setelah dicatat.';
}
