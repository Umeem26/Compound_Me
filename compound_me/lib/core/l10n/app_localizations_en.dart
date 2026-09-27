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
  String get profileEmptyTitle => 'Your profile isn\'t set up yet';

  @override
  String get profileEmptyBody => 'Your nickname and wallets will be kept here.';

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
}
