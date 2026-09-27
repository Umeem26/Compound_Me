/// Source of "now", injectable so repositories and calculators stay
/// deterministic in tests.
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
