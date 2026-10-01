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

# The screenshots for docs/v2/screens (font 1.0, light and dark):
python tool/qa/qa_phase3.py screens --docs --out ../docs/v2/screens
```

Every `qa_phase3.py` check clears the app's data and seeds it through the
UI (onboarding with Tunai Rp 1.000.000, then transactions through the
form, two of them dated yesterday with the calendar sheet).

## Phase 4

```sh
# Fresh app: Home without habits, S-20 empty, templates, S-21 from a
# template (light + dark). Clears the app's data.
python tool/qa/qa_phase4.py empty --docs --out ../docs/v2/screens

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
python tool/qa/qa_phase4.py screens --docs --out ../docs/v2/screens
python tool/qa/qa_phase4.py layout    # 360 dp + font 1.3 + dark
```

On the emulator, pressing back while a form's autofocused keyboard is up
closes the form (the Phase 2 wallet form does the same), so the scripts
scroll above the keyboard instead. Fase 6 checks this on a real phone.
