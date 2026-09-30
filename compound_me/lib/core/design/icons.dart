import 'package:flutter/widgets.dart';

/// Curated Phosphor icons (§6). The fonts in assets/fonts/phosphor are the
/// ones shipped with phosphor_flutter 2.1.0, and the codepoints below come
/// from that same release. Add an icon here before using it anywhere else.
abstract final class AppIcons {
  static const String _regular = 'PhosphorRegular';
  static const String _fill = 'PhosphorFill';

  // Navigation.
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

  // Interface icons; never offered in the icon picker.
  static const IconData caretRight = IconData(0xe13a, fontFamily: _regular);
  static const IconData caretLeft = IconData(0xe138, fontFamily: _regular);
  static const IconData caretDown = IconData(0xe136, fontFamily: _regular);
  static const IconData caretUp = IconData(0xe13c, fontFamily: _regular);
  static const IconData arrowLeft = IconData(0xe058, fontFamily: _regular);
  static const IconData x = IconData(0xe4f6, fontFamily: _regular);
  static const IconData check = IconData(0xe182, fontFamily: _regular);
  static const IconData circle = IconData(0xe18a, fontFamily: _regular);
  static const IconData dotsSixVertical = IconData(
    0xeae2,
    fontFamily: _regular,
  );
  static const IconData trash = IconData(0xe4a6, fontFamily: _regular);
  static const IconData archive = IconData(0xe00c, fontFamily: _regular);
  static const IconData arrowCounterClockwise = IconData(
    0xe038,
    fontFamily: _regular,
  );
  static const IconData pencilSimple = IconData(0xe3b4, fontFamily: _regular);
  static const IconData translate = IconData(0xe4a2, fontFamily: _regular);
  static const IconData sun = IconData(0xe472, fontFamily: _regular);
  static const IconData moon = IconData(0xe330, fontFamily: _regular);
  static const IconData circleHalf = IconData(0xe18c, fontFamily: _regular);
  static const IconData eye = IconData(0xe220, fontFamily: _regular);
  static const IconData eyeSlash = IconData(0xe224, fontFamily: _regular);
  static const IconData arrowDownLeft = IconData(0xe040, fontFamily: _regular);
  static const IconData arrowUpRight = IconData(0xe092, fontFamily: _regular);
  static const IconData plusMinus = IconData(0xe3d8, fontFamily: _regular);
  static const IconData calendarBlank = IconData(0xe10a, fontFamily: _regular);
  static const IconData notePencil = IconData(0xe34c, fontFamily: _regular);
  static const IconData magnifyingGlass = IconData(
    0xe30c,
    fontFamily: _regular,
  );
  static const IconData warningCircle = IconData(0xe4e2, fontFamily: _regular);
  static const IconData info = IconData(0xe2ce, fontFamily: _regular);
  static const IconData arrowSquareOut = IconData(0xe5de, fontFamily: _regular);
  static const IconData certificate = IconData(0xe766, fontFamily: _regular);
  static const IconData lockSimple = IconData(0xe308, fontFamily: _regular);
  static const IconData lightning = IconData(0xe2de, fontFamily: _regular);
  static const IconData backspace = IconData(0xe0ae, fontFamily: _regular);
  static const IconData trendUp = IconData(0xe4ae, fontFamily: _regular);
  static const IconData database = IconData(0xe1de, fontFamily: _regular);

  // Icons users pick for categories, wallets and habits (about 48, §6).
  // Money.
  static const IconData wallet = IconData(0xe68a, fontFamily: _regular);
  static const IconData money = IconData(0xe588, fontFamily: _regular);
  static const IconData bank = IconData(0xe0b4, fontFamily: _regular);
  static const IconData creditCard = IconData(0xe1d2, fontFamily: _regular);
  static const IconData deviceMobile = IconData(0xe1e0, fontFamily: _regular);
  static const IconData piggyBank = IconData(0xea04, fontFamily: _regular);
  static const IconData coins = IconData(0xe78e, fontFamily: _regular);
  static const IconData handCoins = IconData(0xea8c, fontFamily: _regular);
  static const IconData receipt = IconData(0xe3ec, fontFamily: _regular);
  static const IconData gift = IconData(0xe276, fontFamily: _regular);
  static const IconData storefront = IconData(0xe470, fontFamily: _regular);
  static const IconData briefcase = IconData(0xe0ee, fontFamily: _regular);
  // Food and drink.
  static const IconData forkKnife = IconData(0xe262, fontFamily: _regular);
  static const IconData coffee = IconData(0xe1c2, fontFamily: _regular);
  static const IconData hamburger = IconData(0xe790, fontFamily: _regular);
  static const IconData cookie = IconData(0xe6ca, fontFamily: _regular);
  static const IconData bowlFood = IconData(0xeaa4, fontFamily: _regular);
  static const IconData drop = IconData(0xe210, fontFamily: _regular);
  // Getting around.
  static const IconData bus = IconData(0xe106, fontFamily: _regular);
  static const IconData car = IconData(0xe112, fontFamily: _regular);
  static const IconData motorcycle = IconData(0xe80a, fontFamily: _regular);
  static const IconData gasPump = IconData(0xe768, fontFamily: _regular);
  static const IconData airplane = IconData(0xe002, fontFamily: _regular);
  static const IconData bicycle = IconData(0xe0d6, fontFamily: _regular);
  // Shopping and home.
  static const IconData shoppingBag = IconData(0xe416, fontFamily: _regular);
  static const IconData shoppingCart = IconData(0xe41e, fontFamily: _regular);
  static const IconData tShirt = IconData(0xe670, fontFamily: _regular);
  static const IconData lightbulb = IconData(0xe2dc, fontFamily: _regular);
  static const IconData wifiHigh = IconData(0xe4ea, fontFamily: _regular);
  // Fun.
  static const IconData filmSlate = IconData(0xe8c2, fontFamily: _regular);
  static const IconData gameController = IconData(0xe26e, fontFamily: _regular);
  static const IconData musicNotes = IconData(0xe340, fontFamily: _regular);
  static const IconData television = IconData(0xe754, fontFamily: _regular);
  // Health and sport.
  static const IconData firstAidKit = IconData(0xe570, fontFamily: _regular);
  static const IconData heartbeat = IconData(0xe2ac, fontFamily: _regular);
  static const IconData pill = IconData(0xe700, fontFamily: _regular);
  static const IconData barbell = IconData(0xe0b6, fontFamily: _regular);
  static const IconData personSimpleRun = IconData(
    0xe730,
    fontFamily: _regular,
  );
  // Learning and work.
  static const IconData graduationCap = IconData(0xe62c, fontFamily: _regular);
  static const IconData bookOpen = IconData(0xe0e6, fontFamily: _regular);
  static const IconData laptop = IconData(0xe586, fontFamily: _regular);
  // Life.
  static const IconData users = IconData(0xe4d6, fontFamily: _regular);
  static const IconData pawPrint = IconData(0xe648, fontFamily: _regular);
  static const IconData heart = IconData(0xe2a8, fontFamily: _regular);
  static const IconData plant = IconData(0xebae, fontFamily: _regular);
  static const IconData cigarette = IconData(0xed90, fontFamily: _regular);
  static const IconData dotsThreeCircle = IconData(
    0xe200,
    fontFamily: _regular,
  );

  /// Picker icons by their stored `iconKey`, in picker order. The database
  /// keeps these keys, never raw codepoints.
  static const Map<String, IconData> byKey = {
    'wallet': wallet,
    'money': money,
    'bank': bank,
    'creditCard': creditCard,
    'deviceMobile': deviceMobile,
    'piggyBank': piggyBank,
    'coins': coins,
    'handCoins': handCoins,
    'receipt': receipt,
    'gift': gift,
    'storefront': storefront,
    'briefcase': briefcase,
    'forkKnife': forkKnife,
    'coffee': coffee,
    'hamburger': hamburger,
    'cookie': cookie,
    'bowlFood': bowlFood,
    'drop': drop,
    'bus': bus,
    'car': car,
    'motorcycle': motorcycle,
    'gasPump': gasPump,
    'airplane': airplane,
    'bicycle': bicycle,
    'shoppingBag': shoppingBag,
    'shoppingCart': shoppingCart,
    'tShirt': tShirt,
    'house': house,
    'lightbulb': lightbulb,
    'wifiHigh': wifiHigh,
    'filmSlate': filmSlate,
    'gameController': gameController,
    'musicNotes': musicNotes,
    'television': television,
    'firstAidKit': firstAidKit,
    'heartbeat': heartbeat,
    'pill': pill,
    'barbell': barbell,
    'personSimpleRun': personSimpleRun,
    'graduationCap': graduationCap,
    'bookOpen': bookOpen,
    'laptop': laptop,
    'users': users,
    'pawPrint': pawPrint,
    'heart': heart,
    'plant': plant,
    'cigarette': cigarette,
    'dotsThreeCircle': dotsThreeCircle,
  };
}
