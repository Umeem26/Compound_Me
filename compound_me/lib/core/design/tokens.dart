import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Raw palette from docs/v2/02-design-system.md §3. Widgets must go through
/// the theme-aware [AppColors] instead of reading these directly.
abstract final class AppPalette {
  static const teal50 = Color(0xFFE6F2F0);
  static const teal100 = Color(0xFFCCE5E1);
  static const teal200 = Color(0xFF99CBC3);
  static const teal400 = Color(0xFF4DB6AC);
  static const teal700 = Color(0xFF00695C);
  static const teal800 = Color(0xFF004D40);
  static const teal900 = Color(0xFF00332E);

  static const gold50 = Color(0xFFFDF6E3);
  static const gold100 = Color(0xFFFAEBC2);
  static const gold300 = Color(0xFFF2CF6B);
  static const gold500 = Color(0xFFE0A91B);
  static const gold800 = Color(0xFF8A6400);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

/// The eight preset colors for categories, wallets and habits (§3.5).
/// Stored in the database by [key], never as a raw color value.
///
/// Each preset has an icon color per theme so the icon keeps at least 3:1
/// against its own tint (WCAG 1.4.11). Where the §3.5 value falls short in
/// one theme it is replaced there (§3.5 table); the others are unchanged.
enum AppPresetColor {
  teal('teal', AppPalette.teal700, dark: AppPalette.teal400),
  gold('gold', AppPalette.gold800, dark: AppPalette.gold500),
  coral('coral', Color(0xFFD45147), dark: Color(0xFFD9655B)),
  violet('violet', Color(0xFF7C6BC4)),
  blue('blue', Color(0xFF3F7FD1)),
  green('green', Color(0xFF3B8E56), dark: Color(0xFF3E9A5C)),
  rose('rose', Color(0xFFC45A8A)),
  slate('slate', Color(0xFF5F6F7A), dark: Color(0xFF657883));

  const AppPresetColor(this.key, this.light, {Color? dark})
    : dark = dark ?? light;

  final String key;
  final Color light;
  final Color dark;

  Color foreground(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Icons sit on a 12% tint of the preset, never on a solid fill.
  Color background(Brightness brightness) =>
      foreground(brightness).withValues(alpha: AppOpacity.presetTint);

  static AppPresetColor fromKey(String key) =>
      values.firstWhere((c) => c.key == key, orElse: () => AppPresetColor.teal);
}

/// Theme-aware color roles (§3.2, §3.3, §11).
@immutable
class AppColors {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.onPrimary,
    required this.primaryPressed,
    required this.primaryTint,
    required this.primaryTintPressed,
    required this.onPrimaryTint,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    required this.income,
    required this.expense,
    required this.danger,
    required this.onDanger,
    required this.dangerTint,
    required this.dangerTintPressed,
    required this.onDangerTint,
    required this.warning,
    required this.success,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
  });

  final Color bg;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color primary;
  final Color onPrimary;
  final Color primaryPressed;
  final Color primaryTint;
  final Color primaryTintPressed;
  final Color onPrimaryTint;
  final Color accent;
  final Color onAccent;
  final Color accentText;
  final Color income;
  final Color expense;
  final Color danger;
  final Color onDanger;
  final Color dangerTint;
  final Color dangerTintPressed;

  /// Text on [dangerTint]; one step deeper than [danger] so labels keep
  /// 4.5:1 even while pressed (02 §11.1).
  final Color onDangerTint;
  final Color warning;
  final Color success;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  static const light = AppColors(
    bg: Color(0xFFF7F9F8),
    surface: AppPalette.white,
    surfaceMuted: Color(0xFFEFF2F1),
    border: Color(0xFFE2E7E5),
    textPrimary: Color(0xFF121917),
    textSecondary: Color(0xFF5C6865),
    textTertiary: Color(0xFF6B7774),
    primary: AppPalette.teal700,
    onPrimary: AppPalette.white,
    primaryPressed: AppPalette.teal800,
    primaryTint: AppPalette.teal50,
    primaryTintPressed: AppPalette.teal100,
    onPrimaryTint: AppPalette.teal700,
    accent: AppPalette.gold500,
    onAccent: AppPalette.teal900,
    accentText: AppPalette.gold800,
    income: AppPalette.teal700,
    expense: Color(0xFF121917),
    danger: Color(0xFFC53B3B),
    onDanger: AppPalette.white,
    dangerTint: Color(0xFFFAEFEF),
    dangerTintPressed: Color(0xFFF8E7E7),
    onDangerTint: Color(0xFFB23434),
    warning: AppPalette.gold800,
    success: AppPalette.teal700,
    inverseSurface: Color(0xFF121917),
    onInverseSurface: Color(0xFFF7F9F8),
    inversePrimary: AppPalette.teal400,
  );

  static const dark = AppColors(
    bg: Color(0xFF0C1211),
    surface: Color(0xFF141C1A),
    surfaceMuted: Color(0xFF1C2624),
    border: Color(0xFF2A3533),
    textPrimary: Color(0xFFE8EEEC),
    textSecondary: Color(0xFFA7B3B0),
    textTertiary: Color(0xFF7A8683),
    primary: AppPalette.teal400,
    onPrimary: AppPalette.teal900,
    // One step darker than teal400 while keeping teal900 text readable;
    // teal700 would drop that contrast below 3:1.
    primaryPressed: Color(0xFF3B978E),
    // teal400 at 16% (pressed: 24%) over the dark surface, precomputed opaque.
    primaryTint: Color(0xFF1D3531),
    primaryTintPressed: Color(0xFF22413D),
    onPrimaryTint: AppPalette.teal400,
    accent: AppPalette.gold300,
    onAccent: AppPalette.teal900,
    accentText: AppPalette.gold300,
    income: AppPalette.teal400,
    expense: Color(0xFFE8EEEC),
    danger: Color(0xFFF07070),
    onDanger: AppPalette.teal900,
    // danger at 16% (pressed: 24%) over the dark surface, precomputed opaque.
    dangerTint: Color(0xFF372928),
    dangerTintPressed: Color(0xFF49302F),
    onDangerTint: Color(0xFFF48686),
    warning: AppPalette.gold300,
    success: AppPalette.teal400,
    inverseSurface: Color(0xFFE8EEEC),
    onInverseSurface: Color(0xFF0C1211),
    inversePrimary: AppPalette.teal700,
  );

  AppColors lerp(AppColors other, double t) => AppColors(
    bg: Color.lerp(bg, other.bg, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
    border: Color.lerp(border, other.border, t)!,
    textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    primary: Color.lerp(primary, other.primary, t)!,
    onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
    primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
    primaryTintPressed: Color.lerp(
      primaryTintPressed,
      other.primaryTintPressed,
      t,
    )!,
    onPrimaryTint: Color.lerp(onPrimaryTint, other.onPrimaryTint, t)!,
    accent: Color.lerp(accent, other.accent, t)!,
    onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    accentText: Color.lerp(accentText, other.accentText, t)!,
    income: Color.lerp(income, other.income, t)!,
    expense: Color.lerp(expense, other.expense, t)!,
    danger: Color.lerp(danger, other.danger, t)!,
    onDanger: Color.lerp(onDanger, other.onDanger, t)!,
    dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
    dangerTintPressed: Color.lerp(
      dangerTintPressed,
      other.dangerTintPressed,
      t,
    )!,
    onDangerTint: Color.lerp(onDangerTint, other.onDangerTint, t)!,
    warning: Color.lerp(warning, other.warning, t)!,
    success: Color.lerp(success, other.success, t)!,
    inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
    onInverseSurface: Color.lerp(onInverseSurface, other.onInverseSurface, t)!,
    inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
  );
}

/// 4 dp grid (§5). No other spacing values are allowed in widgets.
abstract final class AppSpacing {
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  static const double screenHorizontal = space5;
}

abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;
}

abstract final class AppSizes {
  static const double minTouchTarget = 48;
  static const double buttonHeight = 52;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;
  static const double addButton = 56;
  static const double addButtonLift = 8;
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 28;
  static const double emptyStateIcon = 48;
  static const double emptyStateCircle = 88;
  static const double segmentedHeight = 40;
  static const double spinner = 20;
  static const double spinnerStroke = 2;
  static const double border = 1;
  static const double borderSelected = 2;

  /// List rows, RowPicker and settings rows (§7.5).
  static const double row = 56;
  static const double textField = 52;
  static const double keypadKey = 56;
  static const double iconBadge = 40;
  static const double iconBadgeLarge = 56;
  static const double transactionTile = 64;
  static const double chip = 40;
  static const double calendarDay = 36;
  static const double calendarDot = 4;
  static const double habitChip = 56;
  static const double habitChipRing = 3;
  static const double habitChipLabel = 72;
  static const double checkButton = 44;
  static const double habitTile = 72;
  static const double badge = 20;
  static const double iconButtonTonal = 40;
  static const double avatar = 64;
  static const double avatarSmall = 40;
  static const double colorSwatch = 32;
  static const double selectableCardMin = 72;
  static const double pageDot = 8;
  static const double pageDotActive = 24;
  static const double onboardingArt = 240;
  static const double coachMarkPointer = 8;
  static const double coachMarkMaxWidth = 280;
  static const double skeletonLine = 16;
  static const double skeletonAmount = 180;
  static const double appIcon = 72;
  static const double proportionBar = 8;
  static const double donut = 176;
  static const double donutRing = 28;
  static const double donutGap = 2;
  static const double progressRing = 48;
  static const double progressRingStroke = 4;
  static const double sliderTrack = 6;
  static const double sliderThumb = 12;
  static const double legendDot = 12;
}

abstract final class AppOpacity {
  static const double disabled = 0.4;
  static const double presetTint = 0.12;
  static const double shadow = 0.06;

  /// Low point of the skeleton shimmer (§7.6: 0.5 to 1).
  static const double skeletonLow = 0.5;
}

abstract final class AppScale {
  static const double pressed = 0.98;
}

/// Motion tokens (§8). Durations collapse to zero when the device asks for
/// reduced motion, see [AppDurations.resolve].
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration sheet = Duration(milliseconds: 320);
  static const Duration undoWindow = Duration(seconds: 4);

  /// Local data is usually instant; a skeleton only appears after this
  /// (03 §4) so nothing flickers.
  static const Duration skeletonDelay = Duration(milliseconds: 300);
  static const Duration shimmer = Duration(milliseconds: 1200);

  static const Curve fastCurve = Curves.easeOut;
  static const Curve baseCurve = Curves.easeOutCubic;
  static const Curve sheetInCurve = Curves.easeOutCubic;
  static const Curve sheetOutCurve = Curves.easeInCubic;

  static Duration resolve(Duration duration, {required bool reduceMotion}) =>
      reduceMotion ? Duration.zero : duration;
}

/// Only floating elements (bottom sheet, add button, snackbar) cast a shadow,
/// and only in the light theme (§5, §11).
abstract final class AppShadows {
  static const List<BoxShadow> floatingLight = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, AppOpacity.shadow),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];
  static const List<BoxShadow> none = [];
}
