# QA on the emulator

Each phase's checklist (06 §2) runs automatically on the emulator before its
PR (06 §1): an integration test for what the app itself can drive, and adb
scripts for what needs the system (force stop, font scale, dark mode,
intents). Results go into the PR as a pass/fail table.

## Before running

- Emulator Pixel 9 (API 35) running: `emulator -avd Pixel_9`.
- Python 3.9+ and adb. The scripts find adb through `ADB`, `ANDROID_HOME`,
  `ANDROID_SDK_ROOT` or the default Windows SDK path.
- Run everything from the repository root.

## Phase 2

```sh
# a-e: delete all, onboarding with a reduce template, English, discard
# dialog, second wallet. Uses the device's own storage; prints the tap count.
flutter test integration_test/phase2_checklist_test.dart -d emulator-5554

# flutter test uninstalls the app afterwards, so install the debug build again
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# f-h: resume after force stop, font 1.3 + dark screenshots, GitHub intent
python tool/qa/qa_phase2.py all
```

`qa_phase2.py` clears the app's data (`resume`, `screens`) and restores the
emulator's font scale and dark mode when it finishes. Screenshots land in
`build/qa/phase2/`. Overflow errors are counted from logcat; clipped text
is judged from the screenshots.

Android 15 redacts URI paths in logcat and dumpsys (`dat=https://github.com/...`),
so `github-link` checks the scheme, host and Chrome as target, and the exact
repository URL is asserted in
`test/features/settings/presentation/settings_screens_test.dart`.

## Phase 3

```sh
# a-h: clean data, Flow B tap count ("kopi Rp 22.000" with the last
# category chosen), delete + undo, edit moving wallets, hide balance at
# launch, strict month + "Lihat" + search in history, midnight at the end
# of a month (a clock started at 23:59:57, so the real timer fires) and
# returning to the app. Prints "QA Flow B: ..." with the tap count.
flutter test integration_test/phase3_checklist_test.dart -d emulator-5554

flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Flow B again on the installed app, hide balance across real relaunches
# (force stop), history month/search, light + dark screenshots, and the
# layout at 360 dp + font 1.3 (summary card in one row, no overflow).
python tool/qa/qa_phase3.py all

# The screenshots for docs/process/phase-screens (font 1.0, light and dark):
python tool/qa/qa_phase3.py screens --docs --out docs/process/phase-screens
```

Every `qa_phase3.py` check clears the app's data and seeds it through the
UI (onboarding with Tunai Rp 1.000.000, then transactions through the
form, two of them dated yesterday with the calendar sheet).

## Phase 4

```sh
# Fresh app: Home without habits, S-20 empty, templates, S-21 from a
# template (light + dark). Clears the app's data.
python tool/qa/qa_phase4.py empty --docs --out docs/process/phase-screens

# a-e: clean data, "Kopi Rp 25.000, GoPay, Makanan" → check-in lands in
# GoPay, long-press count 2 then 1, one missed day kept as a grace day,
# five fast taps stay consistent. `flutter drive --keep-app-running`
# leaves the app's data on the device for the screenshots below
# (`flutter test` would uninstall it).
flutter drive --keep-app-running --driver=test_driver/integration_test.dart \
  --target=integration_test/phase4_checklist_test.dart -d emulator-5554

# flutter drive installs its own test build: put the app back (data stays)
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

python tool/qa/qa_phase4.py stepper   # long-press the Home chip twice
python tool/qa/qa_phase4.py screens --docs --out docs/process/phase-screens
python tool/qa/qa_phase4.py layout    # 360 dp + font 1.3 + dark
```

On the emulator, pressing back while a form's autofocused keyboard is up
closes the form (the Phase 2 wallet form does the same), so the scripts
scroll above the keyboard instead. Fase 6 checks this on a real phone.

## Phase 5

```sh
# Fresh app: Wawasan under a week of data, "0 dari 7 hari" (light).
# Clears the app's data.
python tool/qa/qa_phase5.py empty --docs --out docs/process/phase-screens

# a-e: clean data and "3 dari 7 hari" after one expense two days back,
# the debug sample data (60 days, only in debug builds) from Settings and
# a second press refused, Wawasan numbers against the database for this
# and last month, the simulator (50% of coffee 3x/week x Rp 25.000 is
# Rp 1.950.000 a year, 1/3/5 years with 5% interest, disclaimer in view at
# every step), the Home insight card. Leaves the sample data on the device.
flutter drive --keep-app-running --driver=test_driver/integration_test.dart   --target=integration_test/phase5_checklist_test.dart -d emulator-5554

flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# S-30, S-31, the Home card and S-22 in light mode, S-30 and S-31 in dark
python tool/qa/qa_phase5.py screens --docs --out docs/process/phase-screens
python tool/qa/qa_phase5.py layout    # 360 dp + font 1.3 + dark
```

S-30 is shot for last month: it is complete whatever day of the month the
emulator is on.

## Phase 6

The audit itself runs in `flutter test` (`test/audit/`: design rules, screens
at text scale 1,3 in both languages, error states). What needs the emulator
or the release build:

```sh
# 1.000 transactions, history scroll in profile mode; writes
# build/history_scroll.timeline_summary.json and build/baseline_scroll.timeline_summary.json
# (a plain ListView on the same emulator, to read the raster times against).
flutter drive --profile --no-dds --driver=test_driver/perf_driver.dart --target=integration_test/perf_history_test.dart -d emulator-5554

# Cold start in profile mode: build/start_up_info.json
# (timeToFirstFrameRasterizedMicros, three runs).
flutter run --profile --trace-startup --no-dds -d emulator-5554

# Signed release build (needs android/key.properties, see 06 §5), then the
# R8 smoke test: onboarding, transaction, check-in, Insights, About, force
# stop and relaunch, logcat without crashes. Uninstall a debug build first.
flutter build apk --release
adb uninstall com.umem.compound_me
adb install build/app/outputs/flutter-apk/app-release.apk
python tool/qa/qa_phase6.py release

# The two portfolio videos (docs/media, 20 s at most each).
python tool/qa/qa_phase6.py video-flow-b
python tool/qa/qa_phase6.py video-habit
```

16 KB page size, on the release APK (Android build-tools 35.0.0 or newer):

```sh
zipalign -c -P 16 -v 4 build/app/outputs/flutter-apk/app-release.apk
```

and every 64-bit `.so` must have LOAD segments aligned to at least 0x4000
(`p_align`, as in the Android documentation's `check_elf_alignment.sh`).
