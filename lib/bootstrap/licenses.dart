import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// License files for assets that ship inside the app rather than as a pub
/// package, so they also appear on the "Open source licenses" page.
abstract final class BundledLicenses {
  static const plusJakartaSansPackage = 'Plus Jakarta Sans';
  static const plusJakartaSansAsset = 'assets/fonts/OFL.txt';
  static const phosphorPackage = 'Phosphor Icons';
  static const phosphorAsset = 'assets/fonts/phosphor/LICENSE.txt';
}

void registerBundledLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      BundledLicenses.plusJakartaSansPackage,
    ], await rootBundle.loadString(BundledLicenses.plusJakartaSansAsset));
    yield LicenseEntryWithLineBreaks(const [
      BundledLicenses.phosphorPackage,
    ], await rootBundle.loadString(BundledLicenses.phosphorAsset));
  });
}
