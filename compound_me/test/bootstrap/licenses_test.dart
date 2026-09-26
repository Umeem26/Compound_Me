import 'package:compound_me/bootstrap/licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registers the bundled font licenses', () async {
    registerBundledLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    String textOf(String package) => entries
        .firstWhere((e) => e.packages.contains(package))
        .paragraphs
        .map((p) => p.text)
        .join('\n');

    expect(
      textOf(BundledLicenses.plusJakartaSansPackage),
      contains('SIL Open Font License'),
    );
    expect(textOf(BundledLicenses.phosphorPackage), contains('MIT License'));
  });
}
