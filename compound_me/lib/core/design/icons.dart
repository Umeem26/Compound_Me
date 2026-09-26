import 'package:flutter/widgets.dart';

/// Curated Phosphor icons (§6). The fonts in assets/fonts/phosphor are the
/// ones shipped with phosphor_flutter 2.1.0, and the codepoints below come
/// from that same release. Add an icon here before using it anywhere else.
abstract final class AppIcons {
  static const String _regular = 'PhosphorRegular';
  static const String _fill = 'PhosphorFill';

  static const IconData house = IconData(0xe2c2, fontFamily: _regular);
  static const IconData houseFill = IconData(0xe2c2, fontFamily: _fill);
  static const IconData checkCircle = IconData(0xe184, fontFamily: _regular);
  static const IconData checkCircleFill = IconData(0xe184, fontFamily: _fill);
  static const IconData chartPieSlice = IconData(0xe15a, fontFamily: _regular);
  static const IconData chartPieSliceFill = IconData(0xe15a, fontFamily: _fill);
  static const IconData user = IconData(0xe4c2, fontFamily: _regular);
  static const IconData userFill = IconData(0xe4c2, fontFamily: _fill);
  static const IconData userCircle = IconData(0xe4c4, fontFamily: _regular);
  static const IconData plus = IconData(0xe3d4, fontFamily: _regular);
  static const IconData receipt = IconData(0xe3ec, fontFamily: _regular);

  // Icons users pick for categories, wallets and habits.
  static const IconData forkKnife = IconData(0xe262, fontFamily: _regular);
  static const IconData bus = IconData(0xe106, fontFamily: _regular);
  static const IconData shoppingBag = IconData(0xe416, fontFamily: _regular);
  static const IconData filmSlate = IconData(0xe8c2, fontFamily: _regular);
  static const IconData firstAidKit = IconData(0xe570, fontFamily: _regular);
  static const IconData graduationCap = IconData(0xe62c, fontFamily: _regular);
  static const IconData dotsThreeCircle = IconData(
    0xe200,
    fontFamily: _regular,
  );
  static const IconData wallet = IconData(0xe68a, fontFamily: _regular);
  static const IconData laptop = IconData(0xe586, fontFamily: _regular);
  static const IconData gift = IconData(0xe276, fontFamily: _regular);

  /// Stored `iconKey` values (05 §3) mapped to icons. Codepoints are never
  /// stored, so the icon font can change without a data migration.
  static const Map<String, IconData> byKey = {
    'receipt': receipt,
    'forkKnife': forkKnife,
    'bus': bus,
    'shoppingBag': shoppingBag,
    'filmSlate': filmSlate,
    'firstAidKit': firstAidKit,
    'graduationCap': graduationCap,
    'dotsThreeCircle': dotsThreeCircle,
    'wallet': wallet,
    'laptop': laptop,
    'gift': gift,
  };
}
