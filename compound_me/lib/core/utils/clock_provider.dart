import 'dart:async';

import 'package:compound_me/core/utils/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

/// The raw clock, overridable in tests. Screens watch [nowProvider].
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => systemClock;

/// Local "now" for screens: greeting, "Hari ini"/"Kemarin", the default
/// month of Home and history, and the default date of a new transaction.
/// It moves on by itself when the app comes back to the foreground and at
/// the next local midnight, so an app left open overnight shows the new
/// day. The greeting's hours (04, 10, 15, 18) count as boundaries too.
@Riverpod(keepAlive: true)
class Now extends _$Now {
  Timer? _timer;

  @override
  DateTime build() {
    final listener = AppLifecycleListener(onResume: refresh);
    ref.onDispose(() {
      listener.dispose();
      _timer?.cancel();
    });
    final now = ref.watch(clockProvider)();
    _schedule(now);
    return now;
  }

  /// Reads the clock again and returns it; a new transaction takes its
  /// time from here (S-11).
  DateTime refresh() {
    final now = ref.read(clockProvider)();
    state = now;
    _schedule(now);
    return now;
  }

  void _schedule(DateTime now) {
    _timer?.cancel();
    _timer = Timer(nextRefresh(now).difference(now), refresh);
  }
}

/// Greeting hours from 03 S-10; midnight starts a new day.
const _boundaryHours = [4, 10, 15, 18];

/// The next local midnight or greeting boundary after [now].
DateTime nextRefresh(DateTime now) {
  for (final hour in _boundaryHours) {
    final at = DateTime(now.year, now.month, now.day, hour);
    if (at.isAfter(now)) return at;
  }
  return DateTime(now.year, now.month, now.day + 1);
}
