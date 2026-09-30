import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/app_shell.dart';
import 'package:compound_me/core/router/routes.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/presentation/categories_screen.dart';
import 'package:compound_me/features/categories/presentation/category_editor_screen.dart';
import 'package:compound_me/features/habits/presentation/habits_screen.dart';
import 'package:compound_me/features/home/presentation/home_screen.dart';
import 'package:compound_me/features/insights/presentation/insights_screen.dart';
import 'package:compound_me/features/onboarding/presentation/onboarding_screen.dart';
import 'package:compound_me/features/settings/presentation/about_screen.dart';
import 'package:compound_me/features/settings/presentation/profile_screen.dart';
import 'package:compound_me/features/settings/presentation/settings_screen.dart';
import 'package:compound_me/features/wallets/presentation/wallet_editor_screen.dart';
import 'package:compound_me/features/wallets/presentation/wallets_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Onboarding runs once; until it is done every route leads to it, and
  // afterwards it can't be reopened (PRD US-02.1).
  final onboardingDone = ValueNotifier(ref.read(onboardingDoneProvider));
  ref
    ..listen(onboardingDoneProvider, (_, done) => onboardingDone.value = done)
    ..onDispose(onboardingDone.dispose);

  // Full-screen forms cover the bottom navigation, so they live on the
  // root navigator instead of the tab's own.
  final rootNavigator = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigator,
    initialLocation: AppRoutes.home,
    refreshListenable: onboardingDone,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboardingDone.value) {
        return atOnboarding ? null : AppRoutes.onboarding;
      }
      return atOnboarding ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // indexedStack keeps each tab's state when switching (05 §1).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.habits,
                builder: (context, state) => const HabitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.insights,
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.me,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'wallets',
                    builder: (context, state) => const WalletsScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        parentNavigatorKey: rootNavigator,
                        builder: (context, state) => const WalletEditorScreen(),
                      ),
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: rootNavigator,
                        builder: (context, state) => WalletEditorScreen(
                          walletId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (context, state) => const AboutScreen(),
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CategoriesScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        parentNavigatorKey: rootNavigator,
                        builder: (context, state) => CategoryEditorScreen(
                          kind:
                              CategoryKind.values.asNameMap()[state
                                  .uri
                                  .queryParameters['kind']] ??
                              CategoryKind.expense,
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        parentNavigatorKey: rootNavigator,
                        builder: (context, state) => CategoryEditorScreen(
                          categoryId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
