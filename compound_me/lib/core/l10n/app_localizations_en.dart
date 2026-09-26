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
}
