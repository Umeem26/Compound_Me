import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/preferences/app_preferences.dart';
import 'package:compound_me/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompoundMeApp extends ConsumerStatefulWidget {
  const CompoundMeApp({super.key});

  @override
  ConsumerState<CompoundMeApp> createState() => _CompoundMeAppState();
}

class _CompoundMeAppState extends ConsumerState<CompoundMeApp> {
  static final ThemeData _lightTheme = AppTheme.light();
  static final ThemeData _darkTheme = AppTheme.dark();

  @override
  void initState() {
    super.initState();
    // Bootstrap already ran behind the native splash; drop it as soon as the
    // router has painted its first frame so there is no second splash.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FlutterNativeSplash.remove(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: ref.watch(themeModeSettingProvider),
      locale: ref.watch(localeSettingProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveAppLocale,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
