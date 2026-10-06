"""Phase 4 screens on the emulator, around the checklist run (06 §1).

  python tool/qa/qa_phase4.py empty     # fresh app: no habits, templates
  # then the checklist, which leaves its data on the device:
  #   flutter drive --driver=test_driver/integration_test.dart \\
  #     --target=integration_test/phase4_checklist_test.dart
  python tool/qa/qa_phase4.py stepper   # long-press twice on the Home chip
  python tool/qa/qa_phase4.py screens   # Home strip, S-20, S-21, S-22
  python tool/qa/qa_phase4.py layout    # 360 dp + font 1.3 + dark

`empty` clears the app's data. `screens` and `layout` use what the
checklist built: Kopi (reduce, GoPay, checked in today) and Baca (build,
ten days with one grace day). Light and dark screenshots; --docs names
them phase-4-<screen>-<theme>.png for docs/process/phase-screens.
"""
import argparse
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from adb_driver import (  # noqa: E402
    back, find, font_scale, force_stop, fresh_start, hide_keyboard,
    keyboard_shown, labels,
    launch, logcat,
    night, nodes, screen_width_dp, screenshot, shell, tap, tap_scroll)
from qa_phase3 import device_today, onboard  # noqa: E402

results = []


def check(name, ok, detail=''):
    results.append((name, ok, detail))
    print(('PASS ' if ok else 'FAIL ') + name + (f' ({detail})' if detail else ''))


def long_press(label, contains=False, wait=1.5):
    x, y = find(label, contains=contains)['center']
    shell(f'input swipe {x} {y} {x} {y} 900')
    time.sleep(wait)


def open_habit(name, wait=2.0):
    """Taps a habit tile on its title, clear of the links and the check."""
    x1, y1, x2, y2 = find(name + '\n', contains=True)['bounds']
    shell(f'input tap {x1 + 200} {y1 + 40}')
    time.sleep(wait)


def scroll_down(wait=1.0):
    shell('input swipe 540 1800 540 800 400')
    time.sleep(wait)


def shooter(out_dir, docs, theme, shots):
    def shot(name):
        file = f'phase-4-{name}-{theme}.png' if docs else f'{theme}-{name}.png'
        path = os.path.join(out_dir, file)
        screenshot(path)
        shots.append(path)
    return shot


def walk_empty(shot):
    force_stop()
    launch()
    shot('home-no-habits')
    tap('Kebiasaan', wait=1.5)
    shot('habits-empty')
    tap('Pilih dari template', wait=1.5)
    shot('templates')
    tap('Kopi kekinian', contains=True, wait=2)
    shot('editor-template')
    scroll_down()
    shot('editor-reduce')
    tap('Tutup')
    if 'Buang' in labels():
        tap('Buang')


def walk_data(shot):
    force_stop()
    launch()
    shot('home-strip')
    long_press('Kopi, sudah check-in', contains=True)
    shot('stepper')
    back()
    tap('Kebiasaan', wait=1.5)
    shot('habits-today')
    tap('Semua')
    shot('habits-all')
    open_habit('Baca')
    shot('detail-build')
    # The checklist's grace day is three days back; show its month.
    if device_today().day <= 3:
        tap_scroll('Bulan sebelumnya')
        shell('input swipe 540 1500 540 1000 400')
        time.sleep(1)
    else:
        scroll_down()
    shot('detail-build-calendar')
    back()
    open_habit('Kopi')
    shot('detail-reduce')
    scroll_down()
    shot('detail-reduce-cost')
    back()
    tap('Buat kebiasaan', wait=1.0)
    find('Kebiasaan baru')
    # The name field takes focus. Back with that keyboard up closes the
    # form on the emulator (also the wallet form), so scroll above it.
    for _ in range(6):
        if any(n['label'] == 'Hari tertentu' for n in nodes()):
            break
        shell('input swipe 540 1000 540 500 400')
        time.sleep(0.8)
    tap('Hari tertentu')
    shot('editor-days')
    tap('Tutup')
    if 'Buang' in labels():
        tap('Buang')
    open_habit('Kopi')
    tap('Menu lainnya')
    tap('Edit', wait=1.5)
    tap('Bangun', contains=True)
    shot('kind-locked')
    back()
    tap('Tutup')
    back()


def empty(out_dir, docs):
    """a. A fresh app: Home without habits, S-20 empty, templates, S-21."""
    os.makedirs(out_dir, exist_ok=True)
    shots = []
    fresh_start()
    onboard(['1', '000', '000'])
    try:
        for theme in ('light', 'dark'):
            night(theme == 'dark')
            walk_empty(shooter(out_dir, docs, theme, shots))
    finally:
        night(False)
    check('a. screenshot tanpa kebiasaan (terang & gelap)', len(shots) == 10,
          f'{len(shots)} file di {out_dir}')


def stepper_twice():
    """d. On the real app, the Home chip's long-press opens the stepper again
    after a save (the test harness can't press twice in a row there)."""
    force_stop()
    launch()
    chip = find('Kopi, ', contains=True)
    before = chip['label']
    long_press('Kopi, ', contains=True)
    first = 'Jumlah hari ini' in labels()
    tap('Tambah satu', wait=0.5)
    tap('Simpan', wait=2.5)
    long_press('Kopi, ', contains=True)
    now = labels()
    check('d. long-press chip Beranda membuka stepper', first)
    check('d. long-press kedua setelah simpan membuka stepper lagi',
          'Jumlah hari ini' in now, before + ' → ' + next((l for l in now if l.endswith(' kali')), ''))
    tap('Kurangi satu', wait=0.5)
    tap('Simpan', wait=2.5)


def screens(out_dir, docs):
    """b. Strip, list, detail with a grace day, stepper, form, kind lock."""
    os.makedirs(out_dir, exist_ok=True)
    force_stop()
    launch()
    try:
        find('Kopi, ', contains=True, tries=12)
    except LookupError:
        raise SystemExit('Run the phase 4 checklist with flutter drive first.')
    shots = []
    try:
        for theme in ('light', 'dark'):
            night(theme == 'dark')
            walk_data(shooter(out_dir, docs, theme, shots))
    finally:
        night(False)
    check('b. screenshot kebiasaan (terang & gelap)', len(shots) == 20,
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
        walk_data(shooter(out_dir, False, 'dark', shots))
        log = logcat()
    finally:
        screen_width_dp(None)
        font_scale(1.0)
        night(False)
    overflows = len(re.findall('overflowed', log))
    errors = [l for l in log.splitlines() if ' E flutter' in l or 'EXCEPTION CAUGHT' in l]
    check('c. tanpa overflow (360 dp, font 1,3, gelap)', overflows == 0, f'{overflows} overflow')
    check('c. tanpa error Flutter di logcat', not errors, '; '.join(errors[:2]))
    check('c. screenshot 360 dp', len(shots) == 10, f'{len(shots)} file di {out_dir}')
    restored = shell('settings get system font_scale').strip()
    check('c. pengaturan emulator dikembalikan', restored in ('1.0', '1'), f'font_scale {restored}')


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument('check', choices=['empty', 'stepper', 'screens', 'layout'])
    parser.add_argument('--out', default=os.path.join('build', 'qa', 'phase4'))
    parser.add_argument('--docs', action='store_true')
    args = parser.parse_args()
    if args.check == 'empty':
        empty(args.out, args.docs)
    if args.check == 'stepper':
        stepper_twice()
    if args.check == 'screens':
        screens(args.out, args.docs)
    if args.check == 'layout':
        layout(os.path.join(args.out, '360dp-font-1.3'))
    failed = [r for r in results if not r[1]]
    print(f'\n{len(results) - len(failed)}/{len(results)} lulus')
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
