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
  /// **'Sembunyikan saldo'**
  String get settingsHideBalance;

  /// Explains the hide balance toggle.
  ///
  /// In id, this message translates to:
  /// **'Saldo tertutup saat app dibuka. Ketuk ikon mata untuk melihatnya.'**
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

  /// Short name of the Indonesian language for the settings segment (S-43: Indonesia / English).
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get languageIndonesianShort;

  /// Title of the confirmation when leaving a sheet or editor with unsaved input.
  ///
  /// In id, this message translates to:
  /// **'Buang perubahan?'**
  String get discardTitle;

  /// Explains what discarding does.
  ///
  /// In id, this message translates to:
  /// **'Perubahan yang belum disimpan akan hilang.'**
  String get discardBody;

  /// Leaves without saving.
  ///
  /// In id, this message translates to:
  /// **'Buang'**
  String get discardAction;

  /// Closes the confirmation and stays in the form.
  ///
  /// In id, this message translates to:
  /// **'Lanjut edit'**
  String get keepEditingAction;

  /// Home greeting, 04.00-10.00.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi'**
  String get greetingMorning;

  /// Home greeting, 10.00-15.00.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang'**
  String get greetingMidday;

  /// Home greeting, 15.00-18.00.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore'**
  String get greetingAfternoon;

  /// Home greeting, 18.00-04.00.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam'**
  String get greetingNight;

  /// Greeting followed by the user's name.
  ///
  /// In id, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// Day label for today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get dayToday;

  /// Day label for yesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get dayYesterday;

  /// A day label followed by a time, e.g. 'Hari ini, 08.12'.
  ///
  /// In id, this message translates to:
  /// **'{date}, {time}'**
  String dateTimeJoin(String date, String time);

  /// Tooltip of the eye button while balances are hidden.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan saldo'**
  String get balanceShow;

  /// Tooltip of the eye button while balances show.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan saldo'**
  String get balanceHide;

  /// What screen readers say instead of a hidden balance.
  ///
  /// In id, this message translates to:
  /// **'Saldo disembunyikan'**
  String get balanceHidden;

  /// Home section with the latest transactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi terbaru'**
  String get homeRecentTitle;

  /// Opens the transaction history.
  ///
  /// In id, this message translates to:
  /// **'Lihat semua'**
  String get homeSeeAll;

  /// Screen reader label of the month pill on Home.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan {month}, ganti bulan'**
  String summaryMonthPicker(String month);

  /// Title of the month picker sheet.
  ///
  /// In id, this message translates to:
  /// **'Pilih bulan'**
  String get monthPickerTitle;

  /// Title of the transaction form when adding.
  ///
  /// In id, this message translates to:
  /// **'Tambah transaksi'**
  String get txAddTitle;

  /// Title of the transaction form when editing.
  ///
  /// In id, this message translates to:
  /// **'Edit transaksi'**
  String get txEditTitle;

  /// Closes a sheet.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get actionClose;

  /// Transaction type toggle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get txKindExpense;

  /// Transaction type toggle.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan'**
  String get txKindIncome;

  /// Wallet row of a transaction.
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get txWallet;

  /// Date row of a transaction.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get txDate;

  /// Note row of a transaction.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get txNote;

  /// Placeholder of the note field.
  ///
  /// In id, this message translates to:
  /// **'Misalnya: makan siang kantor'**
  String get txNoteHint;

  /// Note row before a note is written.
  ///
  /// In id, this message translates to:
  /// **'Tambah catatan (opsional)'**
  String get txNoteAdd;

  /// Save button when editing a transaction.
  ///
  /// In id, this message translates to:
  /// **'Simpan perubahan'**
  String get txSaveChanges;

  /// Chip that opens every category.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get txCategoryAll;

  /// Title of the category picker sheet.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori'**
  String get txCategoryPickerTitle;

  /// Title of the wallet picker sheet.
  ///
  /// In id, this message translates to:
  /// **'Pilih dompet'**
  String get txWalletPickerTitle;

  /// Title of the date picker sheet.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get txDatePickerTitle;

  /// Snackbar after saving a transaction.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get txSaved;

  /// Snackbar after deleting a transaction.
  ///
  /// In id, this message translates to:
  /// **'Transaksi dihapus'**
  String get txDeleted;

  /// Tag on a row created by a habit check-in.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan'**
  String get txHabitTag;

  /// Detail row of a check-in expense.
  ///
  /// In id, this message translates to:
  /// **'Dari kebiasaan: {name}'**
  String txFromHabit(String name);

  /// Detail row of a check-in expense whose habit is gone.
  ///
  /// In id, this message translates to:
  /// **'Dari check-in kebiasaan'**
  String get txFromHabitUnknown;

  /// Opens the form to change an item.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// Deletes an item.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get actionDelete;

  /// Title of the confirmation for a check-in expense.
  ///
  /// In id, this message translates to:
  /// **'Hapus transaksi ini?'**
  String get txDeleteHabitTitle;

  /// Explains that the check-in goes too.
  ///
  /// In id, this message translates to:
  /// **'Ini juga membatalkan check-in {name} hari itu.'**
  String txDeleteHabitBody(String name);

  /// Same, when the habit name is unknown.
  ///
  /// In id, this message translates to:
  /// **'Ini juga membatalkan check-in kebiasaan hari itu.'**
  String get txDeleteHabitBodyUnknown;

  /// Title of the transaction history.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get transactionsTitle;

  /// Placeholder of the history search.
  ///
  /// In id, this message translates to:
  /// **'Cari catatan atau kategori'**
  String get txSearchHint;

  /// Clears the history search.
  ///
  /// In id, this message translates to:
  /// **'Hapus pencarian'**
  String get txSearchClear;

  /// History filter chip.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get txFilterCategory;

  /// Removes the category filter.
  ///
  /// In id, this message translates to:
  /// **'Semua kategori'**
  String get txFilterAllCategories;

  /// History filter chip.
  ///
  /// In id, this message translates to:
  /// **'Dompet'**
  String get txFilterWallet;

  /// Removes the wallet filter.
  ///
  /// In id, this message translates to:
  /// **'Semua dompet'**
  String get txFilterAllWallets;

  /// History empty state with filters.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada transaksi yang cocok'**
  String get txNoMatchTitle;

  /// History empty state with filters.
  ///
  /// In id, this message translates to:
  /// **'Coba kata lain atau hapus filter.'**
  String get txNoMatchBody;

  /// Removes every history filter.
  ///
  /// In id, this message translates to:
  /// **'Hapus filter'**
  String get txClearFilters;

  /// Summary label: income of the period.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get txIncome;

  /// Summary label: expenses of the period.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get txExpense;

  /// Summary label: income minus expenses.
  ///
  /// In id, this message translates to:
  /// **'Selisih'**
  String get txNet;

  /// Category in the history filter when both kinds share its name, e.g. 'Lainnya (Pemasukan)'.
  ///
  /// In id, this message translates to:
  /// **'{name} ({kind})'**
  String txFilterCategoryWithKind(String name, String kind);

  /// Header of the month summary card on Home.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get summaryTitle;

  /// Header of the summary card while searching.
  ///
  /// In id, this message translates to:
  /// **'Hasil pencarian'**
  String get txSearchResults;

  /// Month chip while searching, which covers every month.
  ///
  /// In id, this message translates to:
  /// **'Semua bulan'**
  String get txAllMonths;

  /// Switches history to the month before.
  ///
  /// In id, this message translates to:
  /// **'Lihat {month}'**
  String txShowMonth(String month);

  /// History empty state for a month without transactions.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi di {month}'**
  String txMonthEmptyTitle(String month);

  /// History empty state for a month without transactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi bulan itu muncul di sini setelah dicatat.'**
  String get txMonthEmptyBody;

  /// Habit kind: do more of it (PRD §5).
  ///
  /// In id, this message translates to:
  /// **'Bangun'**
  String get habitKindBuild;

  /// Habit kind: do less of it, it costs money (PRD §5).
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get habitKindReduce;

  /// Button and tooltip that open the new habit form.
  ///
  /// In id, this message translates to:
  /// **'Buat kebiasaan'**
  String get habitCreate;

  /// Opens the starter habits.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari template'**
  String get habitFromTemplate;

  /// Title of the starter habits sheet.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari template'**
  String get habitTemplatesTitle;

  /// Habits list filter: scheduled today.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get habitsFilterToday;

  /// Habits list filter: every habit.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get habitsFilterAll;

  /// Tooltip of the ⋯ menu.
  ///
  /// In id, this message translates to:
  /// **'Menu lainnya'**
  String get habitsMore;

  /// Menu item that turns on reordering.
  ///
  /// In id, this message translates to:
  /// **'Atur urutan'**
  String get habitsReorder;

  /// Ends reordering.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get habitsReorderDone;

  /// Shown when nothing is scheduled today.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kebiasaan terjadwal hari ini.'**
  String get habitsNoneToday;

  /// Streak in days.
  ///
  /// In id, this message translates to:
  /// **'{count} hari'**
  String streakDays(int count);

  /// Streak in weeks.
  ///
  /// In id, this message translates to:
  /// **'{count} minggu'**
  String streakWeeks(int count);

  /// Cost of one occurrence of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'{amount} per kali'**
  String habitCostPer(String amount);

  /// Occurrences this week without a limit.
  ///
  /// In id, this message translates to:
  /// **'minggu ini {count}'**
  String habitThisWeek(int count);

  /// Occurrences this week against the weekly limit.
  ///
  /// In id, this message translates to:
  /// **'minggu ini {count}/{limit}'**
  String habitThisWeekOf(int count, int limit);

  /// Reduce habit without a weekly limit: it has no streak yet.
  ///
  /// In id, this message translates to:
  /// **'Atur batas mingguan untuk mulai streak'**
  String get habitSetLimitCta;

  /// Screen reader label of an open check-in.
  ///
  /// In id, this message translates to:
  /// **'{name}, belum check-in hari ini'**
  String habitCheckInOpen(String name);

  /// Screen reader label of a done check-in.
  ///
  /// In id, this message translates to:
  /// **'{name}, sudah check-in hari ini'**
  String habitCheckInDone(String name);

  /// Screen reader label of a reduce check-in with its count.
  ///
  /// In id, this message translates to:
  /// **'{name}, sudah check-in {count} kali hari ini'**
  String habitCheckInCount(String name, int count);

  /// Snackbar after a check-in.
  ///
  /// In id, this message translates to:
  /// **'Dicatat'**
  String get habitLogged;

  /// Snackbar after undoing a check-in with a tap.
  ///
  /// In id, this message translates to:
  /// **'Check-in dibatalkan'**
  String get habitUnlogged;

  /// Stepper sheet of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Jumlah hari ini'**
  String get habitCountToday;

  /// A number of occurrences.
  ///
  /// In id, this message translates to:
  /// **'{count} kali'**
  String habitCountValue(int count);

  /// Cost of today's occurrences.
  ///
  /// In id, this message translates to:
  /// **'{count} × {cost} = {total}'**
  String habitCountCost(int count, String cost, String total);

  /// The stepper reached its limit.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} kali per hari.'**
  String habitCountMax(int max);

  /// Tooltip of a stepper minus button.
  ///
  /// In id, this message translates to:
  /// **'Kurangi satu'**
  String get stepperDecrease;

  /// Tooltip of a stepper plus button.
  ///
  /// In id, this message translates to:
  /// **'Tambah satu'**
  String get stepperIncrease;

  /// Home section with the check-in strip.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan hari ini'**
  String get homeHabitsTitle;

  /// Opens the habits tab.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get homeHabitsAll;

  /// Home card without any habit.
  ///
  /// In id, this message translates to:
  /// **'Tambah kebiasaan pertamamu'**
  String get homeHabitsFirst;

  /// Title of the habit form when creating.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan baru'**
  String get habitNewTitle;

  /// Title of the habit form when editing.
  ///
  /// In id, this message translates to:
  /// **'Edit kebiasaan'**
  String get habitEditTitle;

  /// Label above the build/reduce cards.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get habitKindField;

  /// Explains a build habit.
  ///
  /// In id, this message translates to:
  /// **'Ingin diperbanyak, misalnya olahraga atau baca buku.'**
  String get habitKindBuildHint;

  /// Explains a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Punya biaya dan ingin dikurangi, misalnya kopi kekinian.'**
  String get habitKindReduceHint;

  /// Name field of the habit form.
  ///
  /// In id, this message translates to:
  /// **'Nama kebiasaan'**
  String get fieldHabitName;

  /// Placeholder of the habit name.
  ///
  /// In id, this message translates to:
  /// **'Misalnya: Baca 10 halaman'**
  String get habitNameHint;

  /// Label above the schedule options.
  ///
  /// In id, this message translates to:
  /// **'Jadwal'**
  String get habitScheduleField;

  /// Schedule option: chosen weekdays.
  ///
  /// In id, this message translates to:
  /// **'Hari tertentu'**
  String get scheduleSpecificDays;

  /// Schedule option: a number of times per week.
  ///
  /// In id, this message translates to:
  /// **'N kali seminggu'**
  String get scheduleTimesOption;

  /// Label of the times per week stepper.
  ///
  /// In id, this message translates to:
  /// **'Target per minggu'**
  String get habitTimesPerWeekField;

  /// Screen reader value of the times per week stepper.
  ///
  /// In id, this message translates to:
  /// **'{count} kali seminggu'**
  String habitTimesPerWeekValue(int count);

  /// No weekday chosen.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal satu hari.'**
  String get habitDaysError;

  /// Cost row of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Biaya per kali'**
  String get habitCostField;

  /// Cost row before a cost is set.
  ///
  /// In id, this message translates to:
  /// **'Atur biaya'**
  String get habitCostSet;

  /// Reduce habit without a cost.
  ///
  /// In id, this message translates to:
  /// **'Isi biaya lebih dari Rp 0.'**
  String get habitCostError;

  /// Reduce habit without a wallet.
  ///
  /// In id, this message translates to:
  /// **'Pilih dompet.'**
  String get habitWalletError;

  /// Category row of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get habitCategoryField;

  /// Reduce habit without a category.
  ///
  /// In id, this message translates to:
  /// **'Pilih kategori pengeluaran.'**
  String get habitCategoryError;

  /// Weekly limit stepper of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Batas per minggu'**
  String get habitLimitField;

  /// Weekly limit not set.
  ///
  /// In id, this message translates to:
  /// **'Tanpa batas'**
  String get habitLimitNone;

  /// Screen reader value of the weekly limit.
  ///
  /// In id, this message translates to:
  /// **'{count} kali'**
  String habitLimitValue(int count);

  /// Explains the weekly limit.
  ///
  /// In id, this message translates to:
  /// **'Minggu dengan kejadian di bawah batas dihitung berhasil dan menjaga streak.'**
  String get habitLimitHelper;

  /// Archives a habit with check-ins.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan kebiasaan'**
  String get habitArchive;

  /// Explains archiving a habit.
  ///
  /// In id, this message translates to:
  /// **'Riwayat dan transaksinya tetap tersimpan.'**
  String get habitArchiveHint;

  /// Deletes a habit without check-ins.
  ///
  /// In id, this message translates to:
  /// **'Hapus kebiasaan'**
  String get habitDelete;

  /// Explains deleting a habit.
  ///
  /// In id, this message translates to:
  /// **'Belum ada check-in, jadi bisa dihapus.'**
  String get habitDeleteHint;

  /// Snackbar after archiving a habit.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan diarsipkan'**
  String get habitArchivedDone;

  /// Snackbar after deleting a habit.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan dihapus'**
  String get habitDeletedDone;

  /// Title when a habit with check-ins would change kind.
  ///
  /// In id, this message translates to:
  /// **'Jenis tidak bisa diganti'**
  String get habitKindLockedTitle;

  /// Explains why the kind is fixed.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan ini sudah punya check-in, jadi riwayat dan transaksinya tetap di jenis sekarang. Buat kebiasaan baru untuk jenis {kind}.'**
  String habitKindLockedBody(String kind);

  /// Opens a new habit form with the other kind.
  ///
  /// In id, this message translates to:
  /// **'Buat kebiasaan baru'**
  String get habitKindLockedAction;

  /// Current streak stat.
  ///
  /// In id, this message translates to:
  /// **'Streak'**
  String get habitStatStreak;

  /// Best streak stat.
  ///
  /// In id, this message translates to:
  /// **'Terbaik'**
  String get habitStatBest;

  /// Build habit consistency stat.
  ///
  /// In id, this message translates to:
  /// **'Konsistensi 30 hari'**
  String get habitStatConsistency;

  /// Reduce habit occurrences this week.
  ///
  /// In id, this message translates to:
  /// **'Minggu ini'**
  String get habitStatThisWeek;

  /// A stat without a value.
  ///
  /// In id, this message translates to:
  /// **'–'**
  String get habitStatNone;

  /// A whole percentage.
  ///
  /// In id, this message translates to:
  /// **'{value}%'**
  String percent(int value);

  /// Calendar legend: checked in.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get legendDone;

  /// Calendar legend: a reduce habit happened.
  ///
  /// In id, this message translates to:
  /// **'Tercatat'**
  String get legendLogged;

  /// Calendar legend: a forgiven miss.
  ///
  /// In id, this message translates to:
  /// **'Hari longgar'**
  String get legendGrace;

  /// Calendar legend: a missed scheduled day.
  ///
  /// In id, this message translates to:
  /// **'Terlewat'**
  String get legendMissed;

  /// Calendar day: today, still open.
  ///
  /// In id, this message translates to:
  /// **'Belum check-in'**
  String get legendOpen;

  /// Screen reader label of a calendar day.
  ///
  /// In id, this message translates to:
  /// **'{date}, {status}'**
  String calendarDay(String date, String status);

  /// Calendar arrow.
  ///
  /// In id, this message translates to:
  /// **'Bulan sebelumnya'**
  String get monthPrevious;

  /// Calendar arrow.
  ///
  /// In id, this message translates to:
  /// **'Bulan berikutnya'**
  String get monthNext;

  /// Reduce habit cost card.
  ///
  /// In id, this message translates to:
  /// **'Biaya bulan ini'**
  String get habitCostMonth;

  /// Yearly projection of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Proyeksi setahun ±Rp {amount} dengan pola sekarang'**
  String habitCostYear(String amount);

  /// Section of the habit detail.
  ///
  /// In id, this message translates to:
  /// **'Check-in terakhir'**
  String get habitRecentTitle;

  /// Habit detail without check-ins.
  ///
  /// In id, this message translates to:
  /// **'Belum ada check-in.'**
  String get habitRecentEmpty;

  /// Banner on an archived habit.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan ini diarsipkan.'**
  String get habitArchivedBanner;

  /// Progress toward the first week of data.
  ///
  /// In id, this message translates to:
  /// **'{current} dari {total} hari'**
  String insightsDaysProgress(int current, int total);

  /// Period phrase for the current month.
  ///
  /// In id, this message translates to:
  /// **'bulan ini'**
  String get insightsPeriodThis;

  /// Period phrase for another month, e.g. 'di Agustus'.
  ///
  /// In id, this message translates to:
  /// **'di {month}'**
  String insightsPeriodIn(String month);

  /// Caption under the share percentage on the main insight card.
  ///
  /// In id, this message translates to:
  /// **'pengeluaranmu {period} dari kebiasaan yang ingin kamu kurangi · {amount}'**
  String insightsShareCaption(String period, String amount);

  /// Shown when the month has no expenses.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran {period}.'**
  String insightsNoSpending(String period);

  /// Insights card when there is no reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kebiasaan Kurangi'**
  String get insightsNoReduceTitle;

  /// Insights card when there is no reduce habit.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan satu untuk melihat berapa biayanya dalam setahun.'**
  String get insightsNoReduceBody;

  /// Opens the new habit form from Insights.
  ///
  /// In id, this message translates to:
  /// **'Tambah kebiasaan'**
  String get insightsNoReduceAction;

  /// Section title of reduce habits.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan yang dikurangi'**
  String get insightsReduceSection;

  /// Pace and yearly projection of a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'±{perWeek}x/minggu\nProyeksi Rp {yearly}/th'**
  String insightsReduceSubtitle(String perWeek, String yearly);

  /// Section title of build habits.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan yang dibangun'**
  String get insightsBuildSection;

  /// Label of a build habit's consistency.
  ///
  /// In id, this message translates to:
  /// **'Konsistensi'**
  String get insightsConsistency;

  /// A percentage.
  ///
  /// In id, this message translates to:
  /// **'{percent}%'**
  String percentValue(int percent);

  /// Change in percentage points against last month.
  ///
  /// In id, this message translates to:
  /// **'{points} poin'**
  String insightsTrendPoints(int points);

  /// Spoken form of an upward trend.
  ///
  /// In id, this message translates to:
  /// **'naik {points} poin dibanding bulan lalu'**
  String insightsTrendUp(int points);

  /// Spoken form of a downward trend.
  ///
  /// In id, this message translates to:
  /// **'turun {points} poin dibanding bulan lalu'**
  String insightsTrendDown(int points);

  /// No change against last month.
  ///
  /// In id, this message translates to:
  /// **'Tetap'**
  String get insightsTrendFlat;

  /// Spoken form of no change.
  ///
  /// In id, this message translates to:
  /// **'sama dengan bulan lalu'**
  String get insightsTrendFlatSpoken;

  /// Section title of the donut chart.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran per kategori'**
  String get insightsCategorySection;

  /// Label in the middle of the donut.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get insightsDonutCenter;

  /// Spoken action of a category row.
  ///
  /// In id, this message translates to:
  /// **'Lihat transaksi {category}'**
  String insightsCategoryOpen(String category);

  /// Title of the simulator sheet.
  ///
  /// In id, this message translates to:
  /// **'Kalau {habit} dikurangi…'**
  String simTitle(String habit);

  /// Pace and cost behind the simulation.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata ±{perWeek} kali/minggu (4 minggu terakhir) × {cost}'**
  String simPace(String perWeek, String cost);

  /// Simulator without a pace.
  ///
  /// In id, this message translates to:
  /// **'Belum ada check-in dalam 4 minggu terakhir, jadi belum ada yang bisa dihemat.'**
  String get simNoPace;

  /// Label of the reduction slider.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get simReduceLabel;

  /// Spoken value of the slider.
  ///
  /// In id, this message translates to:
  /// **'{percent} persen'**
  String simPercentSpoken(int percent);

  /// Label above the yearly savings.
  ///
  /// In id, this message translates to:
  /// **'Hemat per tahun'**
  String get simSaveLabel;

  /// An estimated amount.
  ///
  /// In id, this message translates to:
  /// **'±{amount}'**
  String approxAmount(String amount);

  /// Toggle that shows the compound projection.
  ///
  /// In id, this message translates to:
  /// **'Tabung & kembangkan'**
  String get simInvestToggle;

  /// Explains the save and grow toggle.
  ///
  /// In id, this message translates to:
  /// **'Anggap uang yang dihemat ditabung setiap bulan.'**
  String get simInvestHint;

  /// Label of the interest rate field.
  ///
  /// In id, this message translates to:
  /// **'Bunga per tahun (%)'**
  String get simRateLabel;

  /// Error of the interest rate field.
  ///
  /// In id, this message translates to:
  /// **'Isi angka antara 0 dan 100.'**
  String get simRateInvalid;

  /// A number of years.
  ///
  /// In id, this message translates to:
  /// **'{years, plural, =1{1 tahun} other{{years} tahun}}'**
  String simHorizon(int years);

  /// Permanent disclaimer under every projection.
  ///
  /// In id, this message translates to:
  /// **'Simulasi, bukan saran keuangan.'**
  String get simDisclaimer;

  /// The limit the button would set.
  ///
  /// In id, this message translates to:
  /// **'Batas mingguan sesuai simulasi: {limit} kali'**
  String simLimitHint(int limit);

  /// Writes the simulated limit to the habit.
  ///
  /// In id, this message translates to:
  /// **'Atur batas mingguan'**
  String get simSetLimit;

  /// Snackbar after setting the limit.
  ///
  /// In id, this message translates to:
  /// **'Batas mingguan diatur ke {limit} kali'**
  String simLimitSet(int limit);

  /// Error after setting the limit.
  ///
  /// In id, this message translates to:
  /// **'Batas mingguan belum bisa diatur.'**
  String get simLimitFailed;

  /// Opens the simulator from the habit detail.
  ///
  /// In id, this message translates to:
  /// **'Simulasikan'**
  String get habitSimulate;

  /// Home insight about a reduce habit.
  ///
  /// In id, this message translates to:
  /// **'{habit} sudah {amount} bulan ini.'**
  String homeInsightReduce(String habit, String amount);

  /// Opens the simulator.
  ///
  /// In id, this message translates to:
  /// **'Lihat dampak'**
  String get homeInsightReduceAction;

  /// Home insight about a daily streak.
  ///
  /// In id, this message translates to:
  /// **'{habit}: {count} hari berturut-turut.'**
  String homeInsightStreakDays(String habit, int count);

  /// Home insight about a weekly streak.
  ///
  /// In id, this message translates to:
  /// **'{habit}: {count} minggu berturut-turut.'**
  String homeInsightStreakWeeks(String habit, int count);

  /// Opens the habit detail.
  ///
  /// In id, this message translates to:
  /// **'Lihat kebiasaan'**
  String get homeInsightStreakAction;

  /// Home insight about rising spending.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaranmu naik {percent}% dibanding periode yang sama bulan lalu.'**
  String homeInsightSpending(int percent);

  /// Opens Insights.
  ///
  /// In id, this message translates to:
  /// **'Lihat rinciannya'**
  String get homeInsightSpendingAction;

  /// Debug-only group in Settings.
  ///
  /// In id, this message translates to:
  /// **'Alat debug'**
  String get settingsGroupDebug;

  /// Debug-only row.
  ///
  /// In id, this message translates to:
  /// **'Isi data contoh 60 hari'**
  String get debugSampleTitle;

  /// Debug-only row.
  ///
  /// In id, this message translates to:
  /// **'Hanya di build debug. Menambah kebiasaan, check-in, dan transaksi contoh.'**
  String get debugSampleHint;

  /// Debug-only snackbar.
  ///
  /// In id, this message translates to:
  /// **'Data contoh terisi.'**
  String get debugSampleDone;

  /// Debug-only snackbar.
  ///
  /// In id, this message translates to:
  /// **'Data contoh sudah ada.'**
  String get debugSampleExists;

  /// Spoken label of the month picker in Insights.
  ///
  /// In id, this message translates to:
  /// **'Wawasan {month}, ganti bulan'**
  String insightsMonthPicker(String month);
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
