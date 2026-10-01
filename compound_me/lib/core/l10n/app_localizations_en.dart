// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CompoundMe';

  @override
  String get navHome => 'Home';

  @override
  String get navHabits => 'Habits';

  @override
  String get navInsights => 'Insights';

  @override
  String get navProfile => 'Profile';

  @override
  String get navAdd => 'Add transaction';

  @override
  String get homeEmptyTitle => 'No transactions yet';

  @override
  String get homeEmptyBody =>
      'Log your first one, it only takes a few seconds.';

  @override
  String get homeEmptyAction => 'Log your first transaction';

  @override
  String get habitsEmptyTitle => 'Start with one habit';

  @override
  String get habitsEmptyBody =>
      'Small habits you repeat will show their impact here.';

  @override
  String get insightsEmptyTitle => 'Insights appear after a week of logging';

  @override
  String get insightsEmptyBody => 'Log every day, then see the patterns here.';

  @override
  String get undoAction => 'Undo';

  @override
  String get catFood => 'Food & drinks';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catBills => 'Bills';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catHealth => 'Health';

  @override
  String get catEducation => 'Education';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catAllowance => 'Allowance / salary';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catGift => 'Gifts';

  @override
  String get catOtherIncome => 'Other';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionSave => 'Save';

  @override
  String get actionGotIt => 'Got it';

  @override
  String get errorSaveFailed => 'Couldn\'t save. Please try again.';

  @override
  String get keypadBackspace => 'Delete one digit';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageBody => 'You can change it anytime in Settings.';

  @override
  String get onboardingValueGrowthTitle => 'Small habits, big impact';

  @override
  String get onboardingValueGrowthBody =>
      'See what your routines really cost, then put that money toward what matters more.';

  @override
  String get onboardingValueSpeedTitle => 'Log it in seconds';

  @override
  String get onboardingValueSpeedBody =>
      'A quick keypad for spending and one tap to check in a habit.';

  @override
  String get onboardingValuePrivacyTitle => 'Private on your device';

  @override
  String get onboardingValuePrivacyBody =>
      'No account needed. Your data never leaves this phone.';

  @override
  String onboardingPageLabel(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get onboardingNameTitle => 'What should we call you?';

  @override
  String get onboardingNameBody => 'It\'s only used to greet you.';

  @override
  String get fieldName => 'Name';

  @override
  String get errorNameRequired => 'Please enter a name.';

  @override
  String get onboardingWalletTitle => 'Your first wallet';

  @override
  String get onboardingWalletBody =>
      'Where your money is tracked, like cash or a bank account.';

  @override
  String get onboardingWalletHelper => 'You can add or change wallets later.';

  @override
  String get fieldWalletName => 'Wallet name';

  @override
  String get fieldWalletType => 'Type';

  @override
  String get fieldInitialBalance => 'Starting balance';

  @override
  String get walletDefaultName => 'Cash';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeEwallet => 'E-wallet';

  @override
  String get walletTypeOther => 'Other';

  @override
  String get onboardingHabitsTitle => 'Pick your habits';

  @override
  String get onboardingHabitsBody => 'Pick up to 3. You can change them later.';

  @override
  String get habitGroupBuild => 'Want to build';

  @override
  String get habitGroupReduce => 'Want to cut down';

  @override
  String get templateExercise => 'Exercise';

  @override
  String get templateRead => 'Read 10 pages';

  @override
  String get templatePackLunch => 'Pack lunch';

  @override
  String get templateDrinkWater => 'Drink 8 glasses of water';

  @override
  String get templateCafeCoffee => 'Café coffee';

  @override
  String get templateLateSnacks => 'Late-night snacks';

  @override
  String get templateShortRides => 'Short ride-hailing trips';

  @override
  String get templateImpulseBuys => 'Impulse buys';

  @override
  String get scheduleDaily => 'Every day';

  @override
  String get scheduleWorkdays => 'Weekdays';

  @override
  String scheduleTimesPerWeek(int count) {
    return '${count}x a week';
  }

  @override
  String templateCostEdit(String template, String amount) {
    return 'Change the cost of $template, now $amount';
  }

  @override
  String get templateCostTitle => 'Cost each time';

  @override
  String get actionStart => 'Start';

  @override
  String get actionSkipForNow => 'Skip for now';

  @override
  String get coachMarkAdd => 'Log spending and income with this button.';

  @override
  String get errorLoadTitle => 'Couldn\'t load this';

  @override
  String get errorLoadBody => 'Please try again in a moment.';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionRestore => 'Restore';

  @override
  String get fieldIcon => 'Icon';

  @override
  String get fieldColor => 'Color';

  @override
  String get iconPickerTitle => 'Choose an icon';

  @override
  String iconPosition(int position, int total) {
    return 'Icon $position of $total';
  }

  @override
  String get presetTeal => 'Teal';

  @override
  String get presetGold => 'Gold';

  @override
  String get presetCoral => 'Coral';

  @override
  String get presetViolet => 'Violet';

  @override
  String get presetBlue => 'Blue';

  @override
  String get presetGreen => 'Green';

  @override
  String get presetRose => 'Rose';

  @override
  String get presetSlate => 'Slate';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get walletsTotal => 'TOTAL BALANCE';

  @override
  String get walletsAdd => 'Add wallet';

  @override
  String walletsArchived(int count) {
    return 'Archived ($count)';
  }

  @override
  String walletsReorder(String name) {
    return 'Drag to reorder $name';
  }

  @override
  String get walletsEmptyTitle => 'No active wallets';

  @override
  String get walletsEmptyBody => 'Add a wallet to start logging.';

  @override
  String get walletNewTitle => 'New wallet';

  @override
  String get walletEditTitle => 'Edit wallet';

  @override
  String get walletBalanceHelper =>
      'The current balance moves by the same difference.';

  @override
  String get walletArchive => 'Archive wallet';

  @override
  String get walletArchiveHint => 'Hidden from pickers; its history stays.';

  @override
  String get walletDelete => 'Delete wallet';

  @override
  String get walletDeleteHint => 'It hasn\'t been used, so it can be deleted.';

  @override
  String get walletLastActive => 'You need at least one active wallet.';

  @override
  String get walletArchivedDone => 'Wallet archived';

  @override
  String get walletDeletedDone => 'Wallet deleted';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryKindExpense => 'Expenses';

  @override
  String get categoryKindIncome => 'Income';

  @override
  String get categoriesAdd => 'Add category';

  @override
  String categoriesArchived(int count) {
    return 'Archived ($count)';
  }

  @override
  String get categoriesEmptyTitle => 'No active categories';

  @override
  String get categoriesEmptyBody => 'Add a category of this kind.';

  @override
  String get categoryNewTitle => 'New category';

  @override
  String get categoryEditTitle => 'Edit category';

  @override
  String get fieldCategoryName => 'Category name';

  @override
  String get categoryDefaultNameHelper =>
      'Built-in category names follow the app language.';

  @override
  String get categoryArchive => 'Archive category';

  @override
  String get categoryArchiveHint =>
      'Hidden from pickers; its transactions stay.';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String get categoryDeleteHint =>
      'It hasn\'t been used, so it can be deleted.';

  @override
  String get categoryArchivedDone => 'Category archived';

  @override
  String get categoryDeletedDone => 'Category deleted';

  @override
  String profileEditName(String name) {
    return 'Change name, $name';
  }

  @override
  String get profileNameTitle => 'Your name';

  @override
  String get profileTapToEdit => 'Tap to change';

  @override
  String get profileGroupFinance => 'Money';

  @override
  String get profileGroupApp => 'App';

  @override
  String get profileGroupAbout => 'About';

  @override
  String profileActiveWallets(int count) {
    return '$count active';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupDisplay => 'Display';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsHideBalance => 'Hide balance';

  @override
  String get settingsHideBalanceHint =>
      'Your balance is hidden when the app opens. Tap the eye icon to see it.';

  @override
  String get settingsGroupData => 'Data';

  @override
  String get settingsDeleteAll => 'Delete all data';

  @override
  String get deleteAllTitle => 'Delete all data?';

  @override
  String get deleteAllBody =>
      'All transactions, habits, wallets, your own categories and settings will be removed from this phone. This can\'t be undone.';

  @override
  String get deleteAllContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get deleteAllWord => 'DELETE';

  @override
  String deleteAllTypeLabel(String word) {
    return 'Type $word to delete';
  }

  @override
  String get aboutTitle => 'About CompoundMe';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutCreator => 'Made by Hisyam Khaeru Umam';

  @override
  String get aboutSource => 'Source code on GitHub';

  @override
  String get aboutLicenses => 'Open source licenses';

  @override
  String get linkOpenFailed => 'Couldn\'t open the link.';

  @override
  String get languageIndonesianShort => 'Indonesia';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardBody => 'Your unsaved changes will be lost.';

  @override
  String get discardAction => 'Discard';

  @override
  String get keepEditingAction => 'Keep editing';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingMidday => 'Good afternoon';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingNight => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String dateTimeJoin(String date, String time) {
    return '$date, $time';
  }

  @override
  String get balanceShow => 'Show balance';

  @override
  String get balanceHide => 'Hide balance';

  @override
  String get balanceHidden => 'Balance hidden';

  @override
  String get homeRecentTitle => 'Recent transactions';

  @override
  String get homeSeeAll => 'See all';

  @override
  String summaryMonthPicker(String month) {
    return 'Summary for $month, change month';
  }

  @override
  String get monthPickerTitle => 'Choose month';

  @override
  String get txAddTitle => 'Add transaction';

  @override
  String get txEditTitle => 'Edit transaction';

  @override
  String get actionClose => 'Close';

  @override
  String get txKindExpense => 'Expense';

  @override
  String get txKindIncome => 'Income';

  @override
  String get txWallet => 'Wallet';

  @override
  String get txDate => 'Date';

  @override
  String get txNote => 'Note';

  @override
  String get txNoteHint => 'For example: office lunch';

  @override
  String get txNoteAdd => 'Add a note (optional)';

  @override
  String get txSaveChanges => 'Save changes';

  @override
  String get txCategoryAll => 'All';

  @override
  String get txCategoryPickerTitle => 'Choose category';

  @override
  String get txWalletPickerTitle => 'Choose wallet';

  @override
  String get txDatePickerTitle => 'Choose date';

  @override
  String get txSaved => 'Saved';

  @override
  String get txDeleted => 'Transaction deleted';

  @override
  String get txHabitTag => 'Habit';

  @override
  String txFromHabit(String name) {
    return 'From habit: $name';
  }

  @override
  String get txFromHabitUnknown => 'From a habit check-in';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionDelete => 'Delete';

  @override
  String get txDeleteHabitTitle => 'Delete this transaction?';

  @override
  String txDeleteHabitBody(String name) {
    return 'This also undoes that day\'s $name check-in.';
  }

  @override
  String get txDeleteHabitBodyUnknown =>
      'This also undoes that day\'s habit check-in.';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get txSearchHint => 'Search notes or categories';

  @override
  String get txSearchClear => 'Clear search';

  @override
  String get txFilterCategory => 'Category';

  @override
  String get txFilterAllCategories => 'All categories';

  @override
  String get txFilterWallet => 'Wallet';

  @override
  String get txFilterAllWallets => 'All wallets';

  @override
  String get txNoMatchTitle => 'No matching transactions';

  @override
  String get txNoMatchBody => 'Try other words or clear the filters.';

  @override
  String get txClearFilters => 'Clear filters';

  @override
  String get txIncome => 'In';

  @override
  String get txExpense => 'Out';

  @override
  String get txNet => 'Net';

  @override
  String txFilterCategoryWithKind(String name, String kind) {
    return '$name ($kind)';
  }

  @override
  String get summaryTitle => 'Summary';

  @override
  String get txSearchResults => 'Search results';

  @override
  String get txAllMonths => 'All months';

  @override
  String txShowMonth(String month) {
    return 'See $month';
  }

  @override
  String txMonthEmptyTitle(String month) {
    return 'No transactions in $month';
  }

  @override
  String get txMonthEmptyBody =>
      'Transactions of that month show up here once logged.';

  @override
  String get habitKindBuild => 'Build';

  @override
  String get habitKindReduce => 'Reduce';

  @override
  String get habitCreate => 'Create a habit';

  @override
  String get habitFromTemplate => 'Pick from a template';

  @override
  String get habitTemplatesTitle => 'Pick from a template';

  @override
  String get habitsFilterToday => 'Today';

  @override
  String get habitsFilterAll => 'All';

  @override
  String get habitsMore => 'More options';

  @override
  String get habitsReorder => 'Reorder';

  @override
  String get habitsReorderDone => 'Done';

  @override
  String get habitsNoneToday => 'No habits scheduled today.';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String streakWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String habitCostPer(String amount) {
    return '$amount each time';
  }

  @override
  String habitThisWeek(int count) {
    return 'this week $count';
  }

  @override
  String habitThisWeekOf(int count, int limit) {
    return 'this week $count/$limit';
  }

  @override
  String get habitSetLimitCta => 'Set a weekly limit to start a streak';

  @override
  String habitCheckInOpen(String name) {
    return '$name, not checked in today';
  }

  @override
  String habitCheckInDone(String name) {
    return '$name, checked in today';
  }

  @override
  String habitCheckInCount(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$name, checked in $_temp0 today';
  }

  @override
  String get habitLogged => 'Logged';

  @override
  String get habitUnlogged => 'Check-in undone';

  @override
  String get habitCountToday => 'How many today';

  @override
  String habitCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String habitCountCost(int count, String cost, String total) {
    return '$count × $cost = $total';
  }

  @override
  String habitCountMax(int max) {
    return 'At most $max times a day.';
  }

  @override
  String get stepperDecrease => 'One less';

  @override
  String get stepperIncrease => 'One more';

  @override
  String get homeHabitsTitle => 'Today\'s habits';

  @override
  String get homeHabitsAll => 'All';

  @override
  String get homeHabitsFirst => 'Add your first habit';

  @override
  String get habitNewTitle => 'New habit';

  @override
  String get habitEditTitle => 'Edit habit';

  @override
  String get habitKindField => 'Kind';

  @override
  String get habitKindBuildHint =>
      'Something to do more, like exercise or reading.';

  @override
  String get habitKindReduceHint =>
      'It costs money and you want less of it, like café coffee.';

  @override
  String get fieldHabitName => 'Habit name';

  @override
  String get habitNameHint => 'For example: Read 10 pages';

  @override
  String get habitScheduleField => 'Schedule';

  @override
  String get scheduleSpecificDays => 'Some days';

  @override
  String get scheduleTimesOption => 'N times a week';

  @override
  String get habitTimesPerWeekField => 'Target per week';

  @override
  String habitTimesPerWeekValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a week',
      one: 'once a week',
    );
    return '$_temp0';
  }

  @override
  String get habitDaysError => 'Pick at least one day.';

  @override
  String get habitCostField => 'Cost each time';

  @override
  String get habitCostSet => 'Set the cost';

  @override
  String get habitCostError => 'Enter a cost above Rp 0.';

  @override
  String get habitWalletError => 'Choose a wallet.';

  @override
  String get habitCategoryField => 'Category';

  @override
  String get habitCategoryError => 'Choose an expense category.';

  @override
  String get habitLimitField => 'Weekly limit';

  @override
  String get habitLimitNone => 'No limit';

  @override
  String habitLimitValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String get habitLimitHelper =>
      'A week at or under the limit counts as a success and keeps the streak.';

  @override
  String get habitArchive => 'Archive habit';

  @override
  String get habitArchiveHint => 'Its history and expenses stay.';

  @override
  String get habitDelete => 'Delete habit';

  @override
  String get habitDeleteHint =>
      'It has no check-ins yet, so it can be deleted.';

  @override
  String get habitArchivedDone => 'Habit archived';

  @override
  String get habitDeletedDone => 'Habit deleted';

  @override
  String get habitKindLockedTitle => 'The kind can\'t change';

  @override
  String habitKindLockedBody(String kind) {
    return 'This habit has check-ins, so its history and expenses stay with its current kind. Create a new habit to make it $kind.';
  }

  @override
  String get habitKindLockedAction => 'Create a new habit';

  @override
  String get habitStatStreak => 'Streak';

  @override
  String get habitStatBest => 'Best';

  @override
  String get habitStatConsistency => '30-day consistency';

  @override
  String get habitStatThisWeek => 'This week';

  @override
  String get habitStatNone => '–';

  @override
  String percent(int value) {
    return '$value%';
  }

  @override
  String get legendDone => 'Done';

  @override
  String get legendLogged => 'Logged';

  @override
  String get legendGrace => 'Grace day';

  @override
  String get legendMissed => 'Missed';

  @override
  String get legendOpen => 'Not checked in yet';

  @override
  String calendarDay(String date, String status) {
    return '$date, $status';
  }

  @override
  String get monthPrevious => 'Previous month';

  @override
  String get monthNext => 'Next month';

  @override
  String get habitCostMonth => 'Cost this month';

  @override
  String habitCostYear(String amount) {
    return 'About Rp $amount a year at this pace';
  }

  @override
  String get habitRecentTitle => 'Latest check-ins';

  @override
  String get habitRecentEmpty => 'No check-ins yet.';

  @override
  String get habitArchivedBanner => 'This habit is archived.';
}
