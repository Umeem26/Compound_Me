# QA on the emulator

Each phase's checklist (06 §2) runs automatically on the emulator before its
PR (06 §1): an integration test for what the app itself can drive, and adb
scripts for what needs the system (force stop, font scale, dark mode,
intents). Results go into the PR as a pass/fail table.

## Before running

- Emulator Pixel 9 (API 35) running: `emulator -avd Pixel_9`.
- Python 3.9+ and adb. The scripts find adb through `ADB`, `ANDROID_HOME`,
  `ANDROID_SDK_ROOT` or the default Windows SDK path.
- Run everything from `compound_me/`.

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
