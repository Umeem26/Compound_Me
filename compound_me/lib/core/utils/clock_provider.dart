import 'package:compound_me/core/utils/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// "Now" for screens (greeting, "Hari ini"), overridable in tests.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => systemClock;
