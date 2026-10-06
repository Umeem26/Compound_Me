import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Host side of the performance runs: turns the timeline of each traced
/// action into `build/NAME.timeline_summary.json` (frame build and raster
/// times, missed frames).
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    for (final name in ['history_scroll', 'baseline_scroll']) {
      final timeline = driver.Timeline.fromJson(
        data[name] as Map<String, dynamic>,
      );
      await driver.TimelineSummary.summarize(timeline)
          .writeTimelineToFile(name, pretty: true);
    }
  },
);
