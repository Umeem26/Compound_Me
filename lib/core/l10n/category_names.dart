import 'package:compound_me/core/l10n/app_localizations.dart';
import 'package:compound_me/features/categories/domain/category.dart';

/// Display name of a category: the translated default name for seeded
/// categories, or the name the user typed for custom ones.
String categoryName(AppLocalizations l10n, Category category) =>
    category.customName ?? defaultCategoryName(l10n, category.nameKey!);

/// Translation of a default category `nameKey` (05 §5). Throws for unknown
/// keys so a new seed entry without a translation fails loudly in tests.
String defaultCategoryName(AppLocalizations l10n, String nameKey) =>
    switch (nameKey) {
      'catFood' => l10n.catFood,
      'catTransport' => l10n.catTransport,
      'catShopping' => l10n.catShopping,
      'catBills' => l10n.catBills,
      'catEntertainment' => l10n.catEntertainment,
      'catHealth' => l10n.catHealth,
      'catEducation' => l10n.catEducation,
      'catOtherExpense' => l10n.catOtherExpense,
      'catAllowance' => l10n.catAllowance,
      'catFreelance' => l10n.catFreelance,
      'catGift' => l10n.catGift,
      'catOtherIncome' => l10n.catOtherIncome,
      _ => throw ArgumentError.value(nameKey, 'nameKey', 'Unknown category'),
    };
