"""Phase 5 screens on the emulator, around the checklist run (06 §1).

  python tool/qa/qa_phase5.py empty     # fresh app: Wawasan under a week
  # then the checklist, which leaves 60 days of sample data on the device:
  #   flutter drive --keep-app-running --driver=test_driver/integration_test.dart \\
  #     --target=integration_test/phase5_checklist_test.dart
  python tool/qa/qa_phase5.py screens   # S-30, S-31, Home card, S-22
  python tool/qa/qa_phase5.py layout    # 360 dp + font 1.3 + dark

`empty` clears the app's data. `screens` and `layout` use the sample data
the checklist filled in. Light screenshots of every new screen, dark ones
of S-30 and S-31 only; --docs names them phase-5-<screen>-<theme>.png for
docs/process/phase-screens. S-30 is shown for last month, which is complete whatever
day of the month the emulator is on.
"""
import argparse
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    back, find, font_scale, force_stop, fresh_start, labels, launch, logcat, night,
    screen_width_dp, screenshot, shell, tap)
from qa_phase3 import device_today, month_label, onboard, previous_month  # noqa: E402
from qa_phase4 import open_habit  # noqa: E402

results = []


def check(name, ok, detail=''):
    results.append((name, ok, detail))
    print(('PASS ' if ok else 'FAIL ') + name + (f' ({detail})' if detail else ''))


def swipe_up(wait=1.0):
    shell('input swipe 540 1800 540 700 400')
    time.sleep(wait)


def swipe_down(wait=1.0):
    shell('input swipe 540 700 540 1800 400')
    time.sleep(wait)


def shooter(out_dir, docs, theme, shots):
    def shot(name):
        file = f'phase-5-{name}-{theme}.png' if docs else f'{theme}-{name}.png'
        path = os.path.join(out_dir, file)
        screenshot(path)
        shots.append(path)
    return shot


def open_last_month():
    """Wawasan for last month: complete data whatever today's date is."""
    tap('Wawasan', wait=1.5)
    tap('Wawasan ', contains=True, wait=1.2)
    tap(month_label(previous_month(device_today())), wait=2.0)


def walk_insights(shot, theme):
    """S-30 and S-31. Dark mode shows only these two."""
    force_stop()
    launch()
    open_last_month()
    shot('insights')
    if theme == 'light':
        swipe_up()
        shot('insights-categories')
        swipe_down()
    tap('Kopi', contains=True, wait=1.5)
    shot('simulator')
    if theme == 'light':
        tap('Tabung & kembangkan', contains=True, wait=1.0)
        tap('5%', wait=1.0)
        shot('simulator-invest')
    back()


def walk_home_and_detail(shot):
    force_stop()
    launch()
    shot('home')
    tap('Kebiasaan', wait=1.5)
    tap('Semua', wait=1.0)
    open_habit('Kopi')
    swipe_up()
    shot('detail-simulate')
    back()


def empty(out_dir, docs):
    """a. A fresh app: Wawasan says it needs a week, with 0 of 7 days."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []
    fresh_start()
    onboard(['1', '000', '000'])
    shot = shooter(out_dir, docs, 'light', shots)
    force_stop()
    launch()
    tap('Wawasan', wait=1.5)
    found = labels()
    shot('insights-empty')
    check('a. Wawasan kosong menampilkan progres', '0 dari 7 hari' in found,
          'ada teks "0 dari 7 hari"')
    check('a. screenshot Wawasan kosong', len(shots) == 1, out_dir)


def screens(out_dir, docs):
    """b. S-30, S-31, the Home card and S-22 on the sample data."""
    os.makedirs(out_dir, exist_ok=True)
    force_stop()
    launch()
    try:
        tap('Wawasan', wait=1.5)
        find('Kebiasaan yang dikurangi', tries=12)
    except LookupError:
        raise SystemExit('Run the phase 5 checklist with flutter drive first.')
    shots = []
    try:
        for theme in ('light', 'dark'):
            night(theme == 'dark')
            shot = shooter(out_dir, docs, theme, shots)
            walk_insights(shot, theme)
            if theme == 'light':
                walk_home_and_detail(shot)
    finally:
        night(False)
    check('b. screenshot Wawasan, simulator, Beranda, detail', len(shots) == 8,
          f'{len(shots)} file di {out_dir}')


def layout(out_dir):
    """c. 360 dp, font 1.3, dark: no overflow, no Flutter errors."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []
    try:
        font_scale(1.3)
        night(True)
        screen_width_dp(360)
        shell('logcat -c')
        shot = shooter(out_dir, False, 'dark', shots)
        walk_insights(shot, 'light')
        walk_home_and_detail(shot)
        log = logcat()
    finally:
        screen_width_dp(None)
        font_scale(1.0)
        night(False)
    overflows = len(re.findall('overflowed', log))
    errors = [l for l in log.splitlines() if ' E flutter' in l or 'EXCEPTION CAUGHT' in l]
    check('c. tanpa overflow (360 dp, font 1,3, gelap)', overflows == 0, f'{overflows} overflow')
    check('c. tanpa error Flutter di logcat', not errors, '; '.join(errors[:2]))
    check('c. screenshot 360 dp', len(shots) == 6, f'{len(shots)} file di {out_dir}')
    restored = shell('settings get system font_scale').strip()
    check('c. pengaturan emulator dikembalikan', restored in ('1.0', '1'), f'font_scale {restored}')


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('check', choices=['empty', 'screens', 'layout'])
    parser.add_argument('--out', default=os.path.join('build', 'qa', 'phase5'))
    parser.add_argument('--docs', action='store_true')
    args = parser.parse_args()
    if args.check == 'empty':
        empty(args.out, args.docs)
    if args.check == 'screens':
        screens(args.out, args.docs)
    if args.check == 'layout':
        layout(os.path.join(args.out, '360dp-font-1.3'))
    failed = [r for r in results if not r[1]]
    print(f'\n{len(results) - len(failed)}/{len(results)} lulus')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
