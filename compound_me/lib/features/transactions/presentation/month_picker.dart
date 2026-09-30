import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/date_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:flutter/widgets.dart';

/// Months from the oldest transaction up to [now], newest first, as a
/// sheet (S-10 summary, S-13 filter). Returns the picked month.
Future<YearMonth?> showMonthPicker(
  BuildContext context, {
  required YearMonth selected,
  required DateTime now,
  required DateTime? firstOccurredAt,
}) {
  final l10n = context.l10n;
  final current = YearMonth.of(now);
  var oldest = firstOccurredAt == null
      ? current
      : YearMonth.of(firstOccurredAt);
  if (selected.compareTo(oldest) < 0) oldest = selected;
  if (oldest.compareTo(current) > 0) oldest = current;
  return showOptionSheet<YearMonth>(
    context,
    title: l10n.monthPickerTitle,
    selected: selected,
    options: [
      for (
        var month = current;
        month.compareTo(oldest) >= 0;
        month = month.addMonths(-1)
      )
        SheetOption(
          value: month,
          label: l10n.monthLabel(month.year, month.month),
        ),
    ],
  );
}
