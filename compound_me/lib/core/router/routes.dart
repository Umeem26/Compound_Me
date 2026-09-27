/// Route paths from docs/v2/03-ux-flows-and-screens.md §1.
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const habits = '/habits';
  static const insights = '/insights';
  static const me = '/me';
  static const wallets = '/me/wallets';
  static const walletNew = '/me/wallets/new';
  static String wallet(String id) => '/me/wallets/$id';
}
