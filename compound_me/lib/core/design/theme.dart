import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tokens that have no slot in [ColorScheme] (income, accent, surfaceMuted,
/// shadows, ...). Widgets read them through `context.tokens`.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({required this.colors, required this.floatingShadow});

  final AppColors colors;
  final List<BoxShadow> floatingShadow;

  @override
  AppTokens copyWith({AppColors? colors, List<BoxShadow>? floatingShadow}) =>
      AppTokens(
        colors: colors ?? this.colors,
        floatingShadow: floatingShadow ?? this.floatingShadow,
      );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      colors: colors.lerp(other.colors, t),
      floatingShadow: t < 0.5 ? floatingShadow : other.floatingShadow,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    colors: AppColors.light,
    floatingShadow: AppShadows.floatingLight,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    colors: AppColors.dark,
    floatingShadow: AppShadows.none,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors colors,
    required List<BoxShadow> floatingShadow,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryTint,
      onPrimaryContainer: colors.onPrimaryTint,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      error: colors.danger,
      onError: colors.onDanger,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      surfaceContainerLowest: colors.surface,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.surface,
      surfaceContainerHigh: colors.surfaceMuted,
      surfaceContainerHighest: colors.surfaceMuted,
      outline: colors.border,
      outlineVariant: colors.border,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.onInverseSurface,
      inversePrimary: colors.inversePrimary,
      shadow: AppPalette.black,
      scrim: AppPalette.black,
      // Flat design: no M3 elevation tint on surfaces.
      surfaceTint: colors.surface.withValues(alpha: 0),
    );

    final textTheme = const TextTheme(
      displaySmall: AppTextStyles.amountHero,
      headlineSmall: AppTextStyles.titleLarge,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.caption,
      labelSmall: AppTextStyles.overline,
    ).apply(bodyColor: colors.textPrimary, displayColor: colors.textPrimary);

    final overlayStyle = brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.bg,
      canvasColor: colors.bg,
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: AppSizes.border,
        space: AppSizes.border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bg,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleSmall.copyWith(
          color: colors.textPrimary,
        ),
        systemOverlayStyle: overlayStyle,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: colors.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: colors.onInverseSurface,
        ),
        actionTextColor: colors.inversePrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: AppSizes.iconMd,
      ),
      extensions: [AppTokens(colors: colors, floatingShadow: floatingShadow)],
    );
  }
}
