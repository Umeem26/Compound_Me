import 'package:compound_me/core/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// "3,1" (id) or "3.1" (en): occurrences per week with one decimal.
String perWeekText(AppLocalizations l10n, double perWeek) =>
    NumberFormat('0.0', l10n.localeName).format(perWeek);
