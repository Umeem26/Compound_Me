import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// App name. Not translated.
  ///
  /// In id, this message translates to:
  /// **'CompoundMe'**
  String get appTitle;

  /// Bottom navigation tab for the home screen.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// Bottom navigation tab for habits.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan'**
  String get navHabits;

  /// Bottom navigation tab for Compound Insights.
  ///
  /// In id, this message translates to:
  /// **'Wawasan'**
  String get navInsights;

  /// Bottom navigation tab for the profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// Accessible label of the center add button and title of the add transaction sheet.
  ///
  /// In id, this message translates to:
  /// **'Tambah transaksi'**
  String get navAdd;

  /// Home empty state title.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi'**
  String get homeEmptyTitle;

  /// Home empty state explanation.
  ///
  /// In id, this message translates to:
  /// **'Catat yang pertama, cuma butuh beberapa detik.'**
  String get homeEmptyBody;

  /// Home empty state button that opens the add transaction sheet.
  ///
  /// In id, this message translates to:
  /// **'Catat transaksi pertama'**
  String get homeEmptyAction;

  /// Habits empty state title.
  ///
  /// In id, this message translates to:
  /// **'Mulai dari satu kebiasaan'**
  String get habitsEmptyTitle;

  /// Habits empty state explanation.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan kecil yang diulang akan terlihat dampaknya di sini.'**
  String get habitsEmptyBody;

  /// Insights empty state title.
  ///
  /// In id, this message translates to:
  /// **'Wawasan muncul setelah seminggu mencatat'**
  String get insightsEmptyTitle;

  /// Insights empty state explanation.
  ///
  /// In id, this message translates to:
  /// **'Catat setiap hari, lalu lihat polanya di sini.'**
  String get insightsEmptyBody;

  /// Action on the undo snackbar.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get undoAction;

  /// Default expense category name (stored as nameKey catFood).
  ///
  /// In id, this message translates to:
  /// **'Makanan & minuman'**
  String get catFood;

  /// Default expense category name (stored as nameKey catTransport).
  ///
  /// In id, this message translates to:
  /// **'Transportasi'**
  String get catTransport;

  /// Default expense category name (stored as nameKey catShopping).
  ///
  /// In id, this message translates to:
  /// **'Belanja'**
  String get catShopping;

  /// Default expense category name (stored as nameKey catBills).
  ///
  /// In id, this message translates to:
  /// **'Tagihan'**
  String get catBills;

  /// Default expense category name (stored as nameKey catEntertainment).
  ///
  /// In id, this message translates to:
  /// **'Hiburan'**
  String get catEntertainment;

  /// Default expense category name (stored as nameKey catHealth).
  ///
  /// In id, this message translates to:
  /// **'Kesehatan'**
  String get catHealth;

  /// Default expense category name (stored as nameKey catEducation).
  ///
  /// In id, this message translates to:
  /// **'Pendidikan'**
  String get catEducation;

  /// Default expense category name (stored as nameKey catOtherExpense).
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catOtherExpense;

  /// Default income category name (stored as nameKey catAllowance).
  ///
  /// In id, this message translates to:
  /// **'Uang saku / gaji'**
  String get catAllowance;

  /// Default income category name (stored as nameKey catFreelance).
  ///
  /// In id, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// Default income category name (stored as nameKey catGift).
  ///
  /// In id, this message translates to:
  /// **'Hadiah'**
  String get catGift;

  /// Default income category name (stored as nameKey catOtherIncome).
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get catOtherIncome;

  /// Button that moves to the next step.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get actionNext;

  /// Accessible label of the back arrow.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get actionBack;

  /// Skips the product value pages in onboarding.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get actionSkip;

  /// Saves a form or sheet.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get actionSave;

  /// Dismisses a one-time hint.
  ///
  /// In id, this message translates to:
  /// **'Mengerti'**
  String get actionGotIt;

  /// Snackbar when saving fails (02 §9).
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get errorSaveFailed;

  /// Screen reader label of the keypad backspace key. Long press clears.
  ///
  /// In id, this message translates to:
  /// **'Hapus satu angka'**
  String get keypadBackspace;

  /// Name of the Indonesian language, always written in Indonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// Name of the English language, always written in English.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Onboarding language step title.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa'**
  String get onboardingLanguageTitle;

  /// Onboarding language step explanation.
  ///
  /// In id, this message translates to:
  /// **'Bisa diganti kapan saja di Pengaturan.'**
  String get onboardingLanguageBody;

  /// First product value page title.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan kecil, dampak besar'**
  String get onboardingValueGrowthTitle;

  /// First product value page text.
  ///
  /// In id, this message translates to:
  /// **'Lihat berapa sebenarnya harga rutinitasmu, lalu arahkan ke hal yang lebih berarti.'**
  String get onboardingValueGrowthBody;

  /// Second product value page title.
  ///
  /// In id, this message translates to:
  /// **'Catat dalam hitungan detik'**
  String get onboardingValueSpeedTitle;

  /// Second product value page text.
  ///
  /// In id, this message translates to:
  /// **'Keypad cepat untuk pengeluaran, satu ketukan untuk check-in kebiasaan.'**
  String get onboardingValueSpeedBody;

  /// Third product value page title.
  ///
  /// In id, this message translates to:
  /// **'Privat di perangkatmu'**
  String get onboardingValuePrivacyTitle;

  /// Third product value page text.
  ///
  /// In id, this message translates to:
  /// **'Tanpa akun. Datamu tidak pernah keluar dari HP ini.'**
  String get onboardingValuePrivacyBody;

  /// Screen reader label of the onboarding page dots.
  ///
  /// In id, this message translates to:
  /// **'Halaman {current} dari {total}'**
  String onboardingPageLabel(int current, int total);

  /// Onboarding name step title.
  ///
  /// In id, this message translates to:
  /// **'Panggil kamu siapa?'**
  String get onboardingNameTitle;

  /// Onboarding name step explanation.
  ///
  /// In id, this message translates to:
  /// **'Dipakai untuk sapaan saja.'**
  String get onboardingNameBody;

  /// Label of a name field.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get fieldName;

  /// Validation error for an empty name.
  ///
  /// In id, this message translates to:
  /// **'Nama belum diisi.'**
  String get errorNameRequired;

  /// Onboarding wallet step title.
  ///
  /// In id, this message translates to:
  /// **'Dompet pertama'**
  String get onboardingWalletTitle;

  /// Onboarding wallet step explanation.
  ///
  /// In id, this message translates to:
  /// **'Tempat uangmu dicatat, misalnya uang tunai atau rekening bank.'**
  String get onboardingWalletBody;

  /// Helper under the first wallet form.
  ///
  /// In id, this message translates to:
  /// **'Bisa ditambah atau diubah nanti.'**
  String get onboardingWalletHelper;

  /// Label of the wallet name field.
  ///
  /// In id, this message translates to:
  /// **'Nama dompet'**
  String get fieldWalletName;

  /// Label of the wallet type picker.
  ///
  /// In id, this message translates to:
  /// **'Tipe'**
  String get fieldWalletType;

  /// Label of the wallet starting balance.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal'**
  String get fieldInitialBalance;

  /// Default name of the first wallet.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get walletDefaultName;

  /// Wallet type: cash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get walletTypeCash;

  /// Wallet type: bank account.
  ///
  /// In id, this message translates to:
  /// **'Bank'**
  String get walletTypeBank;

  /// Wallet type: e-wallet such as GoPay or OVO.
  ///
  /// In id, this message translates to:
  /// **'E-wallet'**
  String get walletTypeEwallet;

  /// Wallet type: anything else.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get walletTypeOther;

  /// Onboarding habits step title.
  ///
  /// In id, this message translates to:
  /// **'Pilih kebiasaan'**
  String get onboardingHabitsTitle;

  /// Onboarding habits step explanation.
  ///
  /// In id, this message translates to:
  /// **'Pilih sampai 3. Semuanya bisa diubah nanti.'**
  String get onboardingHabitsBody;

  /// Group of habits the user wants more of.
  ///
  /// In id, this message translates to:
  /// **'Ingin dibangun'**
  String get habitGroupBuild;

  /// Group of habits the user wants less of.
  ///
  /// In id, this message translates to:
  /// **'Ingin dikurangi'**
  String get habitGroupReduce;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Olahraga'**
  String get templateExercise;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Baca 10 halaman'**
  String get templateRead;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Bawa bekal'**
  String get templatePackLunch;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Minum air 8 gelas'**
  String get templateDrinkWater;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Kopi kekinian'**
  String get templateCafeCoffee;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Jajan malam'**
  String get templateLateSnacks;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Ojol jarak dekat'**
  String get templateShortRides;

  /// Starter habit name.
  ///
  /// In id, this message translates to:
  /// **'Belanja impulsif'**
  String get templateImpulseBuys;

  /// Habit schedule: daily.
  ///
  /// In id, this message translates to:
  /// **'Setiap hari'**
  String get scheduleDaily;

  /// Habit schedule: Monday to Friday.
  ///
  /// In id, this message translates to:
  /// **'Hari kerja'**
  String get scheduleWorkdays;

  /// Habit schedule: a number of times per week.
  ///
  /// In id, this message translates to:
  /// **'{count}x seminggu'**
  String scheduleTimesPerWeek(int count);

  /// Screen reader label of the editable template cost.
  ///
  /// In id, this message translates to:
  /// **'Ubah biaya {template}, sekarang {amount}'**
  String templateCostEdit(String template, String amount);

  /// Title of the sheet that edits a template cost.
  ///
  /// In id, this message translates to:
  /// **'Biaya per kali'**
  String get templateCostTitle;

  /// Finishes onboarding with the picked habits.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get actionStart;

  /// Finishes onboarding without picking habits.
  ///
  /// In id, this message translates to:
  /// **'Lewati dulu'**
  String get actionSkipForNow;

  /// One-time hint above the add button after onboarding.
  ///
  /// In id, this message translates to:
  /// **'Catat pengeluaran dan pemasukan dari tombol ini.'**
  String get coachMarkAdd;

  /// Error state title when reading data fails.
  ///
  /// In id, this message translates to:
  /// **'Data belum bisa dimuat'**
  String get errorLoadTitle;

  /// Error state explanation.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi sebentar lagi.'**
  String get errorLoadBody;

  /// Retry button of the error state.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get actionRetry;

  /// Brings an archived wallet or category back.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get actionRestore;

  /// Label of the icon picker row.
  ///
  /// In id, this message translates to:
  /// **'Ikon'**
  String get fieldIcon;

  /// Label of the color picker.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get fieldColor;

  /// Title of the icon picker sheet.
  ///
  /// In id, this message translates to:
  /// **'Pilih ikon'**
  String get iconPickerTitle;

  /// Screen reader label of an icon in the picker.
  ///
  /// In id, this message translates to:
  /// **'Ikon {position} dari {total}'**
  String iconPosition(int position, int total);

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Hijau toska'**
  String get presetTeal;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Emas'**
  String get presetGold;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Koral'**
  String get presetCoral;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Ungu'**
  String get presetViolet;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Biru'**
  String get presetBlue;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Hijau'**
  String get presetGreen;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Merah muda'**
  String get presetRose;

  /// Preset color name for screen readers.
  ///
  /// In id, this message translates to:
  /// **'Abu-abu'**
  String get presetSlate;

  /// Wallets screen title (S-41).
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get walletsTitle;

  /// Overline above the total of active wallets. All caps on purpose.
  ///
  /// In id, this message translates to:
  /// **'TOTAL SALDO'**
  String get walletsTotal;

  /// Row that opens the new wallet form.
  ///
  /// In id, this message translates to:
  /// **'Tambah dompet'**
  String get walletsAdd;

  /// Folded section with archived wallets or categories.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan ({count})'**
  String walletsArchived(int count);

  /// Screen reader label of a drag handle.
  ///
  /// In id, this message translates to:
  /// **'Geser untuk mengurutkan {name}'**
  String walletsReorder(String name);

  /// Wallets empty state title.
  ///
  /// In id, this message translates to:
  /// **'Belum ada dompet aktif'**
  String get walletsEmptyTitle;

  /// Wallets empty state explanation.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan dompet untuk mulai mencatat.'**
  String get walletsEmptyBody;

  /// Title of the new wallet form.
  ///
  /// In id, this message translates to:
  /// **'Dompet baru'**
  String get walletNewTitle;

  /// Title of the edit wallet form.
  ///
  /// In id, this message translates to:
  /// **'Ubah dompet'**
  String get walletEditTitle;

  /// Helper under the starting balance of an existing wallet.
  ///
  /// In id, this message translates to:
  /// **'Saldo sekarang ikut berubah sesuai selisihnya.'**
  String get walletBalanceHelper;

  /// Archives a wallet that has transactions.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan dompet'**
  String get walletArchive;

  /// Explains archiving a wallet.
  ///
  /// In id, this message translates to:
  /// **'Disembunyikan dari pilihan, riwayatnya tetap ada.'**
  String get walletArchiveHint;

  /// Deletes a wallet without transactions.
  ///
  /// In id, this message translates to:
  /// **'Hapus dompet'**
  String get walletDelete;

  /// Explains why an unused wallet can be deleted.
  ///
  /// In id, this message translates to:
  /// **'Belum pernah dipakai, jadi bisa dihapus.'**
  String get walletDeleteHint;

  /// Why the last active wallet can't be archived or deleted.
  ///
  /// In id, this message translates to:
  /// **'Minimal harus ada satu dompet aktif.'**
  String get walletLastActive;

  /// Undo snackbar after archiving a wallet.
  ///
  /// In id, this message translates to:
  /// **'Dompet diarsipkan'**
  String get walletArchivedDone;

  /// Undo snackbar after deleting a wallet.
  ///
  /// In id, this message translates to:
  /// **'Dompet dihapus'**
  String get walletDeletedDone;

  /// Categories screen title (S-42).
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get categoriesTitle;

  /// Segment for expense categories.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get categoryKindExpense;

  /// Segment for income categories.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get categoryKindIncome;

  /// Row that opens the new category form.
  ///
  /// In id, this message translates to:
  /// **'Tambah kategori'**
  String get categoriesAdd;

  /// Folded section with archived categories.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan ({count})'**
  String categoriesArchived(int count);

  /// Categories empty state title.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori aktif'**
  String get categoriesEmptyTitle;

  /// Categories empty state explanation.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan kategori untuk jenis ini.'**
  String get categoriesEmptyBody;

  /// Title of the new category form.
  ///
  /// In id, this message translates to:
  /// **'Kategori baru'**
  String get categoryNewTitle;

  /// Title of the edit category form.
  ///
  /// In id, this message translates to:
  /// **'Ubah kategori'**
  String get categoryEditTitle;

  /// Label of the category name field.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori'**
  String get fieldCategoryName;

  /// Why a default category name can't be edited.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori bawaan mengikuti bahasa aplikasi.'**
  String get categoryDefaultNameHelper;

  /// Archives a category that is in use.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan kategori'**
  String get categoryArchive;

  /// Explains archiving a category.
  ///
  /// In id, this message translates to:
  /// **'Disembunyikan dari pilihan, transaksinya tetap ada.'**
  String get categoryArchiveHint;

  /// Deletes a category nothing uses.
  ///
  /// In id, this message translates to:
  /// **'Hapus kategori'**
  String get categoryDelete;

  /// Why an unused category can be deleted.
  ///
  /// In id, this message translates to:
  /// **'Belum pernah dipakai, jadi bisa dihapus.'**
  String get categoryDeleteHint;

  /// Undo snackbar after archiving a category.
  ///
  /// In id, this message translates to:
  /// **'Kategori diarsipkan'**
  String get categoryArchivedDone;

  /// Undo snackbar after deleting a category.
  ///
  /// In id, this message translates to:
  /// **'Kategori dihapus'**
  String get categoryDeletedDone;

  /// Screen reader label of the profile header that edits the name.
  ///
  /// In id, this message translates to:
  /// **'Ubah nama, {name}'**
  String profileEditName(String name);

  /// Title of the sheet that edits the name.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan'**
  String get profileNameTitle;

  /// Hint under the name in the profile header.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk mengubah'**
  String get profileTapToEdit;

  /// Profile group with wallets and categories.
  ///
  /// In id, this message translates to:
  /// **'Keuangan'**
  String get profileGroupFinance;

  /// Profile group with settings.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi'**
  String get profileGroupApp;

  /// Profile and settings group about the app.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get profileGroupAbout;

  /// Number of active wallets next to the Wallets row.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{1 aktif} other{{count} aktif}}'**
  String profileActiveWallets(int count);

  /// Settings screen title (S-43).
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// Settings group for language, theme and balance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get settingsGroupDisplay;

  /// Language setting label.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// Theme setting label.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// Theme option that follows the device.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get themeSystem;

  /// Light theme option.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// Dark theme option.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// Toggle that starts Home with the balance hidden.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan saldo saat membuka app'**
  String get settingsHideBalance;

  /// Explains the hide balance toggle.
  ///
  /// In id, this message translates to:
  /// **'Saldo di Beranda tertutup sampai kamu ketuk ikon mata.'**
  String get settingsHideBalanceHint;

  /// Settings group for deleting data.
  ///
  /// In id, this message translates to:
  /// **'Data'**
  String get settingsGroupData;

  /// Row and button that delete everything.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data'**
  String get settingsDeleteAll;

  /// First confirmation sheet title.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data?'**
  String get deleteAllTitle;

  /// Explains what deleting all data removes.
  ///
  /// In id, this message translates to:
  /// **'Semua transaksi, kebiasaan, dompet, kategori buatanmu, dan pengaturan akan dihapus dari HP ini. Ini tidak bisa dibatalkan.'**
  String get deleteAllBody;

  /// Goes to the second confirmation step.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get deleteAllContinue;

  /// Closes a confirmation without doing anything.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get actionCancel;

  /// Word the user types to confirm deleting all data. Keep it one uppercase word.
  ///
  /// In id, this message translates to:
  /// **'HAPUS'**
  String get deleteAllWord;

  /// Label of the confirmation field.
  ///
  /// In id, this message translates to:
  /// **'Ketik {word} untuk menghapus'**
  String deleteAllTypeLabel(String word);

  /// About screen title and profile row.
  ///
  /// In id, this message translates to:
  /// **'Tentang CompoundMe'**
  String get aboutTitle;

  /// App version row.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get aboutVersion;

  /// Credits row with the author's name.
  ///
  /// In id, this message translates to:
  /// **'Dibuat oleh Hisyam Khaeru Umam'**
  String get aboutCreator;

  /// Row that opens the repository in a browser.
  ///
  /// In id, this message translates to:
  /// **'Kode sumber di GitHub'**
  String get aboutSource;

  /// Row that opens the licenses page.
  ///
  /// In id, this message translates to:
  /// **'Lisensi open source'**
  String get aboutLicenses;

  /// Snackbar when the browser can't be opened.
  ///
  /// In id, this message translates to:
  /// **'Link tidak bisa dibuka.'**
  String get linkOpenFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
