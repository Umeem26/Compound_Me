import 'package:compound_me/app.dart';
import 'package:compound_me/bootstrap/app_bootstrap.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Single native splash: held only while bootstrap runs, removed after the
  // first frame in CompoundMeApp. No Flutter splash widget, no fake delay.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  final bootstrap = await AppBootstrap.load();
  runApp(
    ProviderScope(overrides: bootstrap.overrides, child: const CompoundMeApp()),
  );
}
