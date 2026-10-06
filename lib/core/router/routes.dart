/// Route paths from docs/design/03-ux-flows-and-screens.md §1.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const transactions = '/transactions';
  static const habits = '/habits';
  static const habitNew = '/habits/new';
  static String habit(String id) => '/habits/$id';
  static String habitEdit(String id) => '/habits/$id/edit';
  static const insights = '/insights';

  /// S-13 inside the Wawasan tab, so back returns to Wawasan (S-30 donut).
  static String insightsTransactions({
    required String month,
    String? category,
  }) =>
      '/insights/transactions?month=$month'
      '${category == null ? '' : '&category=$category'}';
  static const me = '/me';
  static const wallets = '/me/wallets';
  static const walletNew = '/me/wallets/new';
  static String wallet(String id) => '/me/wallets/$id';
  static const categories = '/me/categories';
  static String categoryNew(String kind) => '/me/categories/new?kind=$kind';
  static String category(String id) => '/me/categories/$id';
  static const settings = '/me/settings';
  static const about = '/me/about';
}
