import 'package:compound_me/core/database/app_database.dart';
import 'package:compound_me/core/utils/dates.dart';
import 'package:compound_me/core/utils/id.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

@immutable
class DefaultCategory {
  const DefaultCategory(this.nameKey, this.kind, this.iconKey, this.colorKey);

  final String nameKey;
  final CategoryKind kind;
  final String iconKey;
  final String colorKey;
}

/// Default categories from S-42. Names are l10n keys, translated at display
/// time; icon and color keys come from AppIcons.byKey and AppPresetColor.
const defaultCategories = <DefaultCategory>[
  DefaultCategory('catFood', CategoryKind.expense, 'forkKnife', 'coral'),
  DefaultCategory('catTransport', CategoryKind.expense, 'bus', 'blue'),
  DefaultCategory('catShopping', CategoryKind.expense, 'shoppingBag', 'rose'),
  DefaultCategory('catBills', CategoryKind.expense, 'receipt', 'slate'),
  DefaultCategory(
    'catEntertainment',
    CategoryKind.expense,
    'filmSlate',
    'violet',
  ),
  DefaultCategory('catHealth', CategoryKind.expense, 'firstAidKit', 'green'),
  DefaultCategory(
    'catEducation',
    CategoryKind.expense,
    'graduationCap',
    'gold',
  ),
  DefaultCategory(
    'catOtherExpense',
    CategoryKind.expense,
    'dotsThreeCircle',
    'slate',
  ),
  DefaultCategory('catAllowance', CategoryKind.income, 'wallet', 'teal'),
  DefaultCategory('catFreelance', CategoryKind.income, 'laptop', 'blue'),
  DefaultCategory('catGift', CategoryKind.income, 'gift', 'rose'),
  DefaultCategory(
    'catOtherIncome',
    CategoryKind.income,
    'dotsThreeCircle',
    'teal',
  ),
];

Future<void> seedDefaultCategories(AppDatabase db, {required DateTime now}) {
  final timestamp = toStoredUtc(now);
  return db.batch((batch) {
    batch.insertAll(db.categories, [
      for (final (index, category) in defaultCategories.indexed)
        CategoriesCompanion.insert(
          id: newId(),
          kind: category.kind,
          nameKey: Value(category.nameKey),
          iconKey: category.iconKey,
          colorKey: category.colorKey,
          sortOrder: Value(index),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
    ]);
  });
}
